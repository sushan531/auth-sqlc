# Technology Stack

## Core Technologies
- **Go 1.25+** - Primary programming language
- **PostgreSQL** - Database with UUID v7 primary keys
- **SQLC** - Type-safe SQL code generation

## Key Dependencies
- `github.com/lib/pq` - PostgreSQL driver
- `github.com/google/uuid` - UUID generation and handling
- `github.com/shopspring/decimal` - Decimal precision for financial data

## Database Conventions
- Use `uuid DEFAULT uuidv7()` for all primary keys
- Financial amounts use `DECIMAL` type, mapped to `decimal.Decimal` in Go
- Enum types for constrained values (operation_type, payment methods)
- Foreign key relationships enforced at database level
- Use `sql.NullString`, `sql.NullInt64` for nullable fields

## SQLC Configuration
- Queries organized in `raw/` directory by domain
- Generated code in `generated/` package
- JSON tags enabled for all structs
- Custom type overrides for PostgreSQL numeric → decimal.Decimal

## Common Commands
```bash
# Generate SQLC code
make gen
sqlc generate

# Database migrations
make migrate          # Run up migrations
make rollback        # Run down migrations
make drop           # Drop all tables

# Create new migration
make migration      # Interactive prompt for name

# SQLC cloud operations
make push           # Push schema to SQLC cloud
make verify         # Verify queries against schema

# Run application
export DATABASE_URL="postgres://user:pass@localhost:5432/dbname?sslmode=disable"
go run main.go
```