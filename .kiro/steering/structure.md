# Project Structure

## Directory Organization

```
├── .kiro/              # Kiro IDE configuration and steering rules
├── generated/          # SQLC generated Go code (DO NOT EDIT)
│   ├── db.go          # Database connection interface
│   ├── models.go      # Generated struct types
│   └── *.sql.go       # Generated query functions
├── migrations/         # Database schema migrations
│   ├── *.up.sql       # Forward migrations
│   └── *.down.sql     # Rollback migrations
├── raw/               # Raw SQL queries organized by domain
│   └── users/         # User-related queries
│       ├── users.sql  # User and auth operations
│       └── organization.sql # Organization operations
├── main.go            # Application entry point and test runner
├── sqlc.yaml          # SQLC configuration
├── Makefile           # Build and database commands
├── go.mod             # Go module dependencies
└── README.md          # Project documentation
```

## File Naming Conventions
- SQL files: lowercase with underscores (`users.sql`, `organization.sql`)
- Go files: lowercase with underscores for generated code
- Migration files: timestamp prefix (`20251006072309_initial.up.sql`)
- Unique names: use timestamp suffix for test data uniqueness

## Code Organization Patterns
- Group related SQL queries in domain-specific files under `raw/`
- Use descriptive SQLC query names with action prefix (`Insert`, `Get`, `List`, `Update`, `Delete`)
- Organize complex operations into transaction-based functions
- Test functions follow pattern: `test{Domain}Operations()`

## Generated Code Rules
- Never edit files in `generated/` directory
- Regenerate after SQL changes: `make gen`
- Use generated structs and params for type safety
- Import generated package: `"github.com/sushan531/auth-sqlc/generated"`

## Database Connection Pattern
```go
// Standard connection setup
db, err := sql.Open("postgres", dbURL)
queries := generated.New(db)
ctx := context.Background()
```