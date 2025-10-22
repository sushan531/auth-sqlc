package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"github.com/google/uuid"
	_ "github.com/lib/pq"
	"github.com/sushan531/auth-sqlc/generated"
)

// Example usage of the new Organization CRUD operations with cascading deletes and cursor pagination
func demonstrateOrganizationOperations() {
	// Database connection setup
	dbURL := "postgres://user:pass@localhost:5432/dbname?sslmode=disable"
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	queries := generated.New(db)
	ctx := context.Background()

	// 1. Create organizations
	fmt.Println("=== Creating Organizations ===")
	org1, err := queries.CreateOrganizationWithID(ctx, "Tech Corp Ltd")
	if err != nil {
		log.Printf("Error creating org1: %v", err)
		return
	}
	fmt.Printf("Created: %s (ID: %s)\n", org1.Name, org1.ID)

	org2, err := queries.CreateOrganizationWithID(ctx, "Business Solutions Inc")
	if err != nil {
		log.Printf("Error creating org2: %v", err)
		return
	}
	fmt.Printf("Created: %s (ID: %s)\n", org2.Name, org2.ID)

	// 2. Cursor-based pagination examples
	fmt.Println("\n=== Cursor-based Pagination ===")

	// First page (no cursor)
	firstPage, err := queries.ListOrganizationsWithCursorPagination(ctx, generated.ListOrganizationsWithCursorPaginationParams{
		Column1: uuid.Nil, // No cursor for first page
		Limit:   5,
	})
	if err != nil {
		log.Printf("Error getting first page: %v", err)
		return
	}

	fmt.Printf("First page (%d organizations):\n", len(firstPage))
	for _, org := range firstPage {
		fmt.Printf("  - %s (ID: %s)\n", org.Name, org.ID)
	}

	// Next page using last ID as cursor
	if len(firstPage) > 0 {
		lastID := firstPage[len(firstPage)-1].ID
		nextPage, err := queries.ListOrganizationsWithCursorPagination(ctx, generated.ListOrganizationsWithCursorPaginationParams{
			Column1: lastID,
			Limit:   5,
		})
		if err != nil {
			log.Printf("Error getting next page: %v", err)
			return
		}

		fmt.Printf("Next page (%d organizations):\n", len(nextPage))
		for _, org := range nextPage {
			fmt.Printf("  - %s (ID: %s)\n", org.Name, org.ID)
		}
	}

	// 3. Name-based cursor pagination
	fmt.Println("\n=== Name-based Cursor Pagination ===")
	nameBasedPage, err := queries.ListOrganizationsWithNameCursor(ctx, generated.ListOrganizationsWithNameCursorParams{
		Column1: "", // Start from beginning
		Limit:   3,
	})
	if err != nil {
		log.Printf("Error getting name-based page: %v", err)
		return
	}

	fmt.Printf("Name-based pagination (%d organizations):\n", len(nameBasedPage))
	for _, org := range nameBasedPage {
		fmt.Printf("  - %s (ID: %s)\n", org.Name, org.ID)
	}

	// 4. Organization statistics
	fmt.Println("\n=== Organization Statistics ===")
	stats, err := queries.GetOrganizationStats(ctx)
	if err != nil {
		log.Printf("Error getting stats: %v", err)
		return
	}

	fmt.Printf("Total Organizations: %d\n", stats.TotalOrganizations)
	fmt.Printf("Organizations with Branches: %d\n", stats.OrganizationsWithBranches)
	fmt.Printf("Organizations with Products: %d\n", stats.OrganizationsWithProducts)

	// 5. Organizations with related counts
	fmt.Println("\n=== Organizations with Related Counts ===")
	orgsWithCounts, err := queries.ListOrganizationsWithRelatedCounts(ctx, generated.ListOrganizationsWithRelatedCountsParams{
		Column1: uuid.Nil,
		Limit:   10,
	})
	if err != nil {
		log.Printf("Error getting organizations with counts: %v", err)
		return
	}

	for _, org := range orgsWithCounts {
		fmt.Printf("Organization: %s\n", org.Name)
		fmt.Printf("  - Branches: %d\n", org.BranchCount)
		fmt.Printf("  - Products: %d\n", org.ProductCount)
		fmt.Printf("  - Users: %d\n", org.UserCount)
	}

	// 6. Cascading delete demonstration
	fmt.Println("\n=== Cascading Delete ===")
	fmt.Printf("Deleting organization: %s\n", org1.Name)

	// This will cascade delete all related records (branches, products, etc.)
	deletedOrg, err := queries.DeleteOrganizationCascade(ctx, org1.ID)
	if err != nil {
		log.Printf("Error deleting organization: %v", err)
		return
	}

	fmt.Printf("Successfully deleted: %s (ID: %s)\n", deletedOrg.Name, deletedOrg.ID)
	fmt.Println("All related records (branches, products, sales, etc.) were automatically deleted due to CASCADE constraints")

	// 7. Verify organization exists checks
	fmt.Println("\n=== Existence Checks ===")
	exists, err := queries.OrganizationExists(ctx, org1.ID)
	if err != nil {
		log.Printf("Error checking existence: %v", err)
		return
	}
	fmt.Printf("Organization %s exists: %t\n", org1.ID, exists)

	nameExists, err := queries.OrganizationNameExists(ctx, "Tech Corp Ltd")
	if err != nil {
		log.Printf("Error checking name existence: %v", err)
		return
	}
	fmt.Printf("Organization name 'Tech Corp Ltd' exists: %t\n", nameExists)
}

func main() {
	demonstrateOrganizationOperations()
}
