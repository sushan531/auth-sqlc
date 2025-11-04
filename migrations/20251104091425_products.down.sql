-- Drop indexes
DROP INDEX IF EXISTS idx_category_organization_id;
DROP INDEX IF EXISTS idx_category_name;
DROP INDEX IF EXISTS idx_product_branch_active;
DROP INDEX IF EXISTS idx_product_branch_id;
DROP INDEX IF EXISTS idx_product_organization_id;
DROP INDEX IF EXISTS idx_product_is_active;
DROP INDEX IF EXISTS idx_product_name;
DROP INDEX IF EXISTS idx_product_category_id;

-- Drop tables (product first due to foreign key constraint)
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS category;