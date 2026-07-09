# 4.common.sh Quick Reference

- [4.common.sh Quick Reference](#4commonsh-quick-reference)
  - [Module Overview](#module-overview)
  - [Quick Setup](#quick-setup)
    - [pu\_log\_env\_filtered](#pu_log_env_filtered)
    - [pu\_debug\_suspend](#pu_debug_suspend)
  - [Functions](#functions)
    - [pu\_read\_secret\_from\_user](#pu_read_secret_from_user)
  - [Usage Examples](#usage-examples)
    - [Basic Password Input](#basic-password-input)
    - [API Key Input](#api-key-input)
    - [Database Credentials](#database-credentials)
    - [With Validation](#with-validation)
  - [Security Considerations](#security-considerations)
  - [Best Practices](#best-practices)
  - [Troubleshooting](#troubleshooting)

## Module Overview

**Purpose**: Common utility functions for shell scripts  
**Dependencies**: `2.audit.sh` (for logging)  
**Location**: `${PU_HOME}/code/4.common.sh`  
**Auto-loaded**: Only if `PU_INIT_COMMON=true` when sourcing `1.init.sh`

## Quick Setup

```sh
# Method 1: Auto-load via init script
export PU_HOME="/path/to/2l-posix-shell-utils"
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

# Method 2: Manual load (after audit.sh)
export PU_HOME="/path/to/2l-posix-shell-utils"
. "${PU_HOME}/code/1.init.sh"
. "${PU_HOME}/code/4.common.sh"
```


### pu_log_env_filtered

Display and log environment variables with sensitive data filtered out. Only active when debug mode is enabled.

```sh
pu_log_env_filtered [PREFIX]
```

**Parameters:**
- `PREFIX`: OPTIONAL - Variable prefix to filter (default: "PU")

**Behavior:**
1. Only executes when `__pu_debug_mode` is `true`
2. Filters out variables containing: PASS, password, dbpass (case-insensitive)
3. Displays filtered variables to stderr
4. Logs filtered variables to audit session file

**Example:**
```sh
export APP_DATABASE_HOST="localhost"
export APP_DATABASE_PASSWORD="secret123"
export APP_API_KEY="key123"

pu_log_env_filtered "APP"
# Output shows APP_DATABASE_HOST and APP_API_KEY
# But NOT APP_DATABASE_PASSWORD (filtered)
```

**Use Cases:**
- Debugging configuration issues
- Auditing environment setup
- Troubleshooting without exposing secrets

---

### pu_debug_suspend

Suspend script execution indefinitely for debugging purposes. Only active when debug mode is enabled.

```sh
pu_debug_suspend
```

**Behavior:**
1. Only executes when `__pu_debug_mode` is `true`
2. Logs suspension message
3. Runs `tail -f /dev/null` to suspend indefinitely
4. Useful for keeping containers alive for inspection

**Example:**
```sh
# In a Docker entrypoint script
pu_log_i "Application started"

# Suspend for debugging if debug mode is on
pu_debug_suspend

# This line only reached if debug mode is off
exec /app/start.sh
```

**Use Cases:**
- Keeping Docker containers alive for debugging
- Pausing execution to inspect state
- Interactive debugging sessions

**To Resume:**
- Kill the process or container
- Set `PU_DEBUG_MODE="false"` to skip suspension

---

## Functions

### pu_read_secret_from_user

Securely read a secret (password, token, key) from the user with confirmation.

```sh
pu_read_secret_from_user LABEL
```

**Parameters:**
- `LABEL`: A descriptive label shown to the user (e.g., "database password", "API key")

**Behavior:**
1. Disables terminal echo (input not visible)
2. Prompts user to input the secret
3. Prompts user to input the secret again for confirmation
4. If inputs match, stores value in `${secret}` variable
5. If inputs don't match, repeats the process
6. Re-enables terminal echo

**Output Variable:**
- `secret`: Contains the user input (MUST be used immediately and unset)

**Important:**
- Input is NOT echoed to the terminal (secure)
- User must enter the same value twice
- Loop continues until values match
- Caller MUST unset `secret` immediately after use

**Example:**
```sh
pu_read_secret_from_user "database password"
db_password="${secret}"
unset secret  # CRITICAL: Always unset immediately

# Use the password
mysql -u user -p"${db_password}" ...
unset db_password  # Unset when done
```

## Usage Examples

### Basic Password Input

```sh
#!/bin/sh
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

pu_log_i "Database connection required"
pu_read_secret_from_user "database password"
db_pass="${secret}"
unset secret

# Use the password
if mysql -u myuser -p"${db_pass}" -e "SELECT 1" > /dev/null 2>&1; then
    pu_log_i "Database connection successful"
else
    pu_log_e "Database connection failed"
    exit 1
fi

unset db_pass
```

### API Key Input

```sh
#!/bin/sh
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

pu_log_i "API authentication required"
pu_read_secret_from_user "API key"
api_key="${secret}"
unset secret

# Use the API key
response=$(curl -H "Authorization: Bearer ${api_key}" \
    https://api.example.com/data)

unset api_key
```

### Database Credentials

```sh
#!/bin/sh
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

# Read username (not secret, can use regular read)
printf "Database username: "
read -r db_user

# Read password securely
pu_read_secret_from_user "database password for user ${db_user}"
db_pass="${secret}"
unset secret

# Connect to database
psql -U "${db_user}" -h localhost -d mydb <<EOF
${db_pass}
SELECT * FROM users;
EOF

unset db_pass db_user
```

### With Validation

```sh
#!/bin/sh
export PU_INIT_COMMON="true"
. "${PU_HOME}/code/1.init.sh"

# Function to validate password strength
validate_password() {
    local pass="$1"
    local len=${#pass}
    
    if [ ${len} -lt 8 ]; then
        pu_log_e "Password must be at least 8 characters"
        return 1
    fi
    
    # Add more validation as needed
    return 0
}

# Read password with validation
valid_password="false"
while [ "${valid_password}" = "false" ]; do
    pu_read_secret_from_user "new password"
    password="${secret}"
    unset secret
    
    if validate_password "${password}"; then
        valid_password="true"
        pu_log_i "Password accepted"
    else
        pu_log_w "Please try again with a stronger password"
        unset password
    fi
done

# Use the validated password
# ... your code here ...

unset password
```

## Security Considerations

1. **Terminal Echo Disabled**
   - Input is not visible on screen
   - Prevents shoulder surfing
   - Prevents input from appearing in terminal history

2. **Confirmation Required**
   - User must enter the same value twice
   - Reduces typos and mistakes
   - Ensures user knows what they entered

3. **Variable Hygiene**
   - ALWAYS unset `secret` immediately after copying
   - ALWAYS unset your own variable when done
   - Prevents secrets from lingering in memory

4. **Not Suitable for Unattended Mode**
   - Requires user interaction
   - Will hang if no user present
   - Use environment variables for automation

5. **No Logging**
   - Function does not log the secret
   - Ensure your code doesn't log it either
   - Be careful with debug output

## Best Practices

1. **Always unset the secret variable immediately**
   ```sh
   pu_read_secret_from_user "password"
   my_password="${secret}"
   unset secret  # Do this immediately!
   ```

2. **Use descriptive labels**
   ```sh
   # Good
   pu_read_secret_from_user "GitHub personal access token"
   pu_read_secret_from_user "production database password"
   
   # Bad
   pu_read_secret_from_user "password"
   pu_read_secret_from_user "secret"
   ```

3. **Unset your variables when done**
   ```sh
   pu_read_secret_from_user "API key"
   api_key="${secret}"
   unset secret
   
   # Use the API key
   curl -H "Authorization: Bearer ${api_key}" ...
   
   # Clean up when done
   unset api_key
   ```

4. **Don't use in unattended scripts**
   ```sh
   # Check if running in attended mode
   if [ "${PU_ATTENDED_MODE}" != "true" ]; then
       pu_log_e "This script requires user interaction"
       exit 1
   fi
   
   pu_read_secret_from_user "password"
   ```

5. **Validate input when appropriate**
   ```sh
   pu_read_secret_from_user "password"
   password="${secret}"
   unset secret
   
   if [ -z "${password}" ]; then
       pu_log_e "Password cannot be empty"
       exit 1
   fi
   ```

6. **Never log secrets**
   ```sh
   # NEVER do this:
   pu_log_i "Password is: ${password}"  # BAD!
   
   # Instead:
   pu_log_i "Password received"  # Good
   ```

7. **Use for interactive scripts only**
   ```sh
   # Interactive script
   pu_read_secret_from_user "password"
   
   # Automated script - use environment variables
   password="${DB_PASSWORD}"
   if [ -z "${password}" ]; then
       pu_log_e "DB_PASSWORD environment variable not set"
       exit 1
   fi
   ```

8. **Consider using a secrets manager for production**
   ```sh
   # Development/testing
   if [ "${ENV}" = "dev" ]; then
       pu_read_secret_from_user "API key"
       api_key="${secret}"
       unset secret
   else
       # Production - use secrets manager
       api_key=$(vault kv get -field=api_key secret/myapp)
   fi
   ```

9. **Handle interrupts gracefully**
   ```sh
   # Ensure terminal echo is restored on interrupt
   trap 'stty echo; exit 130' INT TERM
   
   pu_read_secret_from_user "password"
   password="${secret}"
   unset secret
   
   trap - INT TERM
   ```

10. **Document secret requirements**
    ```sh
    #!/bin/sh
    # This script requires:
    # - Database password (will prompt)
    # - API key (will prompt)
    # Run in attended mode only
    
    export PU_ATTENDED_MODE="true"
    export PU_INIT_COMMON="true"
    . "${PU_HOME}/code/1.init.sh"
    ```

## Troubleshooting

**Problem:** Terminal echo not restored after script interruption

**Solution:**
```sh
# Manually restore echo
stty echo

# Or add trap in your script
trap 'stty echo; exit 130' INT TERM
```

**Problem:** Script hangs in CI/CD pipeline

**Cause:** Script is waiting for user input in unattended environment

**Solution:**
```sh
# Check for attended mode before prompting
if [ "${PU_ATTENDED_MODE}" != "true" ]; then
    pu_log_e "Cannot prompt for secrets in unattended mode"
    pu_log_e "Please set required environment variables"
    exit 1
fi
```

**Problem:** Inputs don't match, stuck in loop

**Cause:** User is making typos or copy-paste issues

**Solution:**
- Type carefully
- Use a password manager to generate and store
- Consider adding a "cancel" option in your wrapper

**Problem:** Need to cancel input

**Solution:**
```sh
# Press Ctrl+C to interrupt
# Ensure your script has proper cleanup:
trap 'stty echo; pu_log_w "Cancelled by user"; exit 130' INT TERM
```

**Problem:** Secret contains special characters causing issues

**Solution:**
```sh
# Always quote variables
mysql -u user -p"${password}" ...  # Good
mysql -u user -p${password} ...    # Bad - will break with spaces/special chars
```

**Problem:** Want to allow empty secrets

**Current behavior:** Function accepts empty input if both entries match

**Solution:** Add validation in your code:
```sh
pu_read_secret_from_user "optional token"
token="${secret}"
unset secret

if [ -z "${token}" ]; then
    pu_log_w "No token provided, using anonymous access"
    token="anonymous"
fi