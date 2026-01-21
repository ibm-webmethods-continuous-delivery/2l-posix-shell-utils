# String Utilities Quick Reference (6.string.sh)

This module provides string manipulation and encoding utilities for POSIX-compatible shell scripts.

## Prerequisites

Before using this module, you must source the initialization and audit modules:

```sh
export PU_HOME="/path/to/2l-posix-shell-utils"
export PU_INIT_STRING="true"  # Auto-load string module
. "${PU_HOME}/code/1.init.sh"
```

Or manually source after initialization:

```sh
. "${PU_HOME}/code/1.init.sh"
. "${PU_HOME}/code/6.string.sh"
```

## Functions

### pu_urlencode

URL encode a string for safe use in URLs. Encodes special characters to percent-encoded format according to RFC 3986.

**Signature:**
```sh
pu_urlencode <string> [additional_strings...]
```

**Parameters:**
- `$*` - String(s) to encode (all arguments are concatenated)

**Output:**
- URL-encoded string to stdout

**Safe Characters (not encoded):**
- Alphanumeric: `a-z`, `A-Z`, `0-9`
- Special: `.`, `~`, `_`, `-`

**Example - Basic usage:**
```sh
encoded=$(pu_urlencode "hello world")
echo "${encoded}"
# Output: hello%20world
```

**Example - Special characters:**
```sh
encoded=$(pu_urlencode "hello&world?query=value")
echo "${encoded}"
# Output: hello%26world%3Fquery%3Dvalue
```

**Example - Building URLs:**
```sh
base_url="https://api.example.com/search"
query="user input with spaces"
encoded_query=$(pu_urlencode "${query}")
full_url="${base_url}?q=${encoded_query}"

pu_log_i "Fetching: ${full_url}"
curl "${full_url}"
```

**Example - Multiple parameters:**
```sh
name="John Doe"
email="john.doe@example.com"

url="https://api.example.com/user"
url="${url}?name=$(pu_urlencode "${name}")"
url="${url}&email=$(pu_urlencode "${email}")"

curl "${url}"
```

---

### pu_urlencode_pipe

URL encode input from stdin, character by character. This is typically used internally by `pu_urlencode()` but can be used directly for piped input.

**Signature:**
```sh
echo "string" | pu_urlencode_pipe
```

**Input:**
- stdin (piped input)

**Output:**
- URL-encoded string to stdout

**Example:**
```sh
echo "hello world" | pu_urlencode_pipe
# Output: hello%20world
```

**Example - Processing file content:**
```sh
cat input.txt | pu_urlencode_pipe > encoded.txt
```

---

### pu_str_substitute

POSIX-compatible string substitution using the `tr` command. Works character-by-character, not with substrings.

**Signature:**
```sh
pu_str_substitute <original_string> <from_chars> <to_chars>
```

**Parameters:**
- `$1` - Original string to transform
- `$2` - Character set to substitute (from)
- `$3` - Replacement character set (to)

**Output:**
- Transformed string to stdout

**Returns:**
- `0` - Success
- `1` - Missing required arguments

**Important Notes:**
- Works character-by-character using `tr`
- Each character in `from_chars` is replaced by the corresponding character in `to_chars`
- Not suitable for substring replacement
- POSIX-portable alternative to bash string substitution

**Example - Replace spaces with underscores:**
```sh
result=$(pu_str_substitute "hello world" " " "_")
echo "${result}"
# Output: hello_world
```

**Example - Multiple character substitution:**
```sh
filename="My Document.txt"
safe_name=$(pu_str_substitute "${filename}" " ." "_-")
echo "${safe_name}"
# Output: My_Document-txt
```

**Example - Sanitize filenames:**
```sh
user_input="file name with spaces.txt"
safe_filename=$(pu_str_substitute "${user_input}" " " "_")
touch "${safe_filename}"
```

**Example - Convert to lowercase (using tr ranges):**
```sh
uppercase="HELLO WORLD"
lowercase=$(pu_str_substitute "${uppercase}" "A-Z" "a-z")
echo "${lowercase}"
# Output: hello world
```

**Example - Remove special characters:**
```sh
text="hello@world#test"
clean=$(pu_str_substitute "${text}" "@#" "__")
echo "${clean}"
# Output: hello_world_test
```

## Use Cases

### 1. Building API URLs

```sh
# Search API with user input
search_term="software engineering jobs"
location="New York"

api_url="https://api.jobs.com/search"
api_url="${api_url}?q=$(pu_urlencode "${search_term}")"
api_url="${api_url}&location=$(pu_urlencode "${location}")"

curl -H "Authorization: Bearer ${TOKEN}" "${api_url}"
```

### 2. Filename Sanitization

```sh
# Convert user-provided filename to safe format
user_filename="My Project (Draft).docx"
safe_filename=$(pu_str_substitute "${user_filename}" " ()" "___")

pu_log_i "Saving as: ${safe_filename}"
cp "${source}" "${safe_filename}"
```

### 3. Log File Naming

```sh
# Create log filename from timestamp and service name
service_name="API Server"
timestamp=$(date +%Y-%m-%d_%H:%M:%S)
log_name="${service_name}_${timestamp}.log"

# Sanitize for filesystem
safe_log_name=$(pu_str_substitute "${log_name}" " :" "__")
pu_log_i "Logging to: ${safe_log_name}"
```

### 4. Configuration File Processing

```sh
# Convert YAML-style keys to shell variable names
yaml_key="database.connection.host"
var_name=$(pu_str_substitute "${yaml_key}" "." "_")
var_name=$(pu_str_substitute "${var_name}" "a-z" "A-Z")

echo "export ${var_name}=localhost"
# Output: export DATABASE_CONNECTION_HOST=localhost
```

### 5. URL Query String Building

```sh
# Build complex query string
build_query_string() {
  local result=""
  local first=1
  
  while [ $# -gt 0 ]; do
    key="$1"
    value="$2"
    shift 2
    
    if [ ${first} -eq 1 ]; then
      first=0
    else
      result="${result}&"
    fi
    
    result="${result}${key}=$(pu_urlencode "${value}")"
  done
  
  echo "${result}"
}

# Usage
query=$(build_query_string \
  "name" "John Doe" \
  "email" "john@example.com" \
  "message" "Hello, World!")

curl "https://api.example.com/contact?${query}"
```

## Implementation Details

### URL Encoding Algorithm

The `pu_urlencode` function uses a POSIX-portable approach:

1. Reads input character by character using `fold -w1`
2. Checks each character against safe character set
3. Safe characters pass through unchanged
4. Unsafe characters are converted to hex using `od -An -tx1`
5. Hex values are prefixed with `%`

This approach ensures compatibility across different shells and systems without relying on bash-specific features.

### Character Substitution

The `pu_str_substitute` function uses the standard `tr` command, which is available on all POSIX systems. The `tr` command performs character-by-character translation, making it ideal for:

- Case conversion
- Character replacement
- Character removal
- Character squeezing

## Environment Variables

This module uses the standard PU environment variables:

- `PU_HOME` - Path to the library installation (required)
- `PU_DEBUG_MODE` - Enable debug logging (default: `true`)
- `PU_COLORED_MODE` - Enable colored output (default: `true`)
- `PU_INIT_STRING` - Auto-load string module during init (default: `false`)

## Dependencies

- Requires `2.audit.sh` (automatically loaded by `1.init.sh`)
- Uses standard POSIX utilities: `tr`, `od`, `fold`, `printf`
- No external dependencies required

## Testing

Run the string utilities test suite:

```sh
cd test
sh stringTest.sh
```

Or run all tests:

```sh
cd test
sh runTests.sh
```

## Limitations

- `pu_str_substitute` works character-by-character, not with substrings
- For substring replacement, use `sed` or other tools
- URL encoding follows RFC 3986 but may not handle all edge cases
- Very long strings may be slow due to character-by-character processing

## See Also

- [Audit Module Documentation](audit-sh-quick-reference.md)
- [Data Format Utilities Documentation](data-sh-quick-reference.md)
- [Main README](../README.md)