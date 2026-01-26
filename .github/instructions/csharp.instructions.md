---
applyTo: '**/*.cs'
---
# 🔷 Clean C# & ASP.NET Core — Best Practices & Standards

> Guidelines for writing clean, maintainable, and production-ready ASP.NET Core Web APIs.

---

## 🎯 Core Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep controllers thin. Business logic lives in `Services/`. |
| **Repository Pattern** | All database access goes through `Repositories/`. Services never interact with EF Core directly. |
| **Dependency Injection** | Use constructor injection for all dependencies. Register in `Program.cs` or extension methods. |
| **Type Safety** | Leverage C#'s strong typing, nullable reference types, and records. |
| **DTOs** | Use dedicated DTOs for requests/responses. Never expose entities directly. |
| **Async First** | Use `async/await` for all I/O-bound operations. |
| **KISS** | Keep It Simple, Stupid. Favor simplicity over cleverness. |
| **DRY** | Don't Repeat Yourself. Extract reusable logic. |
| **SRP** | Single Responsibility. One component, one job. |
| **Explicit > Implicit** | Code should be obvious, not clever. |

---

## 🏷️ Naming Conventions

| Type | Convention | Example |
| :--- | :--- | :--- |
| Classes | PascalCase | `UserService`, `JobRepository` |
| Interfaces | I + PascalCase | `IUserService`, `IJobRepository` |
| Methods | PascalCase | `GetUserByIdAsync`, `CreateAccessTokenAsync` |
| Properties | PascalCase | `FirstName`, `CreatedAt` |
| Private Fields | _camelCase | `_userRepository`, `_logger` |
| Parameters | camelCase | `userId`, `cancellationToken` |
| Constants | PascalCase | `MaxPageSize`, `DefaultTimeout` |
| DTOs (Request) | PascalCase + Request | `CreateUserRequest`, `UpdateJobRequest` |
| DTOs (Response) | PascalCase + Response | `UserResponse`, `JobListResponse` |
| Routes | kebab-case | `/api/v1/user-profile` |

---

## 🏗️ Controller Patterns

### Keep Controllers Thin

```csharp
// ❌ Too much logic in controller
[ApiController]
[Route("api/v1/users")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserRequest request)
    {
        var existing = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email);
        
        if (existing != null)
            return Conflict("Email already registered");

        var user = new User
        {
            Email = request.Email,
            Password = BCrypt.HashPassword(request.Password),
            FullName = request.FullName
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        await _emailService.SendWelcomeEmailAsync(user.Email);

        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }
}


// ✅ Delegate to service layer
[ApiController]
[Route("api/v1/users")]
[Produces("application/json")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPost]
    [ProducesResponseType(typeof(UserResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<ActionResult<UserResponse>> Create(
        [FromBody] CreateUserRequest request,
        CancellationToken cancellationToken)
    {
        var user = await _userService.CreateAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }
}
```

### Use Dependency Injection

```csharp
// ✅ Constructor injection
[ApiController]
[Route("api/v1/jobs")]
public class JobsController : ControllerBase
{
    private readonly IJobService _jobService;
    private readonly ILogger<JobsController> _logger;

    public JobsController(
        IJobService jobService,
        ILogger<JobsController> logger)
    {
        _jobService = jobService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResponse<JobResponse>>> GetAll(
        [FromQuery] JobFilterRequest filter,
        CancellationToken cancellationToken)
    {
        var result = await _jobService.GetPaginatedAsync(filter, cancellationToken);
        return Ok(result);
    }
}
```

---

## 📦 Repository Pattern

### Repository Interface & Implementation

```csharp
// ✅ Define repository interface
public interface IUserRepository
{
    Task<User?> FindByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<User?> FindByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User> CreateAsync(User user, CancellationToken cancellationToken = default);
    Task<User> UpdateAsync(User user, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(User user, CancellationToken cancellationToken = default);
    Task<(List<User> Items, int TotalCount)> GetPaginatedAsync(
        int skip, 
        int take, 
        CancellationToken cancellationToken = default);
}


// ✅ Implement repository
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<User?> FindByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .FirstOrDefaultAsync(u => u.Id == id, cancellationToken);
    }

    public async Task<User?> FindByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _context.Users
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    }

    public async Task<User> CreateAsync(User user, CancellationToken cancellationToken = default)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync(cancellationToken);
        return user;
    }

    public async Task<User> UpdateAsync(User user, CancellationToken cancellationToken = default)
    {
        _context.Users.Update(user);
        await _context.SaveChangesAsync(cancellationToken);
        return user;
    }

    public async Task<bool> DeleteAsync(User user, CancellationToken cancellationToken = default)
    {
        _context.Users.Remove(user);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<(List<User> Items, int TotalCount)> GetPaginatedAsync(
        int skip,
        int take,
        CancellationToken cancellationToken = default)
    {
        var query = _context.Users.AsQueryable();
        
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip(skip)
            .Take(take)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
}
```

### Services Use Repositories

```csharp
// ❌ Service accessing EF Core directly
public class UserService : IUserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<UserResponse> CreateAsync(CreateUserRequest request, CancellationToken ct)
    {
        var user = new User { Email = request.Email };
        _context.Users.Add(user);  // Direct DbContext access
        await _context.SaveChangesAsync(ct);
        return MapToResponse(user);
    }
}


// ✅ Service delegates to repository
public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserService> _logger;

    public UserService(
        IUserRepository userRepository,
        ILogger<UserService> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<UserResponse> CreateAsync(
        CreateUserRequest request,
        CancellationToken cancellationToken)
    {
        var existing = await _userRepository.FindByEmailAsync(request.Email, cancellationToken);
        if (existing is not null)
        {
            throw new DuplicateEmailException(request.Email);
        }

        var user = new User
        {
            Email = request.Email,
            Password = PasswordHasher.Hash(request.Password),
            FullName = request.FullName
        };

        var created = await _userRepository.CreateAsync(user, cancellationToken);
        
        _logger.LogInformation("User {UserId} created with email {Email}", created.Id, created.Email);

        return MapToResponse(created);
    }

    public async Task<UserResponse> GetByIdAsync(int id, CancellationToken cancellationToken)
    {
        var user = await _userRepository.FindByIdAsync(id, cancellationToken)
            ?? throw new UserNotFoundException(id);

        return MapToResponse(user);
    }

    private static UserResponse MapToResponse(User user) => new()
    {
        Id = user.Id,
        Email = user.Email,
        FullName = user.FullName,
        CreatedAt = user.CreatedAt
    };
}
```

### Register Dependencies in Program.cs

```csharp
// ✅ Extension method for clean registration
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IJobRepository, JobRepository>();
        return services;
    }

    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IJobService, JobService>();
        services.AddScoped<IAuthService, AuthService>();
        return services;
    }
}


// Program.cs
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services
    .AddRepositories()
    .AddApplicationServices();
```

---

## 📋 DTO & Validation

### Request & Response DTOs

```csharp
// ✅ Request DTOs with validation attributes
public record CreateUserRequest
{
    [Required]
    [EmailAddress]
    [MaxLength(255)]
    public required string Email { get; init; }

    [Required]
    [MinLength(8)]
    [MaxLength(128)]
    public required string Password { get; init; }

    [MaxLength(255)]
    public string? FullName { get; init; }
}


public record UpdateUserRequest
{
    [EmailAddress]
    [MaxLength(255)]
    public string? Email { get; init; }

    [MaxLength(255)]
    public string? FullName { get; init; }
}


// ✅ Response DTOs (immutable records)
public record UserResponse
{
    public int Id { get; init; }
    public required string Email { get; init; }
    public string? FullName { get; init; }
    public DateTime CreatedAt { get; init; }
    public ProfileResponse? Profile { get; init; }
}


public record PagedResponse<T>
{
    public required IReadOnlyList<T> Data { get; init; }
    public int Total { get; init; }
    public int Page { get; init; }
    public int PerPage { get; init; }
    public int TotalPages { get; init; }
}
```

### FluentValidation (Advanced)

```csharp
// ✅ Complex validation with FluentValidation
public class CreateJobRequestValidator : AbstractValidator<CreateJobRequest>
{
    public CreateJobRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MinimumLength(3)
            .MaximumLength(255)
            .Must(title => !string.IsNullOrWhiteSpace(title))
            .WithMessage("Title cannot be empty or whitespace");

        RuleFor(x => x.SalaryMin)
            .GreaterThanOrEqualTo(0)
            .When(x => x.SalaryMin.HasValue);

        RuleFor(x => x.SalaryMax)
            .GreaterThanOrEqualTo(x => x.SalaryMin ?? 0)
            .When(x => x.SalaryMax.HasValue && x.SalaryMin.HasValue)
            .WithMessage("Maximum salary must be greater than or equal to minimum salary");
    }
}


// Register in Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<CreateJobRequestValidator>();
builder.Services.AddFluentValidationAutoValidation();
```

---

## 🌐 Global API Standards

### URL Structure

| Pattern | Description | Example |
| :--- | :--- | :--- |
| `/api/v1/{resource}` | Resource collection | `/api/v1/users` |
| `/api/v1/{resource}/{id}` | Single resource | `/api/v1/users/123` |
| `/api/v1/{resource}/{id}/{sub}` | Nested resource | `/api/v1/users/123/applications` |
| `/api/v1/{resource}/{id}/actions/{action}` | Custom actions | `/api/v1/jobs/123/actions/apply` |

### API Versioning

```csharp
// ✅ URL path versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
    options.ApiVersionReader = new UrlSegmentApiVersionReader();
});


// Controller with versioning
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/users")]
public class UsersController : ControllerBase
{
    // ...
}
```

### HTTP Methods

| Method | Action | Response |
| :--- | :--- | :--- |
| `GET` | Read resource(s) | 200 with data |
| `POST` | Create resource | 201 with created resource |
| `PUT` | Full update | 200 with updated resource |
| `PATCH` | Partial update | 200 with updated resource |
| `DELETE` | Remove resource | 204 No Content |

### Pagination Pattern

```csharp
// ✅ Pagination request
public record PaginationRequest
{
    [Range(1, int.MaxValue)]
    public int Page { get; init; } = 1;

    [Range(1, 100)]
    public int PerPage { get; init; } = 20;

    public int Skip => (Page - 1) * PerPage;
}


// ✅ Repository with pagination and filtering
public class JobRepository : IJobRepository
{
    private readonly AppDbContext _context;

    public async Task<(List<Job> Items, int TotalCount)> GetPaginatedAsync(
        JobFilterRequest filter,
        CancellationToken cancellationToken = default)
    {
        var query = _context.Jobs.AsQueryable();

        // Apply filters
        if (!string.IsNullOrEmpty(filter.Status))
        {
            query = query.Where(j => j.Status == filter.Status);
        }

        if (!string.IsNullOrEmpty(filter.Search))
        {
            query = query.Where(j => j.Title.Contains(filter.Search));
        }

        // Get total count before pagination
        var totalCount = await query.CountAsync(cancellationToken);

        // Apply sorting
        query = filter.SortOrder?.ToLower() == "asc"
            ? query.OrderBy(j => EF.Property<object>(j, filter.SortBy ?? "CreatedAt"))
            : query.OrderByDescending(j => EF.Property<object>(j, filter.SortBy ?? "CreatedAt"));

        // Apply pagination
        var items = await query
            .Skip(filter.Skip)
            .Take(filter.PerPage)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
}


// ✅ Service builds paginated response
public class JobService : IJobService
{
    public async Task<PagedResponse<JobResponse>> GetPaginatedAsync(
        JobFilterRequest filter,
        CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _jobRepository.GetPaginatedAsync(filter, cancellationToken);
        var totalPages = (int)Math.Ceiling(totalCount / (double)filter.PerPage);

        return new PagedResponse<JobResponse>
        {
            Data = items.Select(MapToResponse).ToList(),
            Total = totalCount,
            Page = filter.Page,
            PerPage = filter.PerPage,
            TotalPages = totalPages
        };
    }
}
```

### Filtering & Sorting

```csharp
// ✅ Filter request with validation
public record JobFilterRequest : PaginationRequest
{
    [RegularExpression("^(draft|active|closed)$")]
    public string? Status { get; init; }

    [MinLength(2)]
    [MaxLength(100)]
    public string? Search { get; init; }

    [RegularExpression("^(CreatedAt|Title|Salary)$")]
    public string? SortBy { get; init; } = "CreatedAt";

    [RegularExpression("^(asc|desc)$")]
    public string? SortOrder { get; init; } = "desc";
}
```

---

## 📊 HTTP Status Codes

### ✅ Success (2xx)

| Code | When to Use |
| :--- | :--- |
| `200 OK` | Successful GET, PUT, PATCH |
| `201 Created` | Successful POST creating a resource |
| `202 Accepted` | Request accepted for async processing |
| `204 No Content` | Successful DELETE |

### ⚠️ Client Errors (4xx)

| Code | When to Use |
| :--- | :--- |
| `400 Bad Request` | Malformed request syntax |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but not authorized |
| `404 Not Found` | Resource does not exist |
| `409 Conflict` | Duplicate or state conflict |
| `422 Unprocessable Entity` | Validation errors |

### 💥 Server Errors (5xx)

| Code | When to Use |
| :--- | :--- |
| `500 Internal Server Error` | Unhandled exceptions |
| `503 Service Unavailable` | Database or service down |

---

## 🚨 Error Handling

### Custom Exception Classes

```csharp
// ✅ Base application exception
public abstract class AppException : Exception
{
    public string Code { get; }
    public int StatusCode { get; }
    public IDictionary<string, object>? Details { get; }

    protected AppException(
        string message,
        string code,
        int statusCode = 400,
        IDictionary<string, object>? details = null)
        : base(message)
    {
        Code = code;
        StatusCode = statusCode;
        Details = details;
    }
}


// ✅ Domain-specific exceptions
public class UserNotFoundException : AppException
{
    public UserNotFoundException(int userId) : base(
        message: $"User with id {userId} not found",
        code: "USER_NOT_FOUND",
        statusCode: 404)
    { }
}


public class DuplicateEmailException : AppException
{
    public DuplicateEmailException(string email) : base(
        message: "Email already registered",
        code: "DUPLICATE_EMAIL",
        statusCode: 409,
        details: new Dictionary<string, object> { ["email"] = email })
    { }
}


public class InsufficientPermissionsException : AppException
{
    public InsufficientPermissionsException(string action) : base(
        message: $"Not authorized to {action}",
        code: "FORBIDDEN",
        statusCode: 403)
    { }
}
```

### Global Exception Handler Middleware

```csharp
// ✅ Exception handling middleware
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (AppException ex)
        {
            _logger.LogWarning(ex, "Application exception: {Message}", ex.Message);
            await HandleExceptionAsync(context, ex);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            await HandleUnknownExceptionAsync(context);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, AppException ex)
    {
        context.Response.StatusCode = ex.StatusCode;
        context.Response.ContentType = "application/json";

        var response = new
        {
            message = ex.Message,
            code = ex.Code,
            details = ex.Details
        };

        await context.Response.WriteAsJsonAsync(response);
    }

    private static async Task HandleUnknownExceptionAsync(HttpContext context)
    {
        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        context.Response.ContentType = "application/json";

        var response = new
        {
            message = "An unexpected error occurred",
            code = "INTERNAL_ERROR"
        };

        await context.Response.WriteAsJsonAsync(response);
    }
}


// Register in Program.cs
app.UseMiddleware<ExceptionHandlingMiddleware>();
```

### Problem Details (RFC 7807)

```csharp
// ✅ Standard problem details
builder.Services.AddProblemDetails(options =>
{
    options.CustomizeProblemDetails = context =>
    {
        context.ProblemDetails.Extensions["traceId"] = context.HttpContext.TraceIdentifier;
    };
});
```

---

## 🔒 Security Patterns

### JWT Authentication

```csharp
// ✅ Auth service
public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly JwtSettings _jwtSettings;

    public AuthService(
        IUserRepository userRepository,
        IOptions<JwtSettings> jwtSettings)
    {
        _userRepository = userRepository;
        _jwtSettings = jwtSettings.Value;
    }

    public async Task<string> AuthenticateAsync(
        string email,
        string password,
        CancellationToken cancellationToken)
    {
        var user = await _userRepository.FindByEmailAsync(email, cancellationToken)
            ?? throw new InvalidCredentialsException();

        if (!PasswordHasher.Verify(password, user.Password))
        {
            throw new InvalidCredentialsException();
        }

        return GenerateToken(user);
    }

    private string GenerateToken(User user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

### Configure JWT in Program.cs

```csharp
// ✅ JWT configuration
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()!;
        
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings.Secret))
        };
    });

builder.Services.AddAuthorization();
```

### Current User Extension

```csharp
// ✅ Extension to get current user
public static class HttpContextExtensions
{
    public static int GetUserId(this HttpContext context)
    {
        var claim = context.User.FindFirst(ClaimTypes.NameIdentifier);
        if (claim is null || !int.TryParse(claim.Value, out var userId))
        {
            throw new UnauthorizedAccessException();
        }
        return userId;
    }

    public static string GetUserRole(this HttpContext context)
    {
        return context.User.FindFirst(ClaimTypes.Role)?.Value ?? "user";
    }
}


// ✅ Usage in controller
[HttpGet("me")]
[Authorize]
public async Task<ActionResult<UserResponse>> GetCurrentUser(CancellationToken cancellationToken)
{
    var userId = HttpContext.GetUserId();
    var user = await _userService.GetByIdAsync(userId, cancellationToken);
    return Ok(user);
}
```

### Role-Based Authorization

```csharp
// ✅ Authorize by role
[Authorize(Roles = "Admin")]
[HttpDelete("{id}")]
public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
{
    await _userService.DeleteAsync(id, cancellationToken);
    return NoContent();
}


// ✅ Policy-based authorization
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("ModeratorOrAdmin", policy => 
        policy.RequireRole("Admin", "Moderator"));
});


[Authorize(Policy = "ModeratorOrAdmin")]
[HttpPut("{id}")]
public async Task<ActionResult<JobResponse>> Update(
    int id,
    [FromBody] UpdateJobRequest request,
    CancellationToken cancellationToken)
{
    var job = await _jobService.UpdateAsync(id, request, cancellationToken);
    return Ok(job);
}
```

### Resource-Based Authorization

```csharp
// ✅ Authorization handler for resource ownership
public class JobAuthorizationHandler : AuthorizationHandler<OperationAuthorizationRequirement, Job>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OperationAuthorizationRequirement requirement,
        Job resource)
    {
        var userId = int.Parse(context.User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var userRole = context.User.FindFirst(ClaimTypes.Role)?.Value;

        if (resource.UserId == userId || userRole == "Admin")
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}


// Register handler
builder.Services.AddSingleton<IAuthorizationHandler, JobAuthorizationHandler>();


// ✅ Usage in controller
[HttpPut("{id}")]
[Authorize]
public async Task<ActionResult<JobResponse>> Update(
    int id,
    [FromBody] UpdateJobRequest request,
    CancellationToken cancellationToken)
{
    var job = await _jobRepository.FindByIdAsync(id, cancellationToken)
        ?? throw new JobNotFoundException(id);

    var authResult = await _authorizationService.AuthorizeAsync(User, job, Operations.Update);
    if (!authResult.Succeeded)
    {
        throw new InsufficientPermissionsException("update this job");
    }

    var updated = await _jobService.UpdateAsync(job, request, cancellationToken);
    return Ok(updated);
}
```

---

## 🧪 Testing Patterns

### Unit Test Structure with xUnit

```csharp
// ✅ Arrange-Act-Assert pattern
public class UserServiceTests
{
    private readonly Mock<IUserRepository> _userRepositoryMock;
    private readonly Mock<ILogger<UserService>> _loggerMock;
    private readonly UserService _sut; // System Under Test

    public UserServiceTests()
    {
        _userRepositoryMock = new Mock<IUserRepository>();
        _loggerMock = new Mock<ILogger<UserService>>();
        _sut = new UserService(_userRepositoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task CreateAsync_WithValidRequest_ReturnsUserResponse()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "test@example.com",
            Password = "securepass123",
            FullName = "Test User"
        };

        _userRepositoryMock
            .Setup(r => r.FindByEmailAsync(request.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);

        _userRepositoryMock
            .Setup(r => r.CreateAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((User u, CancellationToken _) =>
            {
                u.Id = 1;
                u.CreatedAt = DateTime.UtcNow;
                return u;
            });

        // Act
        var result = await _sut.CreateAsync(request, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(request.Email, result.Email);
        Assert.Equal(request.FullName, result.FullName);
    }

    [Fact]
    public async Task CreateAsync_WithDuplicateEmail_ThrowsDuplicateEmailException()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "existing@example.com",
            Password = "password123"
        };

        _userRepositoryMock
            .Setup(r => r.FindByEmailAsync(request.Email, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new User { Id = 1, Email = request.Email });

        // Act & Assert
        await Assert.ThrowsAsync<DuplicateEmailException>(
            () => _sut.CreateAsync(request, CancellationToken.None));
    }
}
```

### Integration Tests with WebApplicationFactory

```csharp
// ✅ Integration test setup
public class UsersControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly WebApplicationFactory<Program> _factory;

    public UsersControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace with test database
                services.RemoveAll<DbContextOptions<AppDbContext>>();
                services.AddDbContext<AppDbContext>(options =>
                    options.UseInMemoryDatabase("TestDb"));
            });
        });
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task Create_WithValidRequest_Returns201Created()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "test@example.com",
            Password = "securepass123",
            FullName = "Test User"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/v1/users", request);

        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var user = await response.Content.ReadFromJsonAsync<UserResponse>();
        Assert.NotNull(user);
        Assert.Equal(request.Email, user.Email);
    }

    [Fact]
    public async Task Create_WithDuplicateEmail_Returns409Conflict()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Email = "duplicate@example.com",
            Password = "password123"
        };

        // Create first user
        await _client.PostAsJsonAsync("/api/v1/users", request);

        // Act - try to create duplicate
        var response = await _client.PostAsJsonAsync("/api/v1/users", request);

        // Assert
        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
    }
}
```

### Test Fixtures & Utilities

```csharp
// ✅ Test data builder
public class UserBuilder
{
    private int _id = 1;
    private string _email = "test@example.com";
    private string _role = "user";
    private string? _fullName;

    public UserBuilder WithId(int id)
    {
        _id = id;
        return this;
    }

    public UserBuilder WithEmail(string email)
    {
        _email = email;
        return this;
    }

    public UserBuilder WithRole(string role)
    {
        _role = role;
        return this;
    }

    public UserBuilder AsAdmin() => WithRole("Admin");

    public User Build() => new()
    {
        Id = _id,
        Email = _email,
        Role = _role,
        FullName = _fullName,
        Password = "hashedpassword",
        CreatedAt = DateTime.UtcNow
    };
}


// Usage
var admin = new UserBuilder().AsAdmin().WithEmail("admin@example.com").Build();
```

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad |
| :--- | :--- |
| Business logic in controllers | Hard to test, violates SRP |
| Services accessing DbContext directly | Couples business logic to EF Core, harder to test |
| Returning entities from controllers | Exposes internal structure, couples API to DB |
| Sync over async (`Task.Result`, `.Wait()`) | Causes deadlocks and thread pool starvation |
| Catching `Exception` without rethrowing | Hides bugs, makes debugging difficult |
| Using `static` for stateful services | Makes testing impossible, hidden dependencies |
| N+1 queries | Kills performance, use `.Include()` |
| Hardcoded connection strings | Security risk, breaks across environments |
| Missing `CancellationToken` | Cannot gracefully cancel long operations |
| Not disposing resources | Memory leaks, connection exhaustion |

---

## 📝 Documentation & Style

### XML Documentation Comments

```csharp
/// <summary>
/// Creates a new user in the database.
/// </summary>
/// <param name="request">The user creation request containing email and password.</param>
/// <param name="cancellationToken">Cancellation token for the operation.</param>
/// <returns>The newly created user response.</returns>
/// <exception cref="DuplicateEmailException">Thrown when email is already registered.</exception>
public async Task<UserResponse> CreateAsync(
    CreateUserRequest request,
    CancellationToken cancellationToken)
{
    // Implementation
}
```

### Swagger/OpenAPI Documentation

```csharp
// ✅ Enhanced Swagger documentation
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "My API",
        Version = "v1",
        Description = "API documentation for My Application"
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    options.IncludeXmlComments(xmlPath);

    // JWT authentication
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
```

### .editorconfig

```ini
# .editorconfig
root = true

[*.cs]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

# Naming conventions
dotnet_naming_rule.private_fields_should_be_camel_case.severity = warning
dotnet_naming_rule.private_fields_should_be_camel_case.symbols = private_fields
dotnet_naming_rule.private_fields_should_be_camel_case.style = camel_case_with_underscore

dotnet_naming_symbols.private_fields.applicable_kinds = field
dotnet_naming_symbols.private_fields.applicable_accessibilities = private

dotnet_naming_style.camel_case_with_underscore.required_prefix = _
dotnet_naming_style.camel_case_with_underscore.capitalization = camel_case

# Code style
csharp_style_var_for_built_in_types = false:suggestion
csharp_style_var_when_type_is_apparent = true:suggestion
csharp_prefer_braces = true:warning
csharp_style_expression_bodied_methods = when_on_single_line:suggestion
```

---

## 📂 Folder Structure

See [STRUCTURE_BACKEND.md](../../STRUCTURE_BACKEND.md) for full details.

---

## ✅ Quick Checklist

- [ ] Controllers delegate to service layer
- [ ] Services delegate database access to repositories
- [ ] Dependencies registered in `Program.cs` or extension methods
- [ ] All routes return DTOs, not entities
- [ ] Data annotations or FluentValidation for input validation
- [ ] All async methods use `CancellationToken`
- [ ] Custom exceptions for business logic errors
- [ ] Global exception handler middleware registered
- [ ] Proper HTTP status codes used
- [ ] Error responses include `message` field
- [ ] JWT authentication configured
- [ ] Role-based authorization where needed
- [ ] Unit tests with mocks for services
- [ ] Integration tests with WebApplicationFactory
- [ ] API versioning implemented (`/api/v1/`)
- [ ] `.Include()` used to prevent N+1 queries
- [ ] No entities exposed in API responses
- [ ] Swagger/OpenAPI documentation configured
- [ ] Nullable reference types enabled
- [ ] Code formatted according to .editorconfig
