-- name: InsertCategory :one
INSERT INTO category (name, description)
VALUES ($1, $2)
RETURNING *;

-- name: GetCategory :one
SELECT * FROM category
WHERE id = $1;

-- name: GetCategoryByName :one
SELECT * FROM category
WHERE name = $1;

-- name: ListCategories :many
SELECT * FROM category
ORDER BY name;

-- name: UpdateCategory :one
UPDATE category
SET name = $2, description = $3
WHERE id = $1
RETURNING *;

-- name: DeleteCategory :exec
DELETE FROM category
WHERE id = $1;

-- name: InsertProduct :one
INSERT INTO product (
    name, description, category_id, cost_price, selling_price,
    quantity_in_stock, reorder_level, unit_of_measure,
    sub_unit_of_measure, sub_unit_conversion, is_active, image_url
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
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
WHERE p.name = $1;

-- name: ListProducts :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.is_active = true
ORDER BY p.name;

-- name: ListProductsByCategory :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.category_id = $1 AND p.is_active = true
ORDER BY p.name;

-- name: ListLowStockProducts :many
SELECT p.*, c.name as category_name
FROM product p
JOIN category c ON p.category_id = c.id
WHERE p.quantity_in_stock <= p.reorder_level AND p.is_active = true
ORDER BY p.quantity_in_stock ASC;

-- name: UpdateProduct :one
UPDATE product
SET name = $2, description = $3, category_id = $4, cost_price = $5,
    selling_price = $6, quantity_in_stock = $7, reorder_level = $8,
    unit_of_measure = $9, sub_unit_of_measure = $10, sub_unit_conversion = $11,
    is_active = $12, image_url = $13, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateProductStock :one
UPDATE product
SET quantity_in_stock = $2, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateProductPrices :one
UPDATE product
SET cost_price = $2, selling_price = $3, updated_at = NOW()
WHERE id = $1
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
WHERE (p.name ILIKE '%' || $1 || '%' OR p.description ILIKE '%' || $1 || '%')
  AND p.is_active = true
ORDER BY p.name;

-- name: CountProductsByCategory :one
SELECT COUNT(*) FROM product
WHERE category_id = $1 AND is_active = true;