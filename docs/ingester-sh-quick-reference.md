# ingester.sh Quick Reference

- [ingester.sh Quick Reference](#ingestersh-quick-reference)
  - [Module Overview](#module-overview)
  - [Environment Variables](#environment-variables)
  - [System Requirements](#system-requirements)
  - [Quick Setup](#quick-setup)
    - [Alpine Linux Container](#alpine-linux-container)
    - [General Setup](#general-setup)
  - [Functions](#functions)
    - [pu\_assurePublicFile](#pu_assurepublicfile)
  - [Usage Examples](#usage-examples)
    - [Basic Download](#basic-download)
    - [Download with Checksum](#download-with-checksum)
    - [Maven Repository](#maven-repository)
    - [Error Handling](#error-handling)
    - [Offline Mode](#offline-mode)
  - [Troubleshooting](#troubleshooting)
    - [Enable Debug Mode](#enable-debug-mode)
    - [Check Cache](#check-cache)
    - [Verify Checksum](#verify-checksum)
    - [Test URL](#test-url)
    - [Clear Cache](#clear-cache)
  - [Best Practices](#best-practices)
  - [Error Codes Reference](#error-codes-reference)


## Module Overview

**Purpose**: File caching and download functionality for POSIX shell scripts  
**Dependencies**: `audit.sh` (for logging)  
**Location**: `${PU_HOME}/code/ingester.sh`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PU_HOME` | *required* | Path to posix-shell-utils installation |
| `PU_CACHE_HOME` | `/tmp/pu-cache` | Root directory for file cache |
| `PU_ONLINE_MODE` | `Y` | Enable (`Y`) or disable (`N`) downloads |
| `PU_DEBUG_ON` | `N` | Enable debug logging |

## System Requirements

**Linux/Alpine**: `curl`, `coreutils` (for `sha256sum`)  
**macOS**: `curl`, `coreutils` (or use built-in `shasum`)  
**Commands**: `mkdir`, `dirname`, `basename`, `test`

## Quick Setup

### Alpine Linux Container
```sh
# Install dependencies
apk add --no-cache curl coreutils

# Set environment
export PU_HOME="/workspaces/2l-posix-shell-utils"
export PU_CACHE_HOME="/tmp/pu-cache"
```

### General Setup
```sh
# Set environment
export PU_HOME="/path/to/posix-shell-utils"
export PU_CACHE_HOME="${HOME}/.cache/pu"

# Source module
. "${PU_HOME}/code/ingester.sh"
```

## Functions

### pu_assurePublicFile

Downloads and caches a file from a remote server with optional checksum verification.

```sh
pu_assurePublicFile SERVER_NAME BASE_URL RELATIVE_PATH FILENAME [CHECKSUM]
```

**Parameters:**
- `SERVER_NAME`: Logical server name (used in cache structure)
- `BASE_URL`: Base URL (e.g., `https://example.com`)
- `RELATIVE_PATH`: Path relative to base URL
- `FILENAME`: File name to download
- `CHECKSUM`: Optional SHA256 checksum

**Returns:**
- `0`: Success
- `1`: Offline mode - file not in cache
- `2`: Download failed
- `3`: Cache directory creation failed
- `4`: Checksum verification failed

**Cache Location:**
```
${PU_CACHE_HOME}/${SERVER_NAME}/${RELATIVE_PATH}/${FILENAME}
```

## Usage Examples

### Basic Download
```sh
# Source the module
. "${PU_HOME}/code/ingester.sh"

# Download file without checksum
pu_assurePublicFile "myserver" "https://example.com" "files" "document.pdf"
```

### Download with Checksum
```sh
# Download with SHA256 verification
pu_assurePublicFile \
    "releases" \
    "https://github.com/owner/repo/releases/download/v1.0.0" \
    "" \
    "release.tar.gz" \
    "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
```

### Maven Repository
```sh
# Download from Maven Central
pu_assurePublicFile \
    "maven" \
    "https://repo1.maven.org" \
    "maven2/org/apache/commons/commons-lang3/3.12.0" \
    "commons-lang3-3.12.0.jar" \
    "d919d904486c0c93d4bb7e87f53d0e1c6f5b8e2e7b9c8d7e6f5a4b3c2d1e0f9"
```

### Error Handling
```sh
# Handle specific errors
pu_assurePublicFile "server" "https://example.com" "path" "file.txt"
case $? in
    0) echo "Success" ;;
    1) echo "Offline mode - file not cached" ;;
    2) echo "Download failed" ;;
    4) echo "Checksum verification failed" ;;
esac
```

### Offline Mode
```sh
# Enable offline mode
export PU_ONLINE_MODE=N

# Check if file exists in cache
if pu_assurePublicFile "server" "https://example.com" "path" "file.txt"; then
    echo "File found in cache"
else
    echo "File not cached, download would be needed"
fi
```


## Troubleshooting

### Enable Debug Mode
```sh
export PU_DEBUG_ON=Y
```

### Check Cache
```sh
# List cached files
find "${PU_CACHE_HOME}" -type f -ls

# Check specific file
ls -la "${PU_CACHE_HOME}/server/path/file.txt"
```

### Verify Checksum
```sh
# Calculate checksum
sha256sum "${PU_CACHE_HOME}/server/path/file.txt"
```

### Test URL
```sh
# Test download manually
curl -f -L -I "https://example.com/path/file.txt"
```

### Clear Cache
```sh
# Clear entire cache
rm -rf "${PU_CACHE_HOME}"

# Clear specific server cache
rm -rf "${PU_CACHE_HOME}/server_alias"
```

## Best Practices

1. **Always use checksums** for critical files
2. **Set meaningful server names** for cache organization
3. **Handle offline mode** gracefully
4. **Check return codes** for proper error handling
5. **Use consistent cache locations** across scripts
6. **Clean up cache** periodically to save space
7. Prefer **ephemeral CI/CD agents**

## Error Codes Reference

| Code | Meaning | Recovery |
|------|---------|----------|
| 0 | File cached successfully | Continue |
| 1 | Offline mode, file not cached | Enable online mode |
| 2 | Download failed (network/404) | Check URL, retry |
| 3 | Cache directory creation failed | Check permissions |
| 4 | Checksum verification failed | Verify checksum, re-download |
