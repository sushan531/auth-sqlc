-- name: InsertCategory :one
INSERT INTO category (name, description, organization_id)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetCategory :one
SELECT * FROM category
WHERE id = $1;

-- name: GetCategoryByName :one
SELECT * FROM category
WHERE name = $1 AND organization_id = $2;

-- name: ListCategories :many
SELECT * FROM category
WHERE organization_id = $1
ORDER BY name;

-- name: ConditionalUpdateCategory :one
UPDATE category
SET name = coalesce(sqlc.narg('name'), name),
    description = coalesce(sqlc.narg('description'), description),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;

-- name: DeleteCategory :exec
DELETE FROM category
WHERE id = $1;

-- name: InsertProduct :one
INSERT INTO product (
    name, description, category_id, cost_price, selling_price,
    quantity_in_stock, reorder_level, unit_of_measure,
    sub_unit_of_measure, sub_unit_conversion, is_active, image_url,
    organization_id, branch_id
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
RETURNING *;

-- name: GetProduct :one
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.id = $1;

-- name: GetProductByName :one
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.name = $1 AND p.branch_id = $2;

-- name: ListProducts :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.branch_id = $1 AND p.is_active = true
ORDER BY p.name;

-- name: ListProductsByCategory :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.category_id = $1 AND p.branch_id = $2 AND p.is_active = true
ORDER BY p.name;

-- name: ListLowStockProducts :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.branch_id = $1 AND p.quantity_in_stock <= p.reorder_level AND p.is_active = true
ORDER BY p.quantity_in_stock ASC;

-- name: ConditionalUpdateProduct :one
UPDATE product
SET name = coalesce(sqlc.narg('name'), name),
    description = coalesce(sqlc.narg('description'), description),
    category_id = coalesce(sqlc.narg('category_id'), category_id),
    cost_price = coalesce(sqlc.narg('cost_price'), cost_price),
    selling_price = coalesce(sqlc.narg('selling_price'), selling_price),
    quantity_in_stock = coalesce(sqlc.narg('quantity_in_stock'), quantity_in_stock),
    reorder_level = coalesce(sqlc.narg('reorder_level'), reorder_level),
    unit_of_measure = coalesce(sqlc.narg('unit_of_measure'), unit_of_measure),
    sub_unit_of_measure = coalesce(sqlc.narg('sub_unit_of_measure'), sub_unit_of_measure),
    sub_unit_conversion = coalesce(sqlc.narg('sub_unit_conversion'), sub_unit_conversion),
    is_active = coalesce(sqlc.narg('is_active'), is_active),
    image_url = coalesce(sqlc.narg('image_url'), image_url),
    updated_at = NOW()
WHERE id = sqlc.arg('id')
RETURNING *;


-- name: DeactivateProduct :one
UPDATE product
SET is_active = false, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: ActivateProduct :one
UPDATE product
SET is_active = true, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteProduct :exec
DELETE FROM product
WHERE id = $1;

-- name: SearchProducts :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.branch_id = $2 
  AND (p.name ILIKE '%' || $1 || '%' OR p.description ILIKE '%' || $1 || '%')
  AND p.is_active = true
ORDER BY p.name;

-- name: CountProductsByCategory :one
SELECT COUNT(*) FROM product
WHERE category_id = $1 AND branch_id = $2 AND is_active = true;

-- name: ListProductsByOrganization :many
SELECT p.*, c.name as category_name, b.branch_name
FROM product p
JOIN category c ON p.category_id = c.id
JOIN branches b ON p.branch_id = b.id
WHERE p.organization_id = $1 AND p.is_active = true
ORDER BY b.branch_name, p.name;

-- name: ListCategoriesByOrganization :many
SELECT * FROM category
WHERE organization_id = $1
ORDER BY name;

-- name: GetProductsByUserBranches :many
SELECT p.*, c.name as category_name, b.branch_name
FROM product p
JOIN category c ON p.category_id = c.id
JOIN branches b ON p.branch_id = b.id
JOIN user_organization_branches uob ON p.organization_id = uob.organization_id
WHERE uob.user_profile_id = $1 
  AND p.branch_id = ANY(uob.branch_uuids)
  AND p.is_active = true
ORDER BY b.branch_name, p.name;

-- name: CountProductsByBranch :one
SELECT COUNT(*) FROM product
WHERE branch_id = $1 AND is_active = true;

-- name: CountCategoriesByOrganization :one
SELECT COUNT(*) FROM category
WHERE organization_id = $1;