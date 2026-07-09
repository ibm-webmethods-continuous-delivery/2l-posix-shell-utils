# Network Utilities Quick Reference (5.network.sh)

This module provides network connectivity and port checking utilities for POSIX-compatible shell scripts.

## Prerequisites

Before using this module, you must source the initialization and audit modules:

```sh
export PU_HOME="/path/to/2l-posix-shell-utils"
export PU_INIT_NETWORK="true"  # Auto-load network module
. "${PU_HOME}/code/1.init.sh"
```

Or manually source after initialization:

```sh
. "${PU_HOME}/code/1.init.sh"
. "${PU_HOME}/code/5.network.sh"
```

## Functions

### pu_port_is_reachable

Check if a specific port is reachable on a given host.

**Signature:**
```sh
pu_port_is_reachable <hostname> <port>
```

**Parameters:**
- `$1` - hostname or IP address
- `$2` - port number

**Returns:**
- `0` - Port is reachable
- `1` - Port is not reachable
- `2` - Missing required arguments

**Implementation Notes:**
- Uses `nc` (netcat) if available (e.g., Alpine Linux)
- Falls back to `/dev/tcp` if `nc` is not available (e.g., bash on CentOS/RHEL)
- POSIX-compatible approach for maximum portability

**Example:**
```sh
if pu_port_is_reachable "localhost" "8080"; then
  pu_log_i "Port 8080 is open"
else
  pu_log_e "Port 8080 is not reachable"
fi
```

**Example with database:**
```sh
if pu_port_is_reachable "database.example.com" "5432"; then
  pu_log_i "PostgreSQL database is reachable"
  # Proceed with database operations
else
  pu_log_e "Cannot reach database"
  exit 1
fi
```

---

### pu_wait_for_port

Wait for a port to become reachable on a host with configurable retry logic. Useful for waiting for services to start up in containerized environments or during system initialization.

**Signature:**
```sh
pu_wait_for_port <hostname> <port> [max_retries] [sleep_seconds]
```

**Parameters:**
- `$1` - hostname or IP address
- `$2` - port number
- `$3` - OPTIONAL: maximum number of retries (default: 30)
- `$4` - OPTIONAL: sleep time between retries in seconds (default: 5)

**Returns:**
- `0` - Port became reachable within retry limit
- `1` - Port is not reachable after maximum retries
- `2` - Missing required arguments

**Default Behavior:**
- Maximum retries: 30
- Sleep interval: 5 seconds
- Total wait time: up to 150 seconds (2.5 minutes)

**Example - Basic usage:**
```sh
# Wait up to 2.5 minutes (30 retries × 5 seconds)
if pu_wait_for_port "localhost" "8080"; then
  pu_log_i "Service is ready"
else
  pu_log_e "Service failed to start"
  exit 1
fi
```

**Example - Custom timeout:**
```sh
# Wait up to 2 minutes (24 retries × 5 seconds)
if pu_wait_for_port "database" "5432" 24 5; then
  pu_log_i "Database is ready"
else
  pu_log_e "Database failed to start within 2 minutes"
  exit 1
fi
```

**Example - Quick check:**
```sh
# Wait up to 30 seconds (10 retries × 3 seconds)
if pu_wait_for_port "api-server" "3000" 10 3; then
  pu_log_i "API server is ready"
else
  pu_log_w "API server not ready, continuing anyway"
fi
```

**Example - Docker Compose service dependency:**
```sh
#!/bin/sh
# Wait for dependent services before starting main application

pu_log_i "Waiting for database..."
pu_wait_for_port "postgres" "5432" 30 2 || exit 1

pu_log_i "Waiting for Redis..."
pu_wait_for_port "redis" "6379" 30 2 || exit 1

pu_log_i "All dependencies ready, starting application..."
exec /app/start.sh
```

## Use Cases

### 1. Service Health Checks

```sh
# Check if multiple services are running
services="web:80 api:8080 db:5432"

for service in ${services}; do
  host=$(echo ${service} | cut -d: -f1)
  port=$(echo ${service} | cut -d: -f2)
  
  if pu_port_is_reachable "${host}" "${port}"; then
    pu_log_i "✓ ${host}:${port} is healthy"
  else
    pu_log_e "✗ ${host}:${port} is down"
  fi
done
```

### 2. Container Startup Orchestration

```sh
# Wait for database before running migrations
pu_log_i "Waiting for database to be ready..."
if pu_wait_for_port "${DB_HOST}" "${DB_PORT}" 60 2; then
  pu_log_i "Database is ready, running migrations..."
  /app/migrate.sh
else
  pu_log_e "Database did not become ready in time"
  exit 1
fi
```

### 3. Integration Testing

```sh
# Start test services and wait for readiness
docker-compose up -d

pu_log_i "Waiting for test environment..."
pu_wait_for_port "localhost" "8080" 30 2 || exit 1
pu_wait_for_port "localhost" "5432" 30 2 || exit 1

pu_log_i "Running integration tests..."
npm test
```

## Environment Variables

This module uses the standard PU environment variables:

- `PU_HOME` - Path to the library installation (required)
- `PU_DEBUG_MODE` - Enable debug logging (default: `true`)
- `PU_COLORED_MODE` - Enable colored output (default: `true`)
- `PU_INIT_NETWORK` - Auto-load network module during init (default: `false`)

## Dependencies

- Requires `2.audit.sh` (automatically loaded by `1.init.sh`)
- Uses `nc` (netcat) if available, otherwise falls back to `/dev/tcp`
- Compatible with: Alpine Linux, Debian, Ubuntu, CentOS, RHEL, and other POSIX systems

## Testing

Run the network utilities test suite:

```sh
cd test
sh networkTest.sh
```

Or run all tests:

```sh
cd test
sh runTests.sh
```

## Notes

- The `nc` implementation is preferred for better POSIX compatibility
- The `/dev/tcp` fallback requires bash and may not work in pure POSIX shells
- Port numbers should be in the range 1-65535
- Hostname resolution depends on the system's DNS configuration
- Network timeouts are handled by the underlying tools (`nc` or bash)

## See Also

- [Audit Module Documentation](audit-sh-quick-reference.md)
- [Main README](../README.md)