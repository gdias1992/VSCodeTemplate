# 📐 Blip Standard Libraries — Integration Guide

> Reference document for integrating **Blip.Starter.Common** libraries into ASP.NET Core Web API projects. Use this as the standard for all new Blip backend services.

---

## 📦 Package Overview

| Package | Version | Purpose |
|---------|---------|---------|
| `Blip.Starter.Common.Env` | 1.1.0 | Environment metadata and detection (service name, release, cluster) |
| `Blip.Starter.Common.Logs` | 1.1.0 | Centralized structured logging via Serilog |
| `Blip.Starter.Common.Secrets` | 1.1.0 | HashiCorp Vault integration for secure secret management |
| `Blip.Starter.Common.Traces` | 1.1.0 | Distributed tracing and performance monitoring |

### Installation

Add all four packages to your `.csproj`:

```xml
<PackageReference Include="Blip.Starter.Common.Env" Version="1.1.0" />
<PackageReference Include="Blip.Starter.Common.Logs" Version="1.1.0" />
<PackageReference Include="Blip.Starter.Common.Secrets" Version="1.1.0" />
<PackageReference Include="Blip.Starter.Common.Traces" Version="1.1.0" />
```

> **Note**: `Blip.Starter.Common.Logs` depends on `Serilog.AspNetCore`, which must also be referenced:
> ```xml
> <PackageReference Include="Serilog.AspNetCore" Version="10.0.0" />
> ```

---

## 1️⃣ Blip.Starter.Common.Env

### Purpose

Provides an `Environment` class that encapsulates service identity metadata: the **service name**, **release number**, and **cluster name**. This object is consumed by other Blip libraries (e.g., Secrets) to scope configurations properly.

### Integration

#### appsettings.json — `$Metadata` section

Define the metadata section at the root of `appsettings.json`:

```json
{
  "$Metadata": {
    "HostServiceName": "my-service-name",
    "ReleaseNumber": "1.0.0",
    "ClusterName": "production"
  }
}
```

| Key | Type | Description | Example |
|-----|------|-------------|---------|
| `HostServiceName` | `string` | Unique identifier for the service | `"blip-rh-desk"` |
| `ReleaseNumber` | `string` | Current release/version of the service | `"1.0.0"` |
| `ClusterName` | `string` | Deployment cluster or environment name | `"production"`, `"local"` |

#### appsettings.Development.json — Override for local development

```json
{
  "$Metadata": {
    "HostServiceName": "my-service-name",
    "ReleaseNumber": "1.0.0-dev",
    "ClusterName": "local"
  }
}
```

#### Program.cs — Reading metadata and creating the Environment

```csharp
using BlipEnvironment = Blip.Starter.Common.Env.Environment;

// Read environment metadata from configuration
var metadataSection = builder.Configuration.GetSection("$Metadata");
var hostServiceName = metadataSection.GetValue<string>("HostServiceName") ?? "my-service-name";
var releaseNumber = metadataSection.GetValue<string>("ReleaseNumber") ?? "1.0.0";
var clusterName = metadataSection.GetValue<string>("ClusterName") ?? "local";

var blipEnvironment = new BlipEnvironment(hostServiceName, releaseNumber, clusterName);
```

> **Tip**: Use a `using` alias (`BlipEnvironment`) to avoid conflicts with `System.Environment`.

---

## 2️⃣ Blip.Starter.Common.Logs

### Purpose

Provides the `AddLogSink` extension method that configures Serilog with Blip's centralized structured logging standard, including log sinks, enrichment, and exception destructuring.

### Integration

#### appsettings.json — `LogSink` section

```json
{
  "LogSink": {
    "LogLevel": "Information",
    "EnabledLogSinks": ["Json"],
    "EnrichLogWithEventType": true,
    "ExceptionDestructuringEnabled": true,
    "SeqExceptionLogDestructuringDepth": 3
  }
}
```

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| `LogLevel` | `string` | Minimum log level (`Debug`, `Information`, `Warning`, `Error`, `Fatal`) | `"Information"` |
| `EnabledLogSinks` | `string[]` | Active sinks: `"Console"`, `"Json"`, `"Seq"` | `["Json"]` |
| `EnrichLogWithEventType` | `bool` | Adds event type hash to log entries for easier filtering | `true` |
| `ExceptionDestructuringEnabled` | `bool` | Enables deep destructuring of exception objects | `true` |
| `SeqExceptionLogDestructuringDepth` | `int` | Depth for exception destructuring when using Seq | `3` |

#### appsettings.Development.json — Override for local development

```json
{
  "LogSink": {
    "LogLevel": "Debug",
    "EnabledLogSinks": ["Console"],
    "EnrichLogWithEventType": true,
    "ExceptionDestructuringEnabled": true,
    "SeqExceptionLogDestructuringDepth": 3
  }
}
```

> Use `"Console"` sink locally for readable output. Use `"Json"` in production for structured log aggregation.

#### Program.cs — Registering the log sink

The log sink must be configured **before** any other service registration to capture startup logs:

```csharp
using Blip.Starter.Common.Logs.Integration;
using Serilog;

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Configure Blip logging FIRST
    builder.Services.AddLogSink(builder.Configuration);
    builder.Host.UseSerilog();

    Log.Information("API Starting");

    // ... remaining service registration ...

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    await Log.CloseAndFlushAsync();
}
```

#### Key Points

1. **Call `AddLogSink` first** — before any other `builder.Services` registration.
2. **Call `builder.Host.UseSerilog()`** — replaces the default logging provider with Serilog.
3. **Wrap in try/catch/finally** — ensures `Log.Fatal` captures startup failures and `Log.CloseAndFlushAsync()` flushes all buffered logs on shutdown.
4. **Use `ILogger<T>` everywhere** — standard .NET `ILogger<T>` injection works seamlessly because Serilog replaces the default provider.

---

## 3️⃣ Blip.Starter.Common.Secrets

### Purpose

Integrates with **HashiCorp Vault** to inject secrets into `IConfiguration` at startup. In development, secrets can be disabled to use local `appsettings.Development.json` values instead.

### Integration

#### appsettings.json — `Secrets` section (Production)

```json
{
  "Secrets": {
    "Enabled": true,
    "Engine": "HashicorpVault",
    "EnableHostServiceNamePath": true,
    "EnableTenantPath": false,
    "Paths": [],
    "HashicorpVaultUrl": "https://vault.blip.tools",
    "HashicorpVaultServiceAccountPath": "/var/run/secrets/kubernetes.io/serviceaccount/token",
    "HashicorpVaultMountPoint": "tool"
  }
}
```

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| `Enabled` | `bool` | Enable/disable Vault integration | `true` |
| `Engine` | `string` | Secret engine type | `"HashicorpVault"` |
| `EnableHostServiceNamePath` | `bool` | Scope secrets by service name | `true` |
| `EnableTenantPath` | `bool` | Scope secrets by tenant | `false` |
| `Paths` | `string[]` | Additional custom secret paths | `[]` |
| `HashicorpVaultUrl` | `string` | Vault server URL | `"https://vault.blip.tools"` |
| `HashicorpVaultServiceAccountPath` | `string` | Path to K8s service account token for Vault auth | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |
| `HashicorpVaultMountPoint` | `string` | Vault mount point for the secrets engine | `"tool"` |

#### appsettings.Development.json — Disable for local development

```json
{
  "Secrets": {
    "Enabled": false
  }
}
```

> When `Enabled` is `false`, Vault is not contacted. All secrets should be provided locally (e.g., connection strings in `appsettings.Development.json`).

#### ISecretConfiguration Implementation

Create a configuration class that implements `ISecretConfiguration` and reads values from `IConfiguration`:

```csharp
using Blip.Starter.Common.Secrets;
using Microsoft.Extensions.Configuration;

namespace MyProject.Configuration;

public class AppSettingsSecretConfiguration : ISecretConfiguration
{
    public bool Enabled { get; set; }
    public bool EnableTenantPath { get; set; }
    public bool EnableHostServiceNamePath { get; set; }
    public string[] Paths { get; set; }
    public string? HashicorpVaultMountPoint { get; set; }
    public string? HashicorpVaultRoleName { get; set; }
    public string HashicorpVaultServiceAccountPath { get; set; }
    public string HashicorpVaultUrl { get; set; }

    public AppSettingsSecretConfiguration(
        IConfiguration configuration,
        string hostServiceName,
        string clusterName)
    {
        var secretsSection = configuration.GetSection("Secrets");

        Enabled = secretsSection.GetValue<bool>("Enabled", true);
        EnableTenantPath = secretsSection.GetValue<bool>("EnableTenantPath", false);
        EnableHostServiceNamePath = secretsSection.GetValue<bool>(
            "EnableHostServiceNamePath", true);

        var pathsList = secretsSection.GetSection("Paths").Get<string[]>();
        Paths = pathsList ?? Array.Empty<string>();

        HashicorpVaultUrl =
            secretsSection.GetValue<string>("HashicorpVaultUrl")
            ?? "https://vault.blip.tools";

        HashicorpVaultServiceAccountPath =
            secretsSection.GetValue<string>("HashicorpVaultServiceAccountPath")
            ?? "/var/run/secrets/kubernetes.io/serviceaccount/token";

        HashicorpVaultRoleName =
            secretsSection.GetValue<string>("HashicorpVaultRoleName")
            ?? hostServiceName;

        HashicorpVaultMountPoint =
            secretsSection.GetValue<string>("HashicorpVaultMountPoint")
            ?? "tool";
    }
}
```

#### Program.cs — Registering secrets

```csharp
using Blip.Starter.Common.Secrets.Integrations.AspNet;

// Create the secret configuration (after reading $Metadata)
var secretConfiguration = new AppSettingsSecretConfiguration(
    builder.Configuration,
    hostServiceName,
    clusterName
);

// Add secrets to the configuration pipeline
builder.Configuration.AddSecrets(
    environment: blipEnvironment,
    configuration: secretConfiguration
);
```

#### Key Points

1. **Create `BlipEnvironment` first** — the `AddSecrets` call requires it.
2. **`ISecretConfiguration`** — reads from `appsettings.json` so all Vault settings are centralized in configuration files rather than environment variables.
3. **Disable in development** — set `"Enabled": false` in `appsettings.Development.json` to avoid needing a Vault instance locally.
4. **Secrets are injected into `IConfiguration`** — once loaded, they are accessible via `builder.Configuration["key"]` or `IOptions<T>` like any other configuration value.

---

## 4️⃣ Blip.Starter.Common.Traces

### Purpose

Provides distributed tracing and performance monitoring, typically integrating with **OpenTelemetry**. The package is installed as a dependency to enable trace propagation and observability across Blip microservices.

### Installation

```xml
<PackageReference Include="Blip.Starter.Common.Traces" Version="1.1.0" />
```

> **Note**: This library is included in the dependency set to ensure observability readiness. Explicit trace configuration (e.g., OpenTelemetry exporters) may need additional setup depending on the target infrastructure.

---

## 🔗 Full Integration — Program.cs (Complete Example)

Below is the full recommended `Program.cs` incorporating all four Blip libraries:

```csharp
using System.Text;
using MyProject.Configuration;
using MyProject.Data;
using MyProject.Middleware;
using Blip.Starter.Common.Logs.Integration;
using Blip.Starter.Common.Secrets.Integrations.AspNet;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using BlipEnvironment = Blip.Starter.Common.Env.Environment;

try
{
    var builder = WebApplication.CreateBuilder(args);

    // ──────────────────────────────────────────────
    // 1. LOGGING (must be first)
    // ──────────────────────────────────────────────
    builder.Services.AddLogSink(builder.Configuration);
    builder.Host.UseSerilog();

    Log.Information("API Starting");

    // ──────────────────────────────────────────────
    // 2. ENVIRONMENT METADATA
    // ──────────────────────────────────────────────
    var metadataSection = builder.Configuration.GetSection("$Metadata");
    var hostServiceName = metadataSection.GetValue<string>("HostServiceName") ?? "my-service";
    var releaseNumber   = metadataSection.GetValue<string>("ReleaseNumber") ?? "1.0.0";
    var clusterName     = metadataSection.GetValue<string>("ClusterName") ?? "local";

    var blipEnvironment = new BlipEnvironment(hostServiceName, releaseNumber, clusterName);

    // ──────────────────────────────────────────────
    // 3. SECRETS (HashiCorp Vault)
    // ──────────────────────────────────────────────
    var secretConfiguration = new AppSettingsSecretConfiguration(
        builder.Configuration,
        hostServiceName,
        clusterName
    );

    builder.Configuration.AddSecrets(
        environment: blipEnvironment,
        configuration: secretConfiguration
    );

    // ──────────────────────────────────────────────
    // 4. APPLICATION SERVICES
    // ──────────────────────────────────────────────
    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();
    builder.Services.AddHealthChecks();

    // Database, Auth, DI registrations...

    var app = builder.Build();

    // Middleware pipeline...

    await app.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    await Log.CloseAndFlushAsync();
}

public partial class Program { }
```

---

## 📋 Full Configuration — appsettings.json (Template)

```json
{
  "$Metadata": {
    "HostServiceName": "my-service-name",
    "ReleaseNumber": "1.0.0",
    "ClusterName": "production"
  },
  "Secrets": {
    "Enabled": true,
    "Engine": "HashicorpVault",
    "EnableHostServiceNamePath": true,
    "EnableTenantPath": false,
    "Paths": [],
    "HashicorpVaultUrl": "https://vault.blip.tools",
    "HashicorpVaultServiceAccountPath": "/var/run/secrets/kubernetes.io/serviceaccount/token",
    "HashicorpVaultMountPoint": "tool"
  },
  "LogSink": {
    "LogLevel": "Information",
    "EnabledLogSinks": ["Json"],
    "EnrichLogWithEventType": true,
    "ExceptionDestructuringEnabled": true,
    "SeqExceptionLogDestructuringDepth": 3
  },
  "ConnectionStrings": {
    "DefaultConnection": ""
  },
  "AllowedHosts": "*"
}
```

---

## 📋 Full Configuration — appsettings.Development.json (Template)

```json
{
  "$Metadata": {
    "HostServiceName": "my-service-name",
    "ReleaseNumber": "1.0.0-dev",
    "ClusterName": "local"
  },
  "Secrets": {
    "Enabled": false
  },
  "LogSink": {
    "LogLevel": "Debug",
    "EnabledLogSinks": ["Console"],
    "EnrichLogWithEventType": true,
    "ExceptionDestructuringEnabled": true,
    "SeqExceptionLogDestructuringDepth": 3
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=127.0.0.1;Database=my_db;Username=postgres;Password=mypassword"
  }
}
```

---

## ⚠️ Important Rules

1. **Initialization Order**: Always initialize in this order: **Logs → Env → Secrets → Services**.
2. **Try/Catch/Finally**: Wrap the entire `Program.cs` body to guarantee `Log.Fatal` captures startup errors and `Log.CloseAndFlushAsync()` flushes on exit.
3. **Development vs Production**: Use `appsettings.Development.json` to disable Vault and switch to `Console` logging.
4. **Never hardcode secrets**: Connection strings and API keys in production must come from Vault, not from `appsettings.json`.
5. **`$Metadata` is mandatory**: All Blip services must define `HostServiceName`, `ReleaseNumber`, and `ClusterName`.

---

## ✅ Checklist for New Projects

- [ ] All four `Blip.Starter.Common.*` packages added to `.csproj`
- [ ] `Serilog.AspNetCore` package added to `.csproj`
- [ ] `$Metadata` section defined in `appsettings.json` and `appsettings.Development.json`
- [ ] `LogSink` section defined in `appsettings.json` and `appsettings.Development.json`
- [ ] `Secrets` section defined in `appsettings.json` (enabled) and `appsettings.Development.json` (disabled)
- [ ] `AddLogSink` called **first** in `Program.cs`
- [ ] `UseSerilog()` called on `builder.Host`
- [ ] `BlipEnvironment` created from `$Metadata` values
- [ ] `AppSettingsSecretConfiguration` class implemented (implements `ISecretConfiguration`)
- [ ] `AddSecrets` called with `BlipEnvironment` and `AppSettingsSecretConfiguration`
- [ ] `Program.cs` wrapped in `try/catch/finally` with `Log.Fatal` and `Log.CloseAndFlushAsync()`
- [ ] `public partial class Program { }` declared at the bottom for integration test support
