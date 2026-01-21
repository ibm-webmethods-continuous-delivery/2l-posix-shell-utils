# Library: POSIX Shell Scripting Utilities

This repository offers fundamental POSIX-compatible shell script functions that come handy when implementing automation for local development or CI/CD agents.

## Quick Start

### Using in Dockerfile Builds

The library is designed to be easily integrated into Dockerfile builds:

```dockerfile
ARG __iwcd_pu_tag=v0.1.1
ARG __iwcd_base_url=https://raw.githubusercontent.com/ibm-webmethods-continuous-delivery/2l-posix-shell-utils/refs/tags/${__iwcd_pu_tag}
ARG __iwcd_pu_init_sh_url=${__iwcd_base_url}/code/1.init.sh
ARG __provided_assets=/opt/guardian
ARG __pu_home="${__provided_assets}/util/PU_HOME"

ENV PU_HOME="${__pu_home}"
RUN mkdir -p "${PU_HOME}/code" \
    && curl ${__iwcd_pu_init_sh_url} -o "${PU_HOME}/code/1.init.sh"

RUN chmod -R a+rx ${__provided_assets} \
    && . ${PU_HOME}/code/1.init.sh
```

### Using in Shell Scripts

```sh
# Set PU_HOME to the installation directory
export PU_HOME="/path/to/2l-posix-shell-utils"

# Source the initialization script
. "${PU_HOME}/code/1.init.sh"

# The init script will automatically:
# - Set up the audit logging system
# - Optionally download and source other modules if online mode is enabled
```

## Modules

The library consists of seven main modules:

### 1. `1.init.sh` - Initialization Module
- **Purpose**: Bootstrap the library and set up the environment
- **Features**:
  - Validates `PU_HOME` is correctly set
  - Configures work modes (online/offline, attended/unattended, debug, colored output)
  - Automatically downloads missing modules when in online mode
  - Sources the audit module (`2.audit.sh`)
  - Optionally sources ingester and common modules
- **Environment Variables**:
  - `PU_HOME` (required): Path to the library installation
  - `PU_ONLINE_MODE` (default: `true`): Enable automatic file downloads
  - `PU_ATTENDED_MODE` (default: `true`): Enable interactive prompts
  - `PU_DEBUG_MODE` (default: `true`): Enable debug logging
  - `PU_COLORED_MODE` (default: `true`): Enable colored console output
  - `PU_INIT_INGESTER` (default: `false`): Auto-source ingester module
  - `PU_INIT_COMMON` (default: `false`): Auto-source common module
  - `PU_SOURCE_TAG` (default: `main`): Git tag/branch for downloads
  - `PU_HOME_URL` (default: GitHub raw URL): Base URL for downloads

### 2. `2.audit.sh` - Audit and Logging Module
- **Purpose**: Provides structured logging with audit trail
- **Features**:
  - Multiple log levels (info, warning, error, debug)
  - Colored console output (optional)
  - Session-based log files
  - Controlled command execution with output capture
- **Functions**: `pu_log_i`, `pu_log_w`, `pu_log_e`, `pu_log_d`, `pu_controlled_exec`, `pu_log_env`, `pu_log_full_env`
- **Documentation**: [docs/audit-sh-quick-reference.md](docs/audit-sh-quick-reference.md)

### 3. `3.ingester.sh` - File Download and Caching Module
- **Purpose**: Download and cache files from remote servers
- **Features**:
  - Local file caching
  - SHA256 checksum verification
  - Offline mode support
  - Organized cache structure
- **Functions**: `pu_assure_public_file`
- **Documentation**: [docs/ingester-sh-quick-reference.md](docs/ingester-sh-quick-reference.md)

### 4. `4.common.sh` - Common Utilities Module
- **Purpose**: Miscellaneous utility functions
- **Features**:
  - Secure password/secret input from users
  - Filtered environment variable logging
  - Debug suspension for container debugging
- **Functions**: `pu_read_secret_from_user`, `pu_log_env_filtered`, `pu_debug_suspend`
- **Documentation**: [docs/common-sh-quick-reference.md](docs/common-sh-quick-reference.md)

### 5. `5.network.sh` - Network Utilities Module
- **Purpose**: Network connectivity and port checking utilities
- **Features**:
  - Port reachability testing
  - Wait for port with retry logic
  - POSIX-compatible (uses nc or /dev/tcp)
- **Functions**: `pu_port_is_reachable`, `pu_wait_for_port`

### 6. `6.string.sh` - String Manipulation Module
- **Purpose**: String encoding and manipulation utilities
- **Features**:
  - URL encoding
  - POSIX-compatible string substitution
- **Functions**: `pu_urlencode`, `pu_urlencode_pipe`, `pu_str_substitute`

### 7. `7.data.sh` - Data Format Utilities Module
- **Purpose**: Data format conversion utilities
- **Features**:
  - CSV to lines conversion
  - Lines to CSV conversion
  - YAML parsing to environment variables
- **Functions**: `pu_csv_to_lines`, `pu_lines_to_csv`, `pu_parse_yaml`, `pu_load_env_from_yaml`

## Naming Conventions

The library follows strict naming conventions for consistency and maintainability. For complete details, see [Conventions.md](Conventions.md).

### Functions
- **Public functions**: `pu_<name>` using snake_case (e.g., `pu_log_i`, `pu_audit_init_session`)
- **Private functions**: `_pu_<name>` with single underscore prefix (e.g., `_pu_init`, `_pu_init_error`)

### Variables

#### Environment Constants (External Input)
- **Pattern**: `PU_<NAME>` using UPPER_SNAKE_CASE
- **Mutability**: Read-only, must not be modified by scripts
- **Examples**: `PU_HOME`, `PU_DEBUG_MODE`, `PU_ONLINE_MODE`

#### Public Script-Managed Variables
- **Pattern**: `pu_<name>` using lower_snake_case
- **Scope**: Cross-file, visible to all functions
- **Examples**: `pu_debug_mode`, `pu_session_id`

#### File-Scoped Private Variables
- **Pattern**: `__<file_number>__<name>` (double underscore, file number, double underscore)
- **Scope**: Private to all functions within a single file
- **Examples**: `__1__online_mode`, `__2__audit_session_file`, `__3__cache_home`

#### Function-Scoped Private Variables
- **Pattern**: `__<file_number>_<function_number>_<name>`
- **Scope**: Private to a single function, must be unset before return
- **Examples**: `__1_03_source_tag`, `__3_02_full_file_folder`, `__5_02_count`

### Boolean Values
Boolean shell variables are considered to be **true** if they contain the string `"true"` in lowercase. Everything else means false.

```sh
# Correct usage
export PU_DEBUG_MODE="true"   # Enables debug mode
export PU_DEBUG_MODE="false"  # Disables debug mode
export PU_DEBUG_MODE=""        # Disables debug mode (anything except "true")
```

## Module Dependencies

Modules must be sourced in the correct order:

1. `1.init.sh` - Must be sourced first (automatically sources `2.audit.sh`)
2. `2.audit.sh` - Required by all other modules
3. `3.ingester.sh` - Optional, for file download/caching
4. `4.common.sh` - Optional, for utility functions
5. `5.network.sh` - Optional, for network utilities
6. `6.string.sh` - Optional, for string manipulation
7. `7.data.sh` - Optional, for data format conversion

The `1.init.sh` module can automatically source optional modules based on environment variables:
- `PU_INIT_INGESTER=true` - Auto-source `3.ingester.sh`
- `PU_INIT_COMMON=true` - Auto-source `4.common.sh`
- `PU_INIT_NETWORK=true` - Auto-source `5.network.sh`
- `PU_INIT_STRING=true` - Auto-source `6.string.sh`
- `PU_INIT_DATA=true` - Auto-source `7.data.sh`

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `PU_HOME` | *required* | Path to library installation |
| `PU_ONLINE_MODE` | `true` | Enable automatic file downloads |
| `PU_ATTENDED_MODE` | `true` | Enable interactive prompts |
| `PU_DEBUG_MODE` | `true` | Enable debug logging |
| `PU_COLORED_MODE` | `true` | Enable colored console output |
| `PU_INIT_INGESTER` | `false` | Auto-source ingester module (3.ingester.sh) |
| `PU_INIT_COMMON` | `false` | Auto-source common module (4.common.sh) |
| `PU_INIT_NETWORK` | `false` | Auto-source network module (5.network.sh) |
| `PU_INIT_STRING` | `false` | Auto-source string module (6.string.sh) |
| `PU_INIT_DATA` | `false` | Auto-source data module (7.data.sh) |
| `PU_SOURCE_TAG` | `main` | Git tag/branch for downloads |
| `PU_HOME_URL` | GitHub URL | Base URL for module downloads |
| `PU_AUDIT_BASE_DIR` | `/tmp/pu-default-audit` | Base directory for audit logs |
| `PU_SESSION_TIMESTAMP` | Auto-generated | Custom session identifier |
| `PU_CACHE_HOME` | `/tmp/pu-cache` | Root directory for file cache |

## Usage Examples

### Basic Logging
```sh
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Starting application"
pu_log_w "This is a warning"
pu_log_e "This is an error"
pu_log_d "Debug information"  # Only shown when PU_DEBUG_MODE=true
```

### File Download with Caching
```sh
export PU_INIT_INGESTER="true"
. "${PU_HOME}/code/1.init.sh"

# Download and cache a file
pu_assure_public_file \
    "maven" \
    "https://repo1.maven.org" \
    "maven2/org/example/artifact/1.0.0" \
    "artifact-1.0.0.jar" \
    "a1b2c3d4e5f6..."  # Optional SHA256 checksum
```

### Secure Password Input
```sh
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

pu_read_secret_from_user "database password"
db_password="${secret}"
unset secret  # Always unset immediately after use
```

## Testing

The library includes comprehensive tests for multiple platforms:

```sh
# Run all tests
cd test/containerized
./runAllTests.bat  # Windows
# or
./runAllTests.sh   # Linux/macOS

# Run tests for specific platform
cd test/containerized/alpine
docker-compose up --build
```

Supported test platforms:
- Alpine Linux
- Debian
- Red Hat UBI (Universal Base Image)

## License

Copyright IBM Corporation All Rights Reserved.  
SPDX-License-Identifier: Apache-2.0

## Contributing

When contributing to this repository:
1. Follow the established naming conventions (see [Conventions.md](Conventions.md))
2. Maintain strict POSIX compliance (no bash-isms)
3. Update documentation for any new functions
4. Add tests for new functionality
5. Ensure all tests pass on all supported platforms
6. Use proper variable scoping and cleanup (unset function-scoped variables)

### Naming Convention Quick Reference

- Environment constants: `PU_<NAME>` (UPPER_CASE, read-only)
- Public functions: `pu_<action>` (no underscore prefix)
- Private functions: `_pu_<action>` (single underscore prefix)
- File-scoped variables: `__<file>__<name>` (e.g., `__1__online_mode`)
- Function-scoped variables: `__<file>_<func>_<name>` (e.g., `__3_02_result`)
- Boolean values: `"true"` for true, anything else for false

For complete coding conventions, see [Conventions.md](Conventions.md).

**Note for AI Assistants**: Detailed AI-specific rules are in [.ai-assist/RULES.md](.ai-assist/RULES.md).
