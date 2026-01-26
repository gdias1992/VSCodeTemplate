---
applyTo: '**/*.php'
---
# 🐘 Clean PHP & Laravel — Best Practices & Standards

> Guidelines for writing clean, maintainable, and production-ready Laravel applications.

---

## 🎯 Core Principles

| Principle | Description |
| :--- | :--- |
| **Service Layer** | Keep controllers thin. Business logic lives in `Services/`. |
| **Repository Pattern** | All database access goes through `Repositories/`. Services never interact with Eloquent directly. |
| **Dependency Injection** | Use Laravel's container for services, repositories, and shared dependencies. |
| **Type Safety** | Use PHP 8+ type declarations on all method signatures and properties. |
| **Form Requests** | Validate all input using dedicated Form Request classes. |
| **Resources** | Transform models using API Resources for consistent responses. |
| **KISS** | Keep It Simple, Stupid. Favor simplicity over cleverness. |
| **DRY** | Don't Repeat Yourself. Extract reusable logic. |
| **SRP** | Single Responsibility. One component, one job. |
| **Explicit > Implicit** | Code should be obvious, not clever. |

---

## 🏷️ Naming Conventions

| Type | Convention | Example |
| :--- | :--- | :--- |
| Controllers | PascalCase + Controller | `UserController`, `JobApplicationController` |
| Models | PascalCase (singular) | `User`, `JobApplication` |
| Services | PascalCase + Service | `UserService`, `AuthService` |
| Repositories | PascalCase + Repository | `UserRepository`, `JobRepository` |
| Form Requests | PascalCase + Request | `StoreUserRequest`, `UpdateJobRequest` |
| Resources | PascalCase + Resource | `UserResource`, `JobCollection` |
| Migrations | snake_case with timestamp | `2026_01_23_create_users_table` |
| Methods | camelCase | `getUserById`, `createAccessToken` |
| Routes | kebab-case | `/api/v1/user-profile` |

---

## 🏗️ Controller Patterns

### Keep Controllers Thin

```php
// ❌ Too much logic in controller
class UserController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);
        
        $user = new User();
        $user->email = $validated['email'];
        $user->password = Hash::make($validated['password']);
        $user->save();
        
        event(new UserRegistered($user));
        Mail::to($user)->send(new WelcomeEmail($user));
        
        return response()->json($user, 201);
    }
}

// ✅ Delegate to service layer
class UserController extends Controller
{
    public function __construct(
        private readonly UserService $userService
    ) {}

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = $this->userService->create($request->validated());
        
        return UserResource::make($user)
            ->response()
            ->setStatusCode(201);
    }
}
```

### Use Dependency Injection

```php
// ✅ Constructor injection
class JobController extends Controller
{
    public function __construct(
        private readonly JobService $jobService,
        private readonly JobSearchService $searchService
    ) {}

    public function index(IndexJobRequest $request): AnonymousResourceCollection
    {
        $jobs = $this->jobService->getPaginated($request->validated());
        
        return JobResource::collection($jobs);
    }
}
```

---

## 📦 Repository Pattern

### Repository Interface & Implementation

```php
// ✅ Define repository interface
interface UserRepositoryInterface
{
    public function findById(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function create(array $data): User;
    public function update(User $user, array $data): User;
    public function delete(User $user): bool;
    public function paginate(int $perPage = 20): LengthAwarePaginator;
}

// ✅ Implement repository
class UserRepository implements UserRepositoryInterface
{
    public function __construct(
        private readonly User $model
    ) {}

    public function findById(int $id): ?User
    {
        return $this->model->find($id);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->model->where('email', $email)->first();
    }

    public function create(array $data): User
    {
        return $this->model->create($data);
    }

    public function update(User $user, array $data): User
    {
        $user->update($data);
        return $user->fresh();
    }

    public function delete(User $user): bool
    {
        return $user->delete();
    }

    public function paginate(int $perPage = 20): LengthAwarePaginator
    {
        return $this->model->paginate($perPage);
    }
}
```

### Services Use Repositories

```php
// ❌ Service accessing Eloquent directly
class UserService
{
    public function create(array $data): User
    {
        return User::create($data); // Direct model access
    }
}

// ✅ Service delegates to repository
class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository
    ) {}

    public function create(array $data): User
    {
        if ($this->userRepository->findByEmail($data['email'])) {
            throw new DuplicateEmailException();
        }

        return $this->userRepository->create([
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'full_name' => $data['full_name'] ?? null,
        ]);
    }

    public function getById(int $id): User
    {
        $user = $this->userRepository->findById($id);

        if (!$user) {
            throw new ModelNotFoundException('User not found');
        }

        return $user;
    }
}
```

### Bind Repositories in Service Provider

```php
// app/Providers/RepositoryServiceProvider.php
class RepositoryServiceProvider extends ServiceProvider
{
    public array $bindings = [
        UserRepositoryInterface::class => UserRepository::class,
        JobRepositoryInterface::class => JobRepository::class,
    ];
}
```

---

## 📋 Form Request Validation

### Dedicated Request Classes

```php
// ✅ Separation of validation logic
class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'full_name' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'This email is already registered.',
        ];
    }
}

class UpdateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['sometimes', 'email', 'unique:users,email,' . $this->user->id],
            'full_name' => ['sometimes', 'string', 'max:255'],
        ];
    }
}
```

---

## 🎨 API Resources

### Transform Models Consistently

```php
// ✅ Never return Eloquent models directly
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'email' => $this->email,
            'full_name' => $this->full_name,
            'created_at' => $this->created_at->toIso8601String(),
            'profile' => ProfileResource::make($this->whenLoaded('profile')),
        ];
    }
}

// Usage in controller
return UserResource::make($user);
return UserResource::collection($users);
```

### Resource Collections with Meta

```php
// ✅ Paginated responses with metadata
class JobCollection extends ResourceCollection
{
    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
            'meta' => [
                'total' => $this->total(),
                'page' => $this->currentPage(),
                'per_page' => $this->perPage(),
                'total_pages' => $this->lastPage(),
            ],
        ];
    }
}
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

### Route Definitions

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    // Public routes
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/register', [AuthController::class, 'register']);
    
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('me', [UserController::class, 'me']);
        
        Route::apiResource('users', UserController::class);
        Route::apiResource('jobs', JobController::class);
        
        // Custom actions
        Route::post('jobs/{job}/apply', [JobController::class, 'apply']);
    });
});
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

```php
// ✅ Consistent pagination via repository
class JobRepository implements JobRepositoryInterface
{
    public function getPaginated(array $filters): LengthAwarePaginator
    {
        return Job::query()
            ->when($filters['status'] ?? null, fn($q, $status) => $q->where('status', $status))
            ->when($filters['search'] ?? null, fn($q, $search) => $q->where('title', 'like', "%{$search}%"))
            ->orderBy($filters['sort_by'] ?? 'created_at', $filters['sort_order'] ?? 'desc')
            ->paginate($filters['per_page'] ?? 20);
    }
}

// ✅ Service uses repository
class JobService
{
    public function __construct(
        private readonly JobRepositoryInterface $jobRepository
    ) {}

    public function getPaginated(array $filters): LengthAwarePaginator
    {
        return $this->jobRepository->getPaginated($filters);
    }
}
```

### Filtering & Sorting

```php
// ✅ Query parameter conventions
class IndexJobRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'status' => ['nullable', 'in:draft,active,closed'],
            'sort_by' => ['nullable', 'in:created_at,title,salary'],
            'sort_order' => ['nullable', 'in:asc,desc'],
            'search' => ['nullable', 'string', 'min:2', 'max:100'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
            'page' => ['nullable', 'integer', 'min:1'],
        ];
    }
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
| `422 Unprocessable Entity` | Validation errors (Laravel default) |

### 💥 Server Errors (5xx)

| Code | When to Use |
| :--- | :--- |
| `500 Internal Server Error` | Unhandled exceptions |
| `503 Service Unavailable` | Database or service temporarily down |

---

## 🚨 Error Handling

### Consistent Error Response Structure

```php
// ✅ Custom exception handler in bootstrap/app.php (Laravel 11+)
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (Throwable $e, Request $request) {
        if ($request->expectsJson()) {
            return match (true) {
                $e instanceof ModelNotFoundException => response()->json([
                    'message' => 'Resource not found',
                ], 404),
                $e instanceof AuthorizationException => response()->json([
                    'message' => $e->getMessage(),
                ], 403),
                default => null, // Let Laravel handle it
            };
        }
    });
})
```

### Custom Business Exceptions

```php
// ✅ Domain-specific exceptions
class DuplicateEmailException extends Exception
{
    public function render(Request $request): JsonResponse
    {
        return response()->json([
            'message' => 'Email already registered',
            'code' => 'DUPLICATE_EMAIL',
        ], 409);
    }
}

class InsufficientPermissionsException extends Exception
{
    public function __construct(
        private readonly string $action
    ) {
        parent::__construct("Not authorized to {$action}");
    }

    public function render(Request $request): JsonResponse
    {
        return response()->json([
            'message' => $this->getMessage(),
        ], 403);
    }
}
```

### Service Layer Exception Handling

```php
// ✅ Throw exceptions from services, use repositories for data access
class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository
    ) {}

    public function getById(int $id): User
    {
        $user = $this->userRepository->findById($id);

        if (!$user) {
            throw new ModelNotFoundException('User not found');
        }

        return $user;
    }

    public function create(array $data): User
    {
        if ($this->userRepository->findByEmail($data['email'])) {
            throw new DuplicateEmailException();
        }

        return $this->userRepository->create([
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'full_name' => $data['full_name'] ?? null,
        ]);
    }
}
```

---

## 🔒 Security Patterns

### Authentication with Sanctum

```php
// ✅ API token authentication
class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $token = $this->authService->attemptLogin(
            $request->email,
            $request->password
        );

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(null, 204);
    }
}
```

### Authorization with Policies

```php
// ✅ Policy-based authorization
class JobPolicy
{
    public function update(User $user, Job $job): bool
    {
        return $user->id === $job->user_id || $user->isAdmin();
    }

    public function delete(User $user, Job $job): bool
    {
        return $user->id === $job->user_id || $user->isAdmin();
    }
}

// Usage in controller
public function update(UpdateJobRequest $request, Job $job): JsonResponse
{
    $this->authorize('update', $job);

    $job = $this->jobService->update($job, $request->validated());

    return JobResource::make($job);
}
```

### Middleware for Role-Based Access

```php
// ✅ Custom middleware
class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (!$request->user() || !in_array($request->user()->role, $roles)) {
            abort(403, 'Insufficient permissions');
        }

        return $next($request);
    }
}

// Usage in routes
Route::middleware('role:admin')->group(function () {
    Route::delete('users/{user}', [UserController::class, 'destroy']);
});
```

---

## 🧪 Testing Patterns

### Feature Test Structure

```php
// ✅ Arrange-Act-Assert pattern
class UserControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_user(): void
    {
        // Arrange
        $userData = [
            'email' => 'test@example.com',
            'password' => 'securepass123',
            'password_confirmation' => 'securepass123',
        ];

        // Act
        $response = $this->postJson('/api/v1/users', $userData);

        // Assert
        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'email', 'created_at'],
            ])
            ->assertJsonPath('data.email', 'test@example.com');

        $this->assertDatabaseHas('users', ['email' => 'test@example.com']);
    }

    public function test_cannot_create_user_with_duplicate_email(): void
    {
        // Arrange
        User::factory()->create(['email' => 'existing@example.com']);

        // Act
        $response = $this->postJson('/api/v1/users', [
            'email' => 'existing@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        // Assert
        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
```

### Test Helpers

```php
// ✅ Authenticated requests
public function test_authenticated_user_can_view_profile(): void
{
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->getJson('/api/v1/me');

    $response->assertOk()
        ->assertJsonPath('data.id', $user->id);
}

// ✅ Factory states
class UserFactory extends Factory
{
    public function admin(): static
    {
        return $this->state(fn() => ['role' => 'admin']);
    }

    public function verified(): static
    {
        return $this->state(fn() => ['email_verified_at' => now()]);
    }
}

// Usage
$admin = User::factory()->admin()->create();
```

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad |
| :--- | :--- |
| Business logic in controllers | Hard to test, violates SRP |
| Services accessing Eloquent directly | Couples business logic to ORM, harder to test and maintain |
| Returning Eloquent models directly | Exposes internal structure, couples API to DB |
| Raw queries without bindings | SQL injection vulnerability |
| Validation in controllers | Duplicated logic, hard to maintain |
| Using `env()` outside config | Breaks config caching |
| N+1 queries | Kills performance, use eager loading |
| Mass assignment without `$fillable` | Security vulnerability |
| Hardcoded configuration | Not portable, breaks across environments |

---

## 📝 Documentation & Style

### DocBlocks

```php
/**
 * Create a new user in the database.
 *
 * @param array{email: string, password: string, full_name?: string} $data
 * @return User
 * @throws DuplicateEmailException If email is already registered.
 */
public function create(array $data): User
{
    // ...
}
```

### Route Documentation with OpenAPI

```php
/**
 * @OA\Post(
 *     path="/api/v1/users",
 *     summary="Create a new user",
 *     tags={"Users"},
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(ref="#/components/schemas/StoreUserRequest")
 *     ),
 *     @OA\Response(
 *         response=201,
 *         description="User created successfully",
 *         @OA\JsonContent(ref="#/components/schemas/UserResource")
 *     ),
 *     @OA\Response(response=422, description="Validation error")
 * )
 */
public function store(StoreUserRequest $request): JsonResponse
{
    // ...
}
```

---

## 📂 Folder Structure

See [STRUCTURE_BACKEND.md](../../STRUCTURE_BACKEND.md) for full details.

---

## ✅ Quick Checklist

- [ ] Controllers delegate to service layer
- [ ] Services delegate database access to repositories
- [ ] Repository interfaces bound in service provider
- [ ] All endpoints return API Resources
- [ ] Form Requests for all input validation
- [ ] Type declarations on all method signatures
- [ ] Policies for authorization logic
- [ ] Proper HTTP status codes used
- [ ] Error responses include `message` field
- [ ] Authentication uses Sanctum middleware
- [ ] Sensitive data never logged or exposed
- [ ] Tests cover happy path and error cases
- [ ] API versioning implemented (`/api/v1/`)
- [ ] Eager loading used to prevent N+1 queries
- [ ] `$fillable` or `$guarded` on all models
