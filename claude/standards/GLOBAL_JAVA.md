# Java Development Standards

## Style & Formatting

- Formatter: Google Java Format (line length: 100 chars).
- Naming: camelCase for methods/variables, PascalCase for classes, UPPER_SNAKE_CASE for constants.
- Documentation: Javadoc for all public APIs.

## Type Safety

- Avoid raw types; always use generic types.
- Use `Optional<T>` instead of returning `null`.
- Prefer immutable objects; use `final` where appropriate.

## Testing (JUnit 5 + Allure)

- All test classes annotated with `@Epic` and `@Feature` (Allure).
- Use `@Step` for complex test steps.
- Run command: `mvn test` or `gradle test`.
- Coverage: Minimum 80% line coverage required for new features (JaCoCo).

## Build Tooling

- Preferred: Maven or Gradle (project consistent — do not mix).
- Use BOM (Bill of Materials) for dependency version management.
- Static Analysis: Run Checkstyle and SpotBugs before finalizing any PR.
