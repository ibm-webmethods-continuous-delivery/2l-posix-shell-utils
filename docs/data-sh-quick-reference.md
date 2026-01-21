# Data Format Utilities Quick Reference (7.data.sh)

This module provides data format conversion utilities for POSIX-compatible shell scripts, including CSV and YAML processing.

## Prerequisites

Before using this module, you must source the initialization and audit modules:

```sh
export PU_HOME="/path/to/2l-posix-shell-utils"
export PU_INIT_DATA="true"  # Auto-load data module
. "${PU_HOME}/code/1.init.sh"
```

Or manually source after initialization:

```sh
. "${PU_HOME}/code/1.init.sh"
. "${PU_HOME}/code/7.data.sh"
```

## Functions

### pu_csv_to_lines

Convert a comma-separated values (CSV) string to separate lines.

**Signature:**
```sh
pu_csv_to_lines <csv_string> [delimiter]
```

**Parameters:**
- `$1` - CSV string to convert
- `$2` - OPTIONAL: delimiter character (default: `,`)

**Output:**
- Each value on a separate line to stdout

**Returns:**
- `0` - Success
- `1` - Missing required argument

**Example - Basic usage:**
```sh
pu_csv_to_lines "apple,banana,cherry"
# Output:
# apple
# banana
# cherry
```

**Example - Custom delimiter:**
```sh
pu_csv_to_lines "apple|banana|cherry" "|"
# Output:
# apple
# banana
# cherry
```

**Example - Processing in loop:**
```sh
servers="web1,web2,web3,db1"
pu_csv_to_lines "${servers}" | while read -r server; do
  pu_log_i "Processing server: ${server}"
  ssh "${server}" "systemctl status nginx"
done
```

---

### pu_lines_to_csv

Convert a file containing lines to a comma-separated values string.

**Signature:**
```sh
pu_lines_to_csv <file_path> [delimiter]
```

**Parameters:**
- `$1` - Path to file containing lines
- `$2` - OPTIONAL: delimiter character (default: `,`)

**Output:**
- CSV string to stdout

**Returns:**
- `0` - Success
- `1` - File not found or missing argument

**Example - Basic usage:**
```sh
# Given file.txt with content:
# apple
# banana
# cherry

pu_lines_to_csv "file.txt"
# Output: apple,banana,cherry
```

**Example - Custom delimiter:**
```sh
pu_lines_to_csv "servers.txt" "|"
# Output: web1|web2|web3
```

**Example - Building configuration:**
```sh
# Read list of allowed IPs from file
allowed_ips=$(pu_lines_to_csv "allowed_ips.txt")
echo "ALLOWED_IPS=${allowed_ips}" >> config.env
```

---

### pu_parse_yaml

Parse a YAML file and convert it to shell export statements. Handles simple YAML structures (key-value pairs and nested objects).

**Signature:**
```sh
pu_parse_yaml <yaml_file> [prefix]
```

**Parameters:**
- `$1` - Path to YAML file
- `$2` - OPTIONAL: prefix for environment variables (default: none)

**Output:**
- Shell export statements to stdout

**Returns:**
- `0` - Success
- `1` - File not found or missing argument

**Important Notes:**
- This is a simplified YAML parser for basic key-value structures
- May not handle complex YAML features like arrays, multi-line strings, anchors, etc.
- Nested keys are joined with underscores
- Hyphens in keys are converted to underscores

**Example - Basic usage:**
```sh
# Given config.yaml:
# database:
#   host: localhost
#   port: 5432
# app:
#   name: myapp

pu_parse_yaml "config.yaml" "APP_"
# Output:
# export APP_database_host="localhost"
# export APP_database_port="5432"
# export APP_app_name="myapp"
```

**Example - Evaluating output:**
```sh
eval $(pu_parse_yaml "config.yaml" "CONFIG_")
echo "Database host: ${CONFIG_database_host}"
echo "Database port: ${CONFIG_database_port}"
```

---

### pu_load_env_from_yaml

Load environment variables from a YAML file with a given prefix. This is a convenience wrapper around `pu_parse_yaml` that evaluates the output.

**Signature:**
```sh
pu_load_env_from_yaml <yaml_file> [prefix]
```

**Parameters:**
- `$1` - Path to YAML file
- `$2` - OPTIONAL: prefix for environment variables (default: none)

**Returns:**
- `0` - Success
- `1` - File not found, missing argument, or parsing failed

**Example - Basic usage:**
```sh
# Given config.yaml:
# database:
#   host: localhost
#   port: 5432

pu_load_env_from_yaml "config.yaml" "DB_"

# Now you can use the variables:
echo "Connecting to ${DB_database_host}:${DB_database_port}"
```

**Example - Application configuration:**
```sh
#!/bin/sh
# Load configuration from YAML

pu_load_env_from_yaml "app-config.yaml" "APP_"

# Use loaded configuration
pu_log_i "Starting ${APP_app_name} version ${APP_app_version}"
pu_log_i "Connecting to database at ${APP_database_host}"

# Start application with loaded config
exec /app/start.sh
```

## Use Cases

### 1. Processing CSV Data

```sh
# Parse CSV string and process each item
packages="nginx,postgresql,redis,docker"

pu_csv_to_lines "${packages}" | while read -r package; do
  pu_log_i "Installing ${package}..."
  apt-get install -y "${package}"
done
```

### 2. Building CSV from Multiple Sources

```sh
# Collect server names from multiple sources
echo "web1" > /tmp/servers.txt
echo "web2" >> /tmp/servers.txt
echo "web3" >> /tmp/servers.txt

# Convert to CSV for configuration
server_list=$(pu_lines_to_csv "/tmp/servers.txt")
echo "SERVERS=${server_list}" >> /etc/app/config
```

### 3. YAML-Based Configuration

```sh
# config.yaml:
# database:
#   host: postgres.example.com
#   port: 5432
#   name: myapp_db
# redis:
#   host: redis.example.com
#   port: 6379

# Load configuration
pu_load_env_from_yaml "config.yaml" "CFG_"

# Wait for services
pu_wait_for_port "${CFG_database_host}" "${CFG_database_port}"
pu_wait_for_port "${CFG_redis_host}" "${CFG_redis_port}"

# Start application
exec /app/start.sh
```

### 4. Environment-Specific Configuration

```sh
# Load environment-specific config
environment="${ENVIRONMENT:-development}"
config_file="config.${environment}.yaml"

if [ -f "${config_file}" ]; then
  pu_log_i "Loading ${environment} configuration..."
  pu_load_env_from_yaml "${config_file}" "APP_"
else
  pu_log_e "Configuration file not found: ${config_file}"
  exit 1
fi
```

### 5. Multi-Environment Deployment

```sh
# deploy.sh - Deploy to multiple environments

environments="dev,staging,production"

pu_csv_to_lines "${environments}" | while read -r env; do
  pu_log_i "Deploying to ${env}..."
  
  # Load environment-specific config
  pu_load_env_from_yaml "config.${env}.yaml" "DEPLOY_"
  
  # Deploy
  ssh "${DEPLOY_server_host}" "cd /app && git pull && systemctl restart app"
done
```

### 6. Dynamic Service Discovery

```sh
# services.txt contains one service per line
# Convert to comma-separated list for configuration

services_csv=$(pu_lines_to_csv "services.txt")

# Generate nginx upstream configuration
cat > /etc/nginx/conf.d/upstream.conf <<EOF
upstream backend {
$(pu_csv_to_lines "${services_csv}" | while read -r service; do
  echo "    server ${service}:8080;"
done)
}
EOF

nginx -s reload
```

## YAML Parsing Details

### Supported YAML Features

The `pu_parse_yaml` function supports:
- Simple key-value pairs
- Nested objects (converted to underscore-separated keys)
- Quoted and unquoted string values
- Numeric values
- Boolean values (as strings)

### Unsupported YAML Features

The following YAML features are NOT supported:
- Arrays/lists
- Multi-line strings
- Anchors and aliases
- Complex data types
- Comments (they are ignored)
- Multiple documents in one file

### Example YAML Structure

**Supported:**
```yaml
app:
  name: myapp
  version: 1.0.0
database:
  host: localhost
  port: 5432
  ssl_enabled: true
```

**Not Supported:**
```yaml
servers:  # Arrays not supported
  - web1
  - web2
description: |  # Multi-line strings not supported
  This is a
  multi-line description
```

## Implementation Credits

The YAML parsing implementation is based on:
- https://gist.github.com/pkuczynski/8665367

## Environment Variables

This module uses the standard PU environment variables:

- `PU_HOME` - Path to the library installation (required)
- `PU_DEBUG_MODE` - Enable debug logging (default: `true`)
- `PU_COLORED_MODE` - Enable colored output (default: `true`)
- `PU_INIT_DATA` - Auto-load data module during init (default: `false`)

## Dependencies

- Requires `2.audit.sh` (automatically loaded by `1.init.sh`)
- Uses standard POSIX utilities: `tr`, `sed`, `awk`, `read`
- No external dependencies required

## Testing

Run the data format utilities test suite:

```sh
cd test
sh dataTest.sh
```

Or run all tests:

```sh
cd test
sh runTests.sh
```

## Limitations

- YAML parser is simplified and may not handle all YAML features
- CSV functions do not handle quoted fields with embedded delimiters
- No support for CSV escaping or multi-line fields
- Large files may be slow due to line-by-line processing

## See Also

- [Audit Module Documentation](audit-sh-quick-reference.md)
- [String Utilities Documentation](string-sh-quick-reference.md)
- [Main README](../README.md)