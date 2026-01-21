# Rules for AI Agents

## Naming Convention

### Overview
This section defines the strict naming conventions for the POSIX shell utilities repository. All code MUST follow these rules for consistency and maintainability.

### Core Principles

#### 1. POSIX Compliance
- All code MUST be strictly POSIX compliant for maximum portability
- No bash-specific features allowed
- Use `/bin/sh` shebang

#### 2. Snake Case Convention
- All function and variable names use snake_case (lowercase with underscores)
- Exception: Environment constants are UPPER_CASE

### Function Naming Rules

#### 3. Public Functions
- **Pattern**: `pu_<module>_<action>` or `pu_<action>`
- **Prefix**: No underscore prefix
- **Visibility**: Intended for external use by scripts consuming this library
- **Examples**: 
  - `pu_log_i` (public logging function)
  - `pu_assure_public_file` (public file assurance function)
  - `pu_init_hunt_for_pu_file` (public initialization helper)

#### 4. Private Functions (File-Scoped)
- **Pattern**: `_pu_<module>_<action>` or `_<module>_<action>`
- **Prefix**: Single underscore `_`
- **Visibility**: Internal to the file, not intended for external use
- **Examples**:
  - `_pu_init_error` (private to init file)
  - `_pu_init_info` (private to init file)
  - `_pu_init` (private initialization function)

### Variable Naming Rules

#### 5. Environment Constants (External Input)
- **Pattern**: `PU_<NAME>` or `<EXTERNAL_NAME>`
- **Case**: UPPER_CASE with underscores
- **Mutability**: MUST NOT be modified by scripts (read-only)
- **Source**: Set by external environment before script execution
- **Examples**:
  - `PU_HOME` (framework home directory)
  - `PU_ONLINE_MODE` (external configuration)
  - `PU_DEBUG_MODE` (external configuration)
  - `PU_CACHE_HOME` (external configuration)

#### 6. Public Variables (Script-Managed, Cross-Function)
- **Pattern**: `pu_<name>`
- **Case**: lowercase with underscores
- **Prefix**: No underscore prefix
- **Visibility**: Set by scripts, visible and usable across all functions and files
- **Export**: May be exported to environment for cross-script usage
- **Lifecycle**: Persist throughout script execution
- **Examples**:
  - `pu_debug_mode` (framework-managed debug state)
  - `pu_session_id` (current session identifier)
  - `pu_log_level` (current logging level)

#### 7. File-Scoped Private Variables
- **Pattern**: `__<file_number>__<name>`
- **Case**: lowercase with underscores
- **Prefix**: Double underscore `__`
- **Visibility**: Private to all functions within a single file
- **Export**: MUST NOT be exported
- **Lifecycle**: Persist across function calls within the same file
- **Naming**: 
  - `<file_number>` is the numeric prefix of the file (e.g., `1` for `1.init.sh`)
  - Double underscore after file number: `__<file_number>__`
- **Examples**:
  - `__1__online_mode` (private to 1.init.sh, used by multiple functions)
  - `__1__clr_reset` (private to 1.init.sh, color reset code)
  - `__3__cache_home` (private to 3.ingester.sh, cache directory)

#### 8. Function-Scoped Private Variables (Local)
- **Pattern**: `__<file_number>_<function_number>_<name>`
- **Case**: lowercase with underscores
- **Prefix**: Double underscore `__`
- **Visibility**: Private to a single function only
- **Export**: MUST NOT be exported
- **Lifecycle**: MUST be unset before function returns
- **Uniqueness**: Names MUST be globally unique across entire codebase
- **Naming**:
  - `<file_number>` is the numeric prefix of the file (e.g., `1` for `1.init.sh`)
  - `<function_number>` is the function sequence number in that file (e.g., `03` for Function 03)
  - Single underscore between file and function: `__<file_number>_<function_number>_`
- **Examples**:
  - `__1_03_red` (temporary color variable in 1.init.sh, Function 03)
  - `__3_02_full_file_folder` (local path variable in 3.ingester.sh, Function 02)
  - `__3_02_sha256` (local checksum variable in 3.ingester.sh, Function 02)
  - `__3_02_result_curl` (local return code in 3.ingester.sh, Function 02)

### Variable Scope Summary Table

| Scope | Pattern | Prefix | Case | Export | Unset | Example |
|-------|---------|--------|------|--------|-------|---------|
| Environment Constant | `PU_<NAME>` | None | UPPER | No | No | `PU_HOME` |
| Public Script-Managed | `pu_<name>` | None | lower | Maybe | No | `pu_debug_mode` |
| File-Scoped Private | `__<file>__<name>` | `__` | lower | No | No | `__1__online_mode` |
| Function-Scoped Private | `__<file>_<func>_<name>` | `__` | lower | No | Yes | `__3_02_sha256` |

### Naming Pattern Recognition Guide

#### How to Identify Variable Scope by Name

1. **UPPER_CASE** → Environment constant (external, read-only)
2. **pu_lowercase** → Public script-managed variable (cross-function, cross-file)
3. **__N__lowercase** → File-scoped private (all functions in file N)
4. **__N_FF_lowercase** → Function-scoped private (file N, function FF only)

#### How to Identify Function Scope by Name

1. **pu_action** → Public function (external API)
2. **_pu_action** or **_action** → Private function (file-internal)

### Special Cases

#### 9. Color Code Variables
Color codes used for terminal output follow file-scoped or function-scoped rules:
- **File-scoped** (used by multiple functions): `__<file>__clr_<color>`
  - Example: `__1__clr_reset` (used across multiple functions in 1.init.sh)
- **Function-scoped** (used in one function): `__<file>_<func>_<color>`
  - Example: `__1_01_red` (used only in Function 01 of 1.init.sh)

#### 10. Temporary/Working Variables
All temporary variables within functions MUST follow function-scoped naming:
- Pattern: `__<file>_<func>_<name>`
- MUST be unset before function returns
- Examples: `__3_02_result_curl`, `__3_02_checksum`

### Enforcement Rules

#### 11. Variable Lifecycle Management
- **Function-scoped variables** MUST be unset before function returns
- **File-scoped variables** persist throughout file execution
- **Public variables** persist throughout script execution
- **Environment constants** MUST never be modified

#### 12. Export Policy
- Environment constants: Already in environment (no export needed)
- Public script-managed: May be exported if needed for sub-scripts
- File-scoped private: MUST NOT be exported
- Function-scoped private: MUST NOT be exported

#### 13. Documentation Requirements
Each function MUST include:
- Function number comment (e.g., `# Function 01`)
- Purpose description
- Parameter documentation
- Variable scope documentation for non-obvious cases

### Reference Examples

#### Correct Variable Naming Patterns

```sh
# File: 1.init.sh, Function 04
_pu_init() {
  # File-scoped variables (used by multiple functions)
  __1__clr_reset='\033[0m'
  __1__online_mode="${PU_ONLINE_MODE:-true}"
  __1__debug_mode="${PU_DEBUG_MODE:-true}"
  
  # Function-scoped variables (local to this function)
  __1_04_result=0
  
  # ... function logic ...
  
  # Cleanup function-scoped variables
  unset __1_04_result
}

# File: 3.ingester.sh, Function 02
pu_assure_public_file() {
  # Function-scoped variables
  __3_02_full_file_folder="${__3__cache_home}/${1}/${3}"
  __3_02_full_file_pathname="${__3_02_full_file_folder}/${4}"
  __3_02_sha256="${5:-none}"
  
  # ... function logic ...
  
  # Cleanup before return
  unset __3_02_full_file_folder __3_02_full_file_pathname __3_02_sha256
  return 0
}
```

### Validation Checklist

Before committing code, verify:
- [ ] All functions follow public/private naming rules
- [ ] All variables have correct prefix for their scope
- [ ] File-scoped variables use `__<file>__<name>` pattern
- [ ] Function-scoped variables use `__<file>_<func>_<name>` pattern
- [ ] Function-scoped variables are unset before return
- [ ] No private variables are exported
- [ ] Environment constants are not modified
- [ ] Function numbers are documented in comments
- [ ] POSIX compliance maintained (no bash-isms)

## Values Conventions

### Boolean Variables

#### 14. Boolean Value Convention
- **True Value**: Boolean variables MUST contain the string `"true"` (lowercase) to represent true
- **False Value**: Any other value, or a missing/unset variable, represents false
- **Rationale**: POSIX shell does not have native boolean types; this convention provides consistency
- **Testing**: Always use string comparison: `[ "${variable}" = "true" ]`
- **Examples**:
  ```sh
  # Setting boolean values
  __1__debug_mode="${PU_DEBUG_MODE:-true}"
  __1__online_mode="${PU_ONLINE_MODE:-true}"
  
  # Testing boolean values
  if [ "${__1__debug_mode}" = "true" ]; then
    pu_log_d "Debug mode is enabled"
  fi
  
  # False can be any value or unset
  __1__offline_mode="false"  # Explicit false
  __1__disabled_mode=""      # Empty string means false
  # unset __1__missing_mode   # Unset means false
  ```

---

**Last Updated**: 2026-01-21