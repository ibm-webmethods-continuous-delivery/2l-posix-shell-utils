# 1.init.sh Quick Reference

- [1.init.sh Quick Reference](#1initsh-quick-reference)
  - [Module Overview](#module-overview)
  - [Environment Variables](#environment-variables)
  - [Quick Setup](#quick-setup)
    - [In Dockerfile](#in-dockerfile)
    - [In Shell Scripts](#in-shell-scripts)
  - [Functions](#functions)
    - [pu\_init\_hunt\_for\_pu\_file](#pu_init_hunt_for_pu_file)
  - [Work Modes](#work-modes)
    - [Online vs Offline Mode](#online-vs-offline-mode)
    - [Attended vs Unattended Mode](#attended-vs-unattended-mode)
    - [Debug Mode](#debug-mode)
    - [Colored Output Mode](#colored-output-mode)
  - [Automatic Module Loading](#automatic-module-loading)
  - [Usage Examples](#usage-examples)
    - [Basic Initialization](#basic-initialization)
    - [Dockerfile Integration](#dockerfile-integration)
    - [Offline Mode](#offline-mode)
    - [With All Modules](#with-all-modules)
    - [Custom Download Source](#custom-download-source)
  - [Troubleshooting](#troubleshooting)
    - [PU\_HOME Not Set](#pu_home-not-set)
    - [Download Failures](#download-failures)
    - [Module Not Found](#module-not-found)
  - [Best Practices](#best-practices)

## Module Overview

**Purpose**: Bootstrap the POSIX Shell Utils library and initialize the environment  
**Location**: `${PU_HOME}/code/1.init.sh`  
**Auto-loads**: `2.audit.sh` (always), `3.ingester.sh` (optional), `4.common.sh` (optional)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PU_HOME` | *required* | Path to library installation directory |
| `PU_ONLINE_MODE` | `true` | Enable automatic file downloads |
| `PU_ATTENDED_MODE` | `true` | Enable interactive user prompts |
| `PU_DEBUG_MODE` | `true` | Enable debug logging |
| `PU_COLORED_MODE` | `true` | Enable colored console output |
| `PU_INIT_INGESTER` | `false` | Auto-source ingester module |
| `PU_INIT_COMMON` | `false` | Auto-source common module |
| `PU_SOURCE_TAG` | `main` | Git tag/branch for downloads |
| `PU_HOME_URL` | GitHub URL | Base URL for module downloads |

## Quick Setup

### In Dockerfile

```dockerfile
ARG __iwcd_pu_tag=v0.0.3
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

### In Shell Scripts

```sh
# Set PU_HOME
export PU_HOME="/path/to/2l-posix-shell-utils"

# Source the init script
. "${PU_HOME}/code/1.init.sh"

# Now you can use all loaded modules
pu_log_i "Library initialized successfully"
```

## Functions

### pu_init_hunt_for_pu_file

Downloads a missing library file when in online mode.

```sh
pu_init_hunt_for_pu_file RELATIVE_PATH FILENAME
```

**Parameters:**
- `RELATIVE_PATH`: Path relative to `PU_HOME` (e.g., `code`)
- `FILENAME`: Name of the file to download (e.g., `2.audit.sh`)

**Returns:**
- `0`: Success (file exists or downloaded)
- `1`: Offline mode - file not found
- `2`: Download failed

**Example:**
```sh
# Ensure a module is available
if ! pu_init_hunt_for_pu_file "code" "3.ingester.sh"; then
    echo "Failed to obtain ingester module"
    exit 1
fi
```

## Work Modes

### Online vs Offline Mode

**Online Mode** (`PU_ONLINE_MODE=true`):
- Automatically downloads missing modules
- Useful for CI/CD environments with internet access
- Default behavior

**Offline Mode** (`PU_ONLINE_MODE=false`):
- Requires all modules to be pre-installed
- Fails if required files are missing
- Useful for air-gapped environments

```sh
# Enable offline mode
export PU_ONLINE_MODE="false"
. "${PU_HOME}/code/1.init.sh"
```

### Attended vs Unattended Mode

**Attended Mode** (`PU_ATTENDED_MODE=true`):
- Allows interactive prompts
- Suitable for manual script execution
- Default behavior

**Unattended Mode** (`PU_ATTENDED_MODE=false`):
- No interactive prompts
- Suitable for automated CI/CD pipelines
- Scripts should handle all inputs via environment variables

```sh
# Enable unattended mode for CI/CD
export PU_ATTENDED_MODE="false"
. "${PU_HOME}/code/1.init.sh"
```

### Debug Mode

**Debug Mode** (`PU_DEBUG_MODE=true`):
- Enables `pu_log_d` debug messages
- Shows detailed execution information
- Default: enabled

```sh
# Disable debug mode for production
export PU_DEBUG_MODE="false"
. "${PU_HOME}/code/1.init.sh"
```

### Colored Output Mode

**Colored Mode** (`PU_COLORED_MODE=true`):
- Uses ANSI color codes for log messages
- Improves readability in terminals
- Default: enabled

```sh
# Disable colors for log file redirection
export PU_COLORED_MODE="false"
. "${PU_HOME}/code/1.init.sh"
```

## Automatic Module Loading

The init script can automatically load optional modules:

```sh
# Load all modules
export PU_INIT_INGESTER="true"
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

# Now you can use functions from all modules
pu_assure_public_file "server" "https://example.com" "path" "file.txt"
pu_read_secret_from_user "password"
```

**Modules loaded:**
1. `2.audit.sh` - Always loaded automatically
2. `3.ingester.sh` - Loaded if `PU_INIT_INGESTER=true`
3. `4.common.sh` - Loaded if `PU_INIT_COMMON=true`

## Usage Examples

### Basic Initialization

```sh
#!/bin/sh
export PU_HOME="/opt/posix-utils"
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Script started"
# Your code here
pu_log_i "Script completed"
```

### Dockerfile Integration

```dockerfile
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache curl

# Set up PU library
ARG PU_TAG=v0.0.3
ENV PU_HOME=/opt/pu
RUN mkdir -p ${PU_HOME}/code && \
    curl -sL https://raw.githubusercontent.com/ibm-webmethods-continuous-delivery/2l-posix-shell-utils/refs/tags/${PU_TAG}/code/1.init.sh \
    -o ${PU_HOME}/code/1.init.sh

# Initialize in your entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**entrypoint.sh:**
```sh
#!/bin/sh
. ${PU_HOME}/code/1.init.sh
pu_log_i "Container started"
exec "$@"
```

### Offline Mode

```sh
#!/bin/sh
# Pre-install all modules, then use offline mode
export PU_HOME="/opt/posix-utils"
export PU_ONLINE_MODE="false"
export PU_INIT_INGESTER="true"
export PU_INIT_COMMON="true"

. "${PU_HOME}/code/1.init.sh"
```

### With All Modules

```sh
#!/bin/sh
export PU_HOME="/opt/posix-utils"
export PU_INIT_INGESTER="true"
export PU_INIT_COMMON="true"
export PU_DEBUG_MODE="true"

. "${PU_HOME}/code/1.init.sh"

# Use audit functions
pu_log_i "Starting process"

# Use ingester functions
pu_assure_public_file "maven" "https://repo1.maven.org" \
    "maven2/org/example/lib/1.0" "lib-1.0.jar"

# Use common functions
pu_read_secret_from_user "API key"
api_key="${secret}"
unset secret
```

### Custom Download Source

```sh
#!/bin/sh
export PU_HOME="/opt/posix-utils"
export PU_SOURCE_TAG="v0.0.4"
export PU_HOME_URL="https://my-mirror.example.com/posix-utils"

. "${PU_HOME}/code/1.init.sh"
```

## Troubleshooting

### PU_HOME Not Set

**Error:** `PU1|ERROR: 04|/code/1.init.sh file not found!`

**Solution:**
```sh
# Ensure PU_HOME is set before sourcing
export PU_HOME="/correct/path/to/library"
. "${PU_HOME}/code/1.init.sh"
```

### Download Failures

**Error:** `PU1|ERROR: 03|curl failed, code 6`

**Causes:**
- No internet connection
- Incorrect URL
- Firewall blocking access

**Solutions:**
```sh
# 1. Check internet connectivity
curl -I https://github.com

# 2. Use offline mode with pre-installed modules
export PU_ONLINE_MODE="false"

# 3. Use a custom mirror
export PU_HOME_URL="https://your-mirror.example.com"
```

### Module Not Found

**Error:** `FATAL: source the file 2.audit.sh first`

**Cause:** Trying to use a module before initialization

**Solution:**
```sh
# Always source 1.init.sh first
. "${PU_HOME}/code/1.init.sh"

# Then use any module functions
pu_log_i "Now it works"
```

## Best Practices

1. **Always set PU_HOME** before sourcing the init script
2. **Use online mode in CI/CD** for automatic module downloads
3. **Use offline mode in production** for predictable behavior
4. **Enable debug mode during development** for troubleshooting
5. **Disable colored output** when redirecting to log files
6. **Use unattended mode in automation** to prevent hanging on prompts
7. **Pin to specific tags** in production (e.g., `PU_SOURCE_TAG=v0.0.3`)
8. **Pre-download modules** for air-gapped environments
9. **Check return codes** when using `pu_init_hunt_for_pu_file`
10. **Document required modules** in your script headers