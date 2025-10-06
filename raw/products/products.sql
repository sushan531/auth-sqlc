-- name: InsertProduct :one
INSERT INTO products (branch_uuid, unique_name, product_name, product_image, description, selling_price,
                      remaining_quantity,
                      measurement_unit, organization_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    RETURNING *;


-- name: GetAllProductsNext :many
SELECT *
FROM products
WHERE (product_name LIKE $1 OR $1 IS NULL)
  AND branch_uuid = $2
  AND product_id > $3
  AND organization_id = $4
ORDER BY product_id ASC
    LIMIT $5;

-- name: GetAllProductsPrev :many
SELECT *
FROM products
WHERE (product_name LIKE $1 OR $1 IS NULL)
  AND branch_uuid = $2
  AND product_id >= $3
  AND product_id <= $4
  AND organization_id = $5
ORDER BY product_id ASC
    LIMIT $6;


-- name: ConditionalUpdateProduct :one
UPDATE products
SET product_name       = CASE
                             WHEN $1::INT = 1 THEN $2
                             ELSE product_name
END,
    product_image      = CASE
                             WHEN $3::INT = 1 THEN $4
                             ELSE product_image
END,
    description        = CASE
                             WHEN $5::INT = 1 THEN $6
                             ELSE description
END,
    selling_price      = CASE
                             WHEN $7::INT = 1 THEN $8
                             ELSE selling_price
END,
    remaining_quantity = CASE
                             WHEN $9::INT = 1 THEN $10
                             ELSE remaining_quantity
END,
    measurement_unit   = CASE
                             WHEN $11::INT = 1 THEN $12
                             ELSE measurement_unit
END,
    unique_name        = CASE
                             WHEN $13::INT = 1 THEN $14
                             ELSE unique_name
END
WHERE product_id = $15
  AND branch_uuid = $16
  AND organization_id = $17
RETURNING *;


-- name: FindProduct :one
SELECT COUNT(*)
FROM products
WHERE products.product_name = $1
  AND branch_uuid = $2
  AND organization_id = $3;

-- name: GetProduct :one
SELECT *
FROM products
WHERE products.product_id = $1
  AND branch_uuid = $2
  AND organization_id = $3;

-- name: CheckProductExists :one
SELECT COUNT(*)
FROM products
WHERE organization_id = $1
  AND unique_name = $2;


-- name: ListUsersProductNames :many
with user_branches as (select unnest(auth.branch_uuids) as branch_uuid
                       from auth
                       where user_email = $1)
select p.product_name
from products p
         join user_branches ub on p.branch_uuid = ub.branch_uuid
where p.organization_id = $2;

-- name: ListAllProductNames :many
select product_name
from products
where organization_id = $1;