# 3.ingester.sh Quick Reference

- [3.ingester.sh Quick Reference](#3ingestersh-quick-reference)
  - [Module Overview](#module-overview)
  - [Environment Variables](#environment-variables)
  - [System Requirements](#system-requirements)
  - [Quick Setup](#quick-setup)
    - [Alpine Linux Container](#alpine-linux-container)
    - [General Setup](#general-setup)
  - [Functions](#functions)
    - [pu\_assure\_public\_file](#pu_assure_public_file)
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
**Dependencies**: `2.audit.sh` (for logging)  
**Location**: `${PU_HOME}/code/3.ingester.sh`  
**Auto-loaded**: Only if `PU_INIT_INGESTER=true` when sourcing `1.init.sh`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PU_HOME` | *required* | Path to posix-shell-utils installation |
| `PU_CACHE_HOME` | `/tmp/pu-cache` | Root directory for file cache |
| `PU_ONLINE_MODE` | `true` | Enable downloads (string `"true"` for true) |
| `PU_DEBUG_MODE` | `true` | Enable debug logging (string `"true"` for true) |

**Note:** Boolean values use string `"true"` for true, anything else for false.

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
export PU_INIT_INGESTER="true"

# Source via init script
. "${PU_HOME}/code/1.init.sh"
```

### General Setup

```sh
# Set environment
export PU_HOME="/path/to/posix-shell-utils"
export PU_CACHE_HOME="${HOME}/.cache/pu"
export PU_INIT_INGESTER="true"

# Source via init script
. "${PU_HOME}/code/1.init.sh"

# Or source directly (after audit.sh)
. "${PU_HOME}/code/2.audit.sh"
. "${PU_HOME}/code/3.ingester.sh"
```

## Functions

### pu_assure_public_file

Downloads and caches a file from a remote server with optional checksum verification.

```sh
pu_assure_public_file SERVER_NAME BASE_URL RELATIVE_PATH FILENAME [CHECKSUM]
```

**Parameters:**
- `SERVER_NAME`: Logical server name (used in cache structure)
- `BASE_URL`: Base URL (e.g., `https://example.com`)
- `RELATIVE_PATH`: Path relative to base URL
- `FILENAME`: File name to download
- `CHECKSUM`: Optional SHA256 checksum (use `"none"` or omit to skip verification)

**Returns:**
- `0`: Success (file cached and verified)
- `1`: Offline mode - file not in cache
- `2`: Download failed (curl error)
- `3`: File not found after download
- `4`: Checksum verification failed

**Cache Location:**
```
${PU_CACHE_HOME}/${SERVER_NAME}/${RELATIVE_PATH}/${FILENAME}
```

**Behavior:**
1. Checks if file exists in cache
2. If not found and `PU_ONLINE_MODE=true`, downloads the file
3. If checksum provided, verifies SHA256
4. Returns appropriate exit code

## Usage Examples

### Basic Download

```sh
# Source the module
export PU_INIT_INGESTER="true"
. "${PU_HOME}/code/1.init.sh"

# Download file without checksum
pu_assure_public_file "myserver" "https://example.com" "files" "document.pdf"

# File is now cached at:
# ${PU_CACHE_HOME}/myserver/files/document.pdf
```

### Download with Checksum

```sh
# Download with SHA256 verification
pu_assure_public_file \
    "releases" \
    "https://github.com/owner/repo/releases/download/v1.0.0" \
    "" \
    "release.tar.gz" \
    "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"

# If checksum doesn't match, function returns 4
```

### Maven Repository

```sh
# Download from Maven Central
pu_assure_public_file \
    "maven" \
    "https://repo1.maven.org" \
    "maven2/org/apache/commons/commons-lang3/3.12.0" \
    "commons-lang3-3.12.0.jar" \
    "d919d904486c0c93d4bb7e87f53d0e1c6f5b8e2e7b9c8d7e6f5a4b3c2d1e0f9"

# File cached at:
# ${PU_CACHE_HOME}/maven/maven2/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.jar
```

### Error Handling

```sh
# Handle specific errors
if pu_assure_public_file "server" "https://example.com" "path" "file.txt"; then
    pu_log_i "File ready: ${PU_CACHE_HOME}/server/path/file.txt"
else
    case $? in
        1) pu_log_e "Offline mode - file not cached" ;;
        2) pu_log_e "Download failed - check network" ;;
        3) pu_log_e "File not found after download" ;;
        4) pu_log_e "Checksum verification failed" ;;
    esac
    exit 1
fi
```

### Offline Mode

```sh
# Enable offline mode
export PU_ONLINE_MODE="false"
export PU_INIT_INGESTER="true"
. "${PU_HOME}/code/1.init.sh"

# Check if file exists in cache
if pu_assure_public_file "server" "https://example.com" "path" "file.txt"; then
    pu_log_i "File found in cache"
else
    pu_log_w "File not cached, download would be needed"
fi
```


## Troubleshooting

### Enable Debug Mode

```sh
export PU_DEBUG_MODE="true"
export PU_INIT_INGESTER="true"
. "${PU_HOME}/code/1.init.sh"

# Now you'll see detailed debug messages:
# - File found in cache
# - Creating directories
# - Download URLs
# - Checksum verification steps
```

### Check Cache

```sh
# List cached files
find "${PU_CACHE_HOME}" -type f -ls

# Check specific file
ls -la "${PU_CACHE_HOME}/server/path/file.txt"

# Check cache size
du -sh "${PU_CACHE_HOME}"
```

### Verify Checksum

```sh
# Calculate checksum manually
sha256sum "${PU_CACHE_HOME}/server/path/file.txt"

# Compare with expected
expected="a1b2c3d4..."
actual=$(sha256sum "${PU_CACHE_HOME}/server/path/file.txt" | awk '{print $1}')
if [ "${actual}" = "${expected}" ]; then
    echo "Checksum matches"
else
    echo "Checksum mismatch!"
fi
```

### Test URL

```sh
# Test download manually
curl -f -L -I "https://example.com/path/file.txt"

# Test with verbose output
curl -v -L "https://example.com/path/file.txt" -o /tmp/test.txt

# Check if URL is accessible
if curl -f -s -I "https://example.com/path/file.txt" > /dev/null; then
    echo "URL is accessible"
else
    echo "URL is not accessible"
fi
```

### Clear Cache

```sh
# Clear entire cache
rm -rf "${PU_CACHE_HOME}"

# Clear specific server cache
rm -rf "${PU_CACHE_HOME}/server_alias"

# Clear old cache entries (older than 30 days)
find "${PU_CACHE_HOME}" -type f -mtime +30 -delete
```

## Best Practices

1. **Always use checksums for critical files**
   ```sh
   # Good - with checksum
   pu_assure_public_file "releases" "https://..." "path" "app.jar" "${checksum}"
   
   # Acceptable - without checksum for non-critical files
   pu_assure_public_file "docs" "https://..." "path" "readme.txt"
   ```

2. **Set meaningful server names for cache organization**
   ```sh
   # Good - descriptive names
   pu_assure_public_file "maven-central" "https://repo1.maven.org" ...
   pu_assure_public_file "github-releases" "https://github.com/..." ...
   
   # Bad - generic names
   pu_assure_public_file "server1" "https://..." ...
   ```

3. **Handle offline mode gracefully**
   ```sh
   if [ "${PU_ONLINE_MODE}" != "true" ]; then
       pu_log_w "Running in offline mode, ensure files are cached"
   fi
   ```

4. **Check return codes for proper error handling**
   ```sh
   if ! pu_assure_public_file "server" "url" "path" "file"; then
       pu_log_e "Failed to obtain file, cannot continue"
       exit 1
   fi
   ```

5. **Use consistent cache locations across scripts**
   ```sh
   # Set once in environment or config
   export PU_CACHE_HOME="/var/cache/myapp/pu"
   ```

6. **Clean up cache periodically to save space**
   ```sh
   # In maintenance scripts
   find "${PU_CACHE_HOME}" -type f -mtime +90 -delete
   ```

7. **Prefer ephemeral CI/CD agents**
   - Fresh cache on each run
   - No stale files
   - Predictable behavior

8. **Store checksums in version control**
   ```sh
   # checksums.txt
   a1b2c3d4... commons-lang3-3.12.0.jar
   e5f6g7h8... guava-31.1-jre.jar
   
   # In script
   checksum=$(grep "commons-lang3" checksums.txt | awk '{print $1}')
   pu_assure_public_file "maven" "..." "..." "commons-lang3-3.12.0.jar" "${checksum}"
   ```

9. **Use environment-specific cache directories**
   ```sh
   # Development
   export PU_CACHE_HOME="${HOME}/.cache/pu"
   
   # CI/CD
   export PU_CACHE_HOME="/tmp/ci-cache/pu"
   
   # Production
   export PU_CACHE_HOME="/var/cache/app/pu"
   ```

10. **Log cache hits and misses for monitoring**
    ```sh
    # The module already logs this when PU_DEBUG_MODE=true
    export PU_DEBUG_MODE="true"
    ```

## Error Codes Reference

| Code | Meaning | Recovery |
|------|---------|----------|
| 0 | File cached successfully | Continue with cached file |
| 1 | Offline mode, file not cached | Enable online mode or pre-cache file |
| 2 | Download failed (network/404) | Check URL, network, retry |
| 3 | Cache directory creation failed | Check permissions, disk space |
| 4 | Checksum verification failed | Verify checksum, re-download, check file integrity |

**Common Causes:**

**Error 1 (Offline mode):**
- `PU_ONLINE_MODE` is not `"true"`
- File not pre-cached
- Solution: Set `PU_ONLINE_MODE="true"` or pre-cache files

**Error 2 (Download failed):**
- No internet connection
- URL is incorrect or file moved
- Server is down
- Firewall blocking access
- Solution: Check connectivity, verify URL, check firewall rules

**Error 3 (Directory creation failed):**
- Insufficient permissions
- Disk full
- Invalid path
- Solution: Check permissions, free disk space, verify path

**Error 4 (Checksum mismatch):**
- File corrupted during download
- Wrong checksum provided
- File changed on server
- Solution: Verify checksum is correct, re-download, check file source
