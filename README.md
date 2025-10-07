# HK IMS SQLC Test Application

This project contains SQLC generated code for a Hong Kong Inventory Management System (IMS) with PostgreSQL database integration.

## Project Structure

- `generated/` - SQLC generated Go code from SQL queries
- `migrations/` - Database migration files
- `raw/` - Raw SQL query files organized by domain
- `main.go` - Test application to demonstrate SQLC generated code usage
- `sqlc.yaml` - SQLC configuration file

## Prerequisites

1. **Go 1.25+** installed
2. **PostgreSQL database** running
3. **Database created** with the name specified in your connection string

## Database Setup

1. Create a PostgreSQL database:
   ```sql
   CREATE DATABASE hk_ims;
   ```

2. Run the migrations to set up the schema:
   ```bash
   # You can use a migration tool like golang-migrate or run the SQL directly
   psql -d hk_ims -f migrations/20251006072309_initial.up.sql
   ```

## Running the Test Application

### Option 1: Using Environment Variable
```bash
export DATABASE_URL="postgres://username:password@localhost:5432/hk_ims?sslmode=disable"
go run main.go
```

### Option 2: Using Default Connection (modify main.go if needed)
```bash
# The default connection string is:
# postgres://postgres:password@localhost:5432/hk_ims?sslmode=disable
go run main.go
```

### Option 3: Build and Run
```bash
go build -o test_app main.go
./test_app
```

## What the Test Application Does

The `main.go` file demonstrates the usage of all major SQLC generated functions:

### 🏢 Organization Operations
- Creates test organizations
- Retrieves organizations by name
- Tests the `InsertOrganization` and `GetOrganization` functions

### 🏪 Branch Operations  
- Creates test branches linked to organizations
- Lists all branches for an organization
- Tests the `InsertBranch` and `GetOrganizationBranches` functions

### 👤 User/Auth Operations
- Creates test users with authentication data
- Retrieves users by email
- Lists all users in an organization
- Tests the `InsertAuth`, `GetUserByEmail`, and `GetAllUsers` functions

### 📦 Product Operations
- Creates test products with pricing and inventory data
- Retrieves products by ID
- Checks product existence
- Lists product names
- Shows branch-to-product mappings
- Tests multiple product-related functions including:
  - `InsertProduct`
  - `GetProduct` 
  - `CheckProductExists`
  - `ListAllProductNames`
  - `GetBranchToProductMapping`

### 🛒 Purchase Operations
- Demonstrates the `InsertOrUpdateProductsWithPurchasesAndPurchaseGroup` function with both INSERT and UPDATE scenarios:
  - **INSERT**: Creates new products with initial purchase quantities
  - **UPDATE**: Adds inventory to existing products (identified by unique_name) and updates selling prices
- Shows how the same function handles both creating new products and restocking existing ones

## Expected Output

When you run the application successfully, you should see output like:

```
✅ Successfully connected to database

🧪 Running SQLC Generated Code Tests...

📊 Testing Organization Operations...
✅ Created organization: Test Organization 1234567890 (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
✅ Retrieved organization: Test Organization 1234567890 (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

🏢 Testing Branch Operations...
✅ Created branch: Test Branch (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
✅ Found 1 branches for organization
   - Test Branch (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

👤 Testing User/Auth Operations...
✅ Created user: test_1234567890@example.com (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
✅ Retrieved user: test_1234567890@example.com (Role: admin)
✅ Found 1 users in organization

📦 Testing Product Operations...
✅ Created product: Test Product (ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
   Price: $99.99, Quantity: 100 pieces
✅ Retrieved product: Test Product
✅ Product existence check: found 1 products with unique name
✅ Found 1 products in organization:
   - Test Product
✅ Branch to Product mapping (1 entries):
   - Product Test Branch -> Test Product

✅ All tests completed successfully!
```

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Verify the database exists
- Check the connection string credentials
- Ensure the database user has proper permissions

### Migration Issues
- Make sure the database schema is properly set up using the migration files
- Check that all required tables exist

### Build Issues
- Ensure all Go dependencies are installed: `go mod tidy`
- Verify Go version compatibility

## SQLC Code Generation

To regenerate the SQLC code after modifying SQL queries:

```bash
sqlc generate
```

Make sure you have SQLC installed and the `sqlc.yaml` configuration is properly set up.

## Dependencies

- `github.com/lib/pq` - PostgreSQL driver
- `github.com/google/uuid` - UUID generation and handling
- `github.com/shopspring/decimal` - Decimal number handling for financial data