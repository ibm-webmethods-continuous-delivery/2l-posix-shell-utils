# 2.audit.sh Quick Reference

- [2.audit.sh Quick Reference](#2auditsh-quick-reference)
  - [Module Overview](#module-overview)
  - [Environment Variables](#environment-variables)
  - [Quick Start](#quick-start)
  - [Functions](#functions)
    - [pu\_audit\_init\_session](#pu_audit_init_session)
    - [pu\_log\_i](#pu_log_i)
    - [pu\_log\_w](#pu_log_w)
    - [pu\_log\_e](#pu_log_e)
    - [pu\_log\_d](#pu_log_d)
    - [pu\_controlled\_exec](#pu_controlled_exec)
    - [pu\_log\_env](#pu_log_env)
    - [pu\_log\_full\_env](#pu_log_full_env)
  - [Log Format](#log-format)
  - [File Structure](#file-structure)
  - [Usage Examples](#usage-examples)
    - [Basic Logging](#basic-logging)
    - [Controlled Command Execution](#controlled-command-execution)
    - [Environment Logging](#environment-logging)
    - [Custom Session Directory](#custom-session-directory)
  - [Color Codes](#color-codes)
  - [Best Practices](#best-practices)

## Module Overview

**Purpose**: Structured logging with audit trail for shell scripts  
**Dependencies**: `1.init.sh` (must be sourced first)  
**Location**: `${PU_HOME}/code/2.audit.sh`  
**Auto-loaded**: Yes, by `1.init.sh`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PU_AUDIT_BASE_DIR` | `/tmp/pu-default-audit` | Base directory for audit logs |
| `PU_SESSION_TIMESTAMP` | Auto-generated | Custom session identifier (format: `YY-MM-DDTHH.MM.SS`) |
| `PU_DEBUG_MODE` | `true` | Enable debug logging |
| `PU_COLORED_MODE` | `true` | Enable colored console output |

**Note:** Boolean values use string `"true"` for true, anything else for false.

## Quick Start

```sh
# Source via init script (recommended)
export PU_HOME="/path/to/2l-posix-shell-utils"
. "${PU_HOME}/code/1.init.sh"

# Basic logging
pu_log_i "Info message"
pu_log_w "Warning message"
pu_log_e "Error message"
pu_log_d "Debug message"  # Only when PU_DEBUG_MODE=true
```

## Functions

### pu_audit_init_session

Initializes the audit session with directory structure and settings.

**Called automatically** when the module is sourced.

**Creates:**
- Session directory: `${PU_AUDIT_BASE_DIR}/${PU_SESSION_TIMESTAMP}/`
- Session log file: `${PU_AUDIT_BASE_DIR}/${PU_SESSION_TIMESTAMP}/session.log`

**Logs:**
- Session initialization timestamp
- Effective environment variables
- Configuration settings

### pu_log_i

Log informational messages.

```sh
pu_log_i MESSAGE
```

**Parameters:**
- `MESSAGE`: The message to log

**Output:**
- Console: `HHMMSS I|MESSAGE` (stderr)
- File: `HHMMSS I|MESSAGE` (session.log)

**Example:**
```sh
pu_log_i "Application started successfully"
pu_log_i "Processing file: ${filename}"
```

### pu_log_w

Log warning messages with yellow color (if colored mode enabled).

```sh
pu_log_w MESSAGE
```

**Parameters:**
- `MESSAGE`: The warning message to log

**Output:**
- Console: `HHMMSS W|MESSAGE` (stderr, yellow if colored)
- File: `HHMMSS W|MESSAGE` (session.log)

**Example:**
```sh
pu_log_w "Configuration file not found, using defaults"
pu_log_w "Deprecated function called"
```

### pu_log_e

Log error messages with red color (if colored mode enabled).

```sh
pu_log_e MESSAGE
```

**Parameters:**
- `MESSAGE`: The error message to log

**Output:**
- Console: `HHMMSS E|MESSAGE` (stderr, red if colored)
- File: `HHMMSS E|MESSAGE` (session.log)

**Example:**
```sh
pu_log_e "Failed to connect to database"
pu_log_e "Invalid configuration: ${error_detail}"
```

### pu_log_d

Log debug messages with cyan color (if colored mode enabled).

**Only logs when `PU_DEBUG_MODE=true`**

```sh
pu_log_d MESSAGE
```

**Parameters:**
- `MESSAGE`: The debug message to log

**Output:**
- Console: `HHMMSS D|MESSAGE` (stderr, cyan if colored)
- File: `HHMMSS D|MESSAGE` (session.log)

**Example:**
```sh
pu_log_d "Variable value: ${my_var}"
pu_log_d "Entering function: process_data"
```

### pu_controlled_exec

Execute a command with controlled output redirection to audit files.

```sh
pu_controlled_exec COMMAND TAG
```

**Parameters:**
- `COMMAND`: The command to execute
- `TAG`: Tag for naming the output files

**Creates:**
- `${PU_AUDIT_BASE_DIR}/${PU_SESSION_TIMESTAMP}/cExec_${EPOCH}_${TAG}.out` - stdout
- `${PU_AUDIT_BASE_DIR}/${PU_SESSION_TIMESTAMP}/cExec_${EPOCH}_${TAG}.err` - stderr

**Returns:** Exit code of the executed command

**Example:**
```sh
pu_controlled_exec "ls -la /tmp" "list_tmp"
pu_controlled_exec "make build" "build_process"

# Check result
if pu_controlled_exec "npm test" "unit_tests"; then
    pu_log_i "Tests passed"
else
    pu_log_e "Tests failed"
fi
```

### pu_log_env

Display and log PU-prefixed environment variables.

```sh
pu_log_env
```

**Shows:**
- `PU_*` public constants (excluding passwords)
- `__PU_*` private constants (excluding passwords)
- `pu_*` public variables (excluding passwords)
- `__pu_*` private variables (excluding passwords)

**Output:**
- Console: Sorted list of variables (stderr)
- File: Same list (session.log)

**Example:**
```sh
pu_log_env
# Output:
# PU_HOME=/opt/posix-utils
# PU_DEBUG_MODE=true
# __pu_audit_session_dir=/tmp/pu-default-audit/26-01-12T18.00.00
# ...
```

### pu_log_full_env

Display all environment variables (console) and log PU variables (file).

**Only active when `PU_DEBUG_MODE=true`**

**⚠️ DO NOT USE in production code!** May expose sensitive information.

```sh
pu_log_full_env
```

**Output:**
- Console: All environment variables sorted (stderr)
- File: Only PU-prefixed variables (session.log)

## Log Format

All log messages follow this format:

```
YYMDDTHHMMSS<LEVEL>|<MESSAGE>
```

**Components:**
- `YYMDDTHHMMSS`: Timestamp with year, hex month, day, time
  - `YY`: Year (2 digits, e.g., `26` for 2026)
  - `M`: Month in hexadecimal (1=Jan, 2=Feb, ..., 9=Sep, A=Oct, B=Nov, C=Dec)
  - `DD`: Day of month (01-31)
  - `T`: Separator
  - `HH`: Hours (00-23)
  - `MM`: Minutes (00-59)
  - `SS`: Seconds (00-59)
  - Example: `26112T183045` = January 12, 2026 at 18:30:45
- `<LEVEL>`: Log level indicator
  - `I` = Info
  - `W` = Warning
  - `E` = Error
  - `D` = Debug
- `|`: Separator
- `<MESSAGE>`: The log message

**Example:**
```
26112T183045I|Application started
26112T183046W|Configuration file not found
26112T183047E|Database connection failed
26112T183048D|Variable value: test123
```

**Note:** The hex month format (1-C) keeps the timestamp compact while including full date information for audit purposes.

## File Structure

```
${PU_AUDIT_BASE_DIR}/
└── ${PU_SESSION_TIMESTAMP}/
    ├── session.log                    # Main session log
    ├── cExec_1234567890_tag1.out     # Command stdout
    ├── cExec_1234567890_tag1.err     # Command stderr
    ├── cExec_1234567891_tag2.out
    └── cExec_1234567891_tag2.err
```

**Default locations:**
- Base directory: `/tmp/pu-default-audit`
- Session directory: `/tmp/pu-default-audit/26-01-12T18.00.00/`
- Session log: `/tmp/pu-default-audit/26-01-12T18.00.00/session.log`

## Usage Examples

### Basic Logging

```sh
#!/bin/sh
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Script started"
pu_log_i "Processing ${file_count} files"

if [ ! -f "${config_file}" ]; then
    pu_log_w "Config file not found: ${config_file}"
fi

if ! process_data; then
    pu_log_e "Data processing failed"
    exit 1
fi

pu_log_i "Script completed successfully"
```

### Controlled Command Execution

```sh
#!/bin/sh
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Building application"
if pu_controlled_exec "make clean && make build" "build"; then
    pu_log_i "Build successful"
else
    pu_log_e "Build failed, check logs"
    exit 1
fi

pu_log_i "Running tests"
pu_controlled_exec "make test" "tests"
```

### Environment Logging

```sh
#!/bin/sh
export PU_DEBUG_MODE="true"
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Logging environment variables"
pu_log_env

# For debugging only
if [ "${DEBUG_FULL}" = "true" ]; then
    pu_log_full_env
fi
```

### Custom Session Directory

```sh
#!/bin/sh
export PU_AUDIT_BASE_DIR="/var/log/myapp/audit"
export PU_SESSION_TIMESTAMP="deployment-$(date +%Y%m%d-%H%M%S)"
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Custom audit session started"
# Logs will be in: /var/log/myapp/audit/deployment-20260112-180000/
```

## Color Codes

When `PU_COLORED_MODE=true`, the following ANSI colors are used:

| Level | Color | Code |
|-------|-------|------|
| Info | Default | (no color) |
| Warning | Yellow | `\033[0;33m` |
| Error | Red | `\033[0;31m` |
| Debug | Cyan | `\033[0;36m` |

**Disable colors for:**
- Log file redirection
- Non-interactive terminals
- Systems without ANSI support

```sh
export PU_COLORED_MODE="false"
. "${PU_HOME}/code/1.init.sh"
```

## Best Practices

1. **Always use appropriate log levels**
   - `pu_log_i` for normal operations
   - `pu_log_w` for recoverable issues
   - `pu_log_e` for errors requiring attention
   - `pu_log_d` for debugging information

2. **Include context in messages**
   ```sh
   pu_log_i "Processing file: ${filename}"
   pu_log_e "Failed to connect to ${host}:${port}"
   ```

3. **Use controlled execution for important commands**
   ```sh
   pu_controlled_exec "critical_command" "descriptive_tag"
   ```

4. **Disable debug mode in production**
   ```sh
   export PU_DEBUG_MODE="false"
   ```

5. **Use custom session timestamps for clarity**
   ```sh
   export PU_SESSION_TIMESTAMP="backup-$(date +%Y%m%d)"
   ```

6. **Check audit logs after failures**
   ```sh
   cat "${PU_AUDIT_BASE_DIR}/${PU_SESSION_TIMESTAMP}/session.log"
   ```

7. **Clean up old audit logs periodically**
   ```sh
   find "${PU_AUDIT_BASE_DIR}" -type d -mtime +30 -exec rm -rf {} \;
   ```

8. **Never log sensitive information**
   - Passwords, tokens, keys should never be logged
   - Use `pu_log_env` instead of `pu_log_full_env` in production

9. **Disable colors when redirecting to files**
   ```sh
   export PU_COLORED_MODE="false"
   ./script.sh 2>&1 | tee output.log
   ```

10. **Set appropriate audit directory permissions**
    ```sh
    mkdir -p "${PU_AUDIT_BASE_DIR}"
    chmod 750 "${PU_AUDIT_BASE_DIR}"
