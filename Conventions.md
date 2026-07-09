# Rules for Contributing Code

## Naming convention

1. The code MUST be strictly POSIX compliant for portability reasons.
2. Function and variable names follow snake naming convention.
3. Public functions do not have underscore prefix.
4. Private functions have one underscore prefix.
5. Public variables received from environment are considered constants by the scripts and MUST not be changed. These are always in capital letters, e.g. PU_HOME
6. Public variables are not preceded by an underscore.
7. Public variables managed by the scripts are written in lowercase. By public in this case we mean they remain in the environment for usage across functions.
8. Private variables are written in lowercase. By private in this case we mean they are only used within the function. These variables are prefixed with two underscores. These variables are not exported to the environment. Furthermore, they must be unset before the function returns. Their names must be globally unique, therefore they must have a convention like __<file_number>_<function_number>_<name>.

## Values conventions

1. Boolean variable contain the string "true" meaning true. Any other value or missing variable means false.
