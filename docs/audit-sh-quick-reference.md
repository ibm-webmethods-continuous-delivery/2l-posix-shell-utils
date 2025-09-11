# audit.sh Quick Reference

- [audit.sh Quick Reference](#auditsh-quick-reference)
  - [Environment Variables](#environment-variables)
  - [Quick Start](#quick-start)
  - [Functions](#functions)
  - [Log Format](#log-format)
  - [File Structure](#file-structure)


## Environment Variables
- `PU_DEBUG_ON=Y/N` - Enable debug logging (default: N)
- `PU_COLORED_OUTPUT=Y/N` - Enable colored output (default: Y)
- `PU_AUDIT_BASE_DIR=path` - Base directory for audit files
- `PU_SESSION_TIMESTAMP=name` - Custom session identifier

## Quick Start
```sh
# Basic usage
. /path/to/audit.sh
pu_logI "Info message"
pu_logW "Warning message"
pu_logE "Error message"
pu_logD "Debug message"  # Only when PU_DEBUG_ON=Y
```

## Functions
- `pu_logI` - Log info messages
- `pu_logW` - Log warning messages (yellow)
- `pu_logE` - Log error messages (red)
- `pu_logD` - Log debug messages (cyan, debug mode only)
- `pu_controlledExec` - Execute commands with audit trail
- `pu_logEnv` - Display PU environment variables
- `pu_logFullEnv` - Display all environment variables (debug mode)
- `pu_getAuditSessionDir` - Get session directory
- `pu_getAuditSessionFile` - Get session log file
- `pu_getAuditBaseDir` - Get base audit directory
- `pu_getDebugOn` - Get debug state
- `pu_setDebugOn` - Set debug mode

## Log Format
All logs: `HHMMSS<LEVEL>|<MESSAGE>`
- I = Info, W = Warning, E = Error, D = Debug

## File Structure
```
${PU_AUDIT_BASE_DIR}/
└── ${PU_SESSION_TIMESTAMP}/
    ├── session.log
    ├── cExec_<epoch>_<tag>.out
    └── cExec_<epoch>_<tag>.err
```
