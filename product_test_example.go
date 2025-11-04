package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"github.com/shopspring/decimal"
	"github.com/sushan531/auth-sqlc/generated"
)

func TestProductOperations() {
	dbURL := "postgresql://myuser:mypassword@localhost:5432/mydb?sslmode=disable"
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	queries := generated.New(db)
	ctx := context.Background()

	fmt.Println("=== Testing Product Operations ===")

	// Test 1: Create a category
	fmt.Println("\n1. Creating category...")
	category, err := queries.InsertCategory(ctx, generated.InsertCategoryParams{
		Name:        "Electronics",
		Description: sql.NullString{String: "Electronic devices and accessories", Valid: true},
	})
	if err != nil {
		log.Printf("Error creating category: %v", err)
		return
	}
	fmt.Printf("Created category: %s (ID: %s)\n", category.Name, category.ID)

	// Test 2: Create a product
	fmt.Println("\n2. Creating product...")
	product, err := queries.InsertProduct(ctx, generated.InsertProductParams{
		Name:              "iPhone 15 Pro",
		Description:       sql.NullString{String: "Latest iPhone with advanced features", Valid: true},
		CategoryID:        category.ID,
		CostPrice:         decimal.NewFromFloat(800.00),
		SellingPrice:      decimal.NewFromFloat(999.99),
		QuantityInStock:   50,
		ReorderLevel:      10,
		UnitOfMeasure:     "pcs",
		SubUnitOfMeasure:  sql.NullString{},
		SubUnitConversion: sql.NullString{},
		IsActive:          sql.NullBool{Bool: true, Valid: true},
		ImageUrl:          sql.NullString{String: "https://example.com/iphone15.jpg", Valid: true},
	})
	if err != nil {
		log.Printf("Error creating product: %v", err)
		return
	}
	fmt.Printf("Created product: %s (ID: %s)\n", product.Name, product.ID)
	fmt.Printf("Cost: $%s, Selling: $%s, Stock: %d\n",
		product.CostPrice.String(), product.SellingPrice.String(), product.QuantityInStock)

	// Test 3: Get product with category info
	fmt.Println("\n3. Retrieving product with category...")
	productWithCategory, err := queries.GetProduct(ctx, product.ID)
	if err != nil {
		log.Printf("Error getting product: %v", err)
		return
	}
	fmt.Printf("Product: %s, Category: %s\n", productWithCategory.Name, productWithCategory.CategoryName)

	// Test 4: List all products
	fmt.Println("\n4. Listing all products...")
	products, err := queries.ListProducts(ctx)
	if err != nil {
		log.Printf("Error listing products: %v", err)
		return
	}
	fmt.Printf("Found %d products:\n", len(products))
	for _, p := range products {
		fmt.Printf("- %s (%s) - Stock: %d\n", p.Name, p.CategoryName, p.QuantityInStock)
	}

	// Test 5: Update product stock
	fmt.Println("\n5. Updating product stock...")
	updatedProduct, err := queries.UpdateProductStock(ctx, generated.UpdateProductStockParams{
		ID:              product.ID,
		QuantityInStock: 25,
	})
	if err != nil {
		log.Printf("Error updating stock: %v", err)
		return
	}
	fmt.Printf("Updated stock for %s: %d -> %d\n",
		updatedProduct.Name, product.QuantityInStock, updatedProduct.QuantityInStock)

	// Test 6: Check low stock products
	fmt.Println("\n6. Checking low stock products...")
	lowStockProducts, err := queries.ListLowStockProducts(ctx)
	if err != nil {
		log.Printf("Error getting low stock products: %v", err)
		return
	}
	if len(lowStockProducts) > 0 {
		fmt.Printf("Low stock products (%d):\n", len(lowStockProducts))
		for _, p := range lowStockProducts {
			fmt.Printf("- %s: %d (reorder at %d)\n", p.Name, p.QuantityInStock, p.ReorderLevel)
		}
	} else {
		fmt.Println("No low stock products found")
	}

	// Test 7: Search products
	fmt.Println("\n7. Searching products...")
	searchResults, err := queries.SearchProducts(ctx, sql.NullString{String: "iPhone", Valid: true})
	if err != nil {
		log.Printf("Error searching products: %v", err)
		return
	}
	fmt.Printf("Search results for 'iPhone' (%d):\n", len(searchResults))
	for _, p := range searchResults {
		fmt.Printf("- %s (%s)\n", p.Name, p.CategoryName)
	}

	fmt.Println("\n=== Product Operations Test Complete ===")
}
