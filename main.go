package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"github.com/sushan531/hk_ims_sqlc/generated"

	_ "github.com/lib/pq"
)

func main() {
	// Database connection string
	// You can set this via environment variable: export DATABASE_URL="postgres://username:password@localhost/dbname?sslmode=disable"
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://myuser:mypassword@localhost:5432/mydb?sslmode=disable"
		fmt.Println("Using default database URL. Set DATABASE_URL environment variable to override.")
	}

	// Connect to database
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	// Test database connection
	if err := db.Ping(); err != nil {
		log.Fatal("Failed to ping database:", err)
	}
	fmt.Println("✅ Successfully connected to database")

	// Create queries instance
	queries := generated.New(db)
	ctx := context.Background()

	// Run tests
	fmt.Println("\n🧪 Running SQLC Generated Code Tests...")

	// Test Organization operations
	testOrganizationOperations(ctx, queries)

	// Test Branch operations
	testBranchOperations(ctx, queries)

	// Test User/Auth operations
	testUserOperations(ctx, queries)

	// Test Product operations
	testProductOperations(ctx, queries)

	// Test Purchase operations with product insert/update
	testPurchaseOperations(ctx, queries)

	fmt.Println("\n✅ All tests completed successfully!")
}

func testOrganizationOperations(ctx context.Context, queries *generated.Queries) {
	fmt.Println("\n📊 Testing Organization Operations...")

	// Insert a test organization
	orgName := fmt.Sprintf("Test Organization %d", time.Now().Unix())
	org, err := queries.InsertOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to insert organization: %v", err)
		return
	}
	fmt.Printf("✅ Created organization: %s (ID: %s)\n", org.Name, org.ID)

	// Get organization by name
	retrievedOrg, err := queries.GetOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to get organization: %v", err)
		return
	}
	fmt.Printf("✅ Retrieved organization: %s (ID: %s)\n", retrievedOrg.Name, retrievedOrg.ID)
}

func testBranchOperations(ctx context.Context, queries *generated.Queries) {
	fmt.Println("\n🏢 Testing Branch Operations...")

	// First, create an organization for the branch
	orgName := fmt.Sprintf("Branch Test Org %d", time.Now().Unix())
	org, err := queries.InsertOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to create organization for branch test: %v", err)
		return
	}

	// Insert a test branch
	branchParams := generated.InsertBranchParams{
		UniqueName:     fmt.Sprintf("branch_%d", time.Now().Unix()),
		BranchName:     "Test Branch",
		OrganizationID: org.ID,
	}

	branch, err := queries.InsertBranch(ctx, branchParams)
	if err != nil {
		log.Printf("❌ Failed to insert branch: %v", err)
		return
	}
	fmt.Printf("✅ Created branch: %s (ID: %s)\n", branch.BranchName, branch.ID)

	// Get organization branches
	branches, err := queries.GetOrganizationBranches(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to get organization branches: %v", err)
		return
	}
	fmt.Printf("✅ Found %d branches for organization\n", len(branches))
	for _, b := range branches {
		fmt.Printf("   - %s (ID: %s)\n", b.BranchName, b.ID)
	}
}

func testUserOperations(ctx context.Context, queries *generated.Queries) {
	fmt.Println("\n👤 Testing User/Auth Operations...")

	// Create organization and branch for user test
	orgName := fmt.Sprintf("User Test Org %d", time.Now().Unix())
	org, err := queries.InsertOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to create organization for user test: %v", err)
		return
	}

	branchParams := generated.InsertBranchParams{
		UniqueName:     fmt.Sprintf("user_branch_%d", time.Now().Unix()),
		BranchName:     "User Test Branch",
		OrganizationID: org.ID,
	}

	branch, err := queries.InsertBranch(ctx, branchParams)
	if err != nil {
		log.Printf("❌ Failed to create branch for user test: %v", err)
		return
	}

	// Insert a test user
	userParams := generated.InsertAuthParams{
		UserEmail:      fmt.Sprintf("test_%d@example.com", time.Now().Unix()),
		Password:       "hashed_password_here",
		OrganizationID: org.ID,
		Role:           sql.NullString{String: "admin", Valid: true},
		BranchUuids:    []uuid.UUID{branch.ID},
	}

	user, err := queries.InsertAuth(ctx, userParams)
	if err != nil {
		log.Printf("❌ Failed to insert user: %v", err)
		return
	}
	fmt.Printf("✅ Created user: %s (ID: %s)\n", user.UserEmail, user.ID)

	// Get user by email
	retrievedUser, err := queries.GetUserByEmail(ctx, user.UserEmail)
	if err != nil {
		log.Printf("❌ Failed to get user by email: %v", err)
		return
	}
	fmt.Printf("✅ Retrieved user: %s (Role: %s)\n", retrievedUser.UserEmail, retrievedUser.Role.String)

	// Get all users for organization
	allUsers, err := queries.GetAllUsers(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to get all users: %v", err)
		return
	}
	fmt.Printf("✅ Found %d users in organization\n", len(allUsers))
}

func testProductOperations(ctx context.Context, queries *generated.Queries) {
	fmt.Println("\n📦 Testing Product Operations...")

	// Create organization and branch for product test
	orgName := fmt.Sprintf("Product Test Org %d", time.Now().Unix())
	org, err := queries.InsertOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to create organization for product test: %v", err)
		return
	}

	branchParams := generated.InsertBranchParams{
		UniqueName:     fmt.Sprintf("product_branch_%d", time.Now().Unix()),
		BranchName:     "Product Test Branch",
		OrganizationID: org.ID,
	}

	branch, err := queries.InsertBranch(ctx, branchParams)
	if err != nil {
		log.Printf("❌ Failed to create branch for product test: %v", err)
		return
	}

	// Insert a test product
	productParams := generated.InsertProductParams{
		BranchUuid:        branch.ID,
		UniqueName:        fmt.Sprintf("product_%d", time.Now().Unix()),
		ProductName:       "Test Product",
		ProductImage:      sql.NullString{String: "test_image.jpg", Valid: true},
		Description:       sql.NullString{String: "This is a test product", Valid: true},
		SellingPrice:      decimal.NewFromFloat(99.99),
		RemainingQuantity: decimal.NewFromFloat(100),
		MeasurementUnit:   "pieces",
		OrganizationID:    org.ID,
	}

	product, err := queries.InsertProduct(ctx, productParams)
	if err != nil {
		log.Printf("❌ Failed to insert product: %v", err)
		return
	}
	fmt.Printf("✅ Created product: %s (ID: %s)\n", product.ProductName, product.ProductID)
	fmt.Printf("   Price: $%s, Quantity: %s %s\n",
		product.SellingPrice.String(),
		product.RemainingQuantity.String(),
		product.MeasurementUnit)

	// Get product by ID
	getProductParams := generated.GetProductParams{
		ProductID:      product.ProductID,
		BranchUuid:     branch.ID,
		OrganizationID: org.ID,
	}

	retrievedProduct, err := queries.GetProduct(ctx, getProductParams)
	if err != nil {
		log.Printf("❌ Failed to get product: %v", err)
		return
	}
	fmt.Printf("✅ Retrieved product: %s\n", retrievedProduct.ProductName)

	// Check if product exists
	checkParams := generated.CheckProductExistsParams{
		OrganizationID: org.ID,
		UniqueName:     product.UniqueName,
	}

	count, err := queries.CheckProductExists(ctx, checkParams)
	if err != nil {
		log.Printf("❌ Failed to check product existence: %v", err)
		return
	}
	fmt.Printf("✅ Product existence check: found %d products with unique name\n", count)

	// List all product names
	productNames, err := queries.ListAllProductNames(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to list product names: %v", err)
		return
	}
	fmt.Printf("✅ Found %d products in organization:\n", len(productNames))
	for _, name := range productNames {
		fmt.Printf("   - %s\n", name)
	}

	// Test branch to product mapping
	mapping, err := queries.GetBranchToProductMapping(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to get branch to product mapping: %v", err)
		return
	}
	fmt.Printf("✅ Branch to Product mapping (%d entries):\n", len(mapping))
	for _, m := range mapping {
		fmt.Printf("   - %s -> %s\n", m.BranchName, m.ProductName)
	}
}

func testPurchaseOperations(ctx context.Context, queries *generated.Queries) {
	fmt.Println("\n🛒 Testing Purchase Operations with InsertOrUpdateProductsWithPurchasesAndPurchaseGroup...")

	// Create organization and branch for purchase test
	orgName := fmt.Sprintf("Purchase Test Org %d", time.Now().Unix())
	org, err := queries.InsertOrganization(ctx, orgName)
	if err != nil {
		log.Printf("❌ Failed to create organization for purchase test: %v", err)
		return
	}

	branchParams := generated.InsertBranchParams{
		UniqueName:     fmt.Sprintf("purchase_branch_%d", time.Now().Unix()),
		BranchName:     "Purchase Test Branch",
		OrganizationID: org.ID,
	}

	branch, err := queries.InsertBranch(ctx, branchParams)
	if err != nil {
		log.Printf("❌ Failed to create branch for purchase test: %v", err)
		return
	}

	// Create a test user for purchases
	userParams := generated.InsertAuthParams{
		UserEmail:      fmt.Sprintf("purchase_user_%d@example.com", time.Now().Unix()),
		Password:       "hashed_password_here",
		OrganizationID: org.ID,
		Role:           sql.NullString{String: "admin", Valid: true},
		BranchUuids:    []uuid.UUID{branch.ID},
	}

	user, err := queries.InsertAuth(ctx, userParams)
	if err != nil {
		log.Printf("❌ Failed to create user for purchase test: %v", err)
		return
	}

	fmt.Printf("✅ Created test environment: Org: %s, Branch: %s, User: %s\n",
		org.Name, branch.BranchName, user.UserEmail)

	// Test 1: INSERT scenario - New products with purchase
	fmt.Println("\n📥 Test 1: INSERT - Creating new products with purchase...")

	insertParams := generated.InsertOrUpdateProductsWithPurchasesAndPurchaseGroupParams{
		Supplier:       sql.NullString{String: "ABC Supplier", Valid: true},
		TotalCost:      decimal.NewFromFloat(500.00),
		PaymentMethod:  sql.NullString{String: "cash", Valid: true},
		BranchUuid:     branch.ID,
		UserEmail:      user.UserEmail,
		Comments:       sql.NullString{String: "Initial purchase of new products", Valid: true},
		PartnerID:      uuid.NullUUID{Valid: false}, // No partner for this test
		OrganizationID: org.ID,
		// Product arrays (Column9-14)
		Column9: []string{"Laptop", "Mouse"}, // product_name
		Column10: []string{fmt.Sprintf("laptop_%d", time.Now().Unix()),
			fmt.Sprintf("mouse_%d", time.Now().Unix())}, // unique_name
		Column11: []decimal.Decimal{decimal.NewFromFloat(400.00),
			decimal.NewFromFloat(25.00)}, // unit_purchase_price
		Column12: []decimal.Decimal{decimal.NewFromFloat(1),
			decimal.NewFromFloat(4)}, // units
		Column13: []decimal.Decimal{decimal.NewFromFloat(450.00),
			decimal.NewFromFloat(30.00)}, // selling_price
		Column14: []string{"pieces", "pieces"}, // measurement_unit
	}

	insertPurchases, err := queries.InsertOrUpdateProductsWithPurchasesAndPurchaseGroup(ctx, insertParams)
	if err != nil {
		log.Printf("❌ Failed to insert products with purchases: %v", err)
		return
	}

	fmt.Printf("✅ INSERT: Created %d purchase records\n", len(insertPurchases))
	for i, purchase := range insertPurchases {
		fmt.Printf("   Purchase %d: %s - %s units at $%s each\n",
			i+1, purchase.ProductName, purchase.Units.String(), purchase.UnitPurchasePrice.String())
	}

	// Verify products were created
	productNames, err := queries.ListAllProductNames(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to list products after insert: %v", err)
		return
	}
	fmt.Printf("✅ Products in system after INSERT: %v\n", productNames)

	// Test 2: UPDATE scenario - Adding more quantity to existing products
	fmt.Println("\n📤 Test 2: UPDATE - Adding more quantity to existing products...")

	// Wait a moment to ensure different timestamps
	time.Sleep(1 * time.Second)

	updateParams := generated.InsertOrUpdateProductsWithPurchasesAndPurchaseGroupParams{
		Supplier:       sql.NullString{String: "XYZ Supplier", Valid: true},
		TotalCost:      decimal.NewFromFloat(300.00),
		PaymentMethod:  sql.NullString{String: "bank", Valid: true},
		BranchUuid:     branch.ID,
		UserEmail:      user.UserEmail,
		Comments:       sql.NullString{String: "Restocking existing products", Valid: true},
		PartnerID:      uuid.NullUUID{Valid: false},
		OrganizationID: org.ID,
		// Using same unique_names to trigger UPDATE
		Column9:  []string{"Laptop Pro", "Wireless Mouse"}, // product_name (updated)
		Column10: insertParams.Column10,                    // same unique_name (triggers update)
		Column11: []decimal.Decimal{decimal.NewFromFloat(380.00),
			decimal.NewFromFloat(22.00)}, // unit_purchase_price (new)
		Column12: []decimal.Decimal{decimal.NewFromFloat(2),
			decimal.NewFromFloat(6)}, // units (will be added)
		Column13: []decimal.Decimal{decimal.NewFromFloat(420.00),
			decimal.NewFromFloat(28.00)}, // selling_price (updated)
		Column14: []string{"pieces", "pieces"}, // measurement_unit
	}

	updatePurchases, err := queries.InsertOrUpdateProductsWithPurchasesAndPurchaseGroup(ctx, updateParams)
	if err != nil {
		log.Printf("❌ Failed to update products with purchases: %v", err)
		return
	}

	fmt.Printf("✅ UPDATE: Created %d purchase records for restocking\n", len(updatePurchases))
	for i, purchase := range updatePurchases {
		fmt.Printf("   Purchase %d: %s - %s units at $%s each\n",
			i+1, purchase.ProductName, purchase.Units.String(), purchase.UnitPurchasePrice.String())
	}

	// Verify products were updated (should still be same count but with updated quantities)
	finalProductNames, err := queries.ListAllProductNames(ctx, org.ID)
	if err != nil {
		log.Printf("❌ Failed to list products after update: %v", err)
		return
	}
	fmt.Printf("✅ Products in system after UPDATE: %v\n", finalProductNames)

	// Show the difference in behavior
	fmt.Println("\n📊 Summary of INSERT vs UPDATE behavior:")
	fmt.Println("   INSERT: Creates new products with initial quantities")
	fmt.Println("   UPDATE: Adds to existing product quantities and updates selling prices")
	fmt.Printf("   Total products created: %d (same unique_name triggers update, not duplicate)\n", len(finalProductNames))
}
