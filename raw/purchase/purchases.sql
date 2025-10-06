-- name: InsertOrUpdateProductsWithPurchasesAndPurchaseGroup :many
WITH new_group AS (
INSERT INTO purchase_group (
    supplier,
    total_cost,
    payment_method,
    branch_uuid,
    user_email,
    comments,
    partner_id,
    organization_id
) VALUES ($1, -- supplier
    $2, -- total_cost
    $3, -- payment_method
    $4, -- branch_uuid
    $5, -- user_email
    $6, -- comments
    $7, -- partner_id
    $8 -- organization_id
    )
    RETURNING purchase_group_id),
    input_data AS (SELECT unnest($9::text[])     AS product_name,
    unnest($10::text[])    AS unique_name,
    unnest($11::numeric[]) AS unit_purchase_price,
    unnest($12::numeric[]) AS units,
    unnest($13::numeric[]) AS selling_price,
    unnest($14::text[])    AS measurement_unit),
    upserted_products AS (
INSERT INTO products (
    product_name,
    unique_name,
    selling_price,
    remaining_quantity,
    branch_uuid,
    measurement_unit,
    organization_id
)
SELECT i.product_name,
    i.unique_name,
    i.selling_price,
    i.units, -- initial quantity
    $4,      -- branch_uuid
    i.measurement_unit::measurement_unit_types,
    $8       -- organization_id
FROM input_data i
ON CONFLICT (unique_name) DO UPDATE
    SET remaining_quantity = products.remaining_quantity + EXCLUDED.remaining_quantity,
    selling_price = EXCLUDED.selling_price
    RETURNING product_id, unique_name, product_name)
INSERT
INTO purchases (purchase_group_id,
                product_id,
                product_name,
                unit_purchase_price,
                units,
                branch_uuid,
                organization_id)
SELECT (SELECT purchase_group_id FROM new_group),
       p.product_id,
       p.product_name,
       i.unit_purchase_price,
       i.units,
       $4, -- branch_uuid
       $8  -- organization_id
FROM input_data i
         JOIN upserted_products p ON p.unique_name = i.unique_name
    RETURNING *;


-- name: GetGroupedPurchasesNext :many
SELECT pg.purchase_group_id,
       pg.supplier,
       pg.total_cost,
       pg.purchase_date,
       pg.payment_method,
       pg.branch_uuid,
       pg.user_email,
       pg.comments,
       pg.partner_id,
--        pt.partner_name,
       pg.organization_id,
       json_agg(json_build_object(
               'purchase_id', p.purchase_id,
               'product_id', p.product_id,
               'product_name', p.product_name,
               'unit_purchase_price', p.unit_purchase_price,
               'units', p.units,
               'branch_uuid', p.branch_uuid,
               'organization_id', p.organization_id
                )) AS purchase_items
FROM purchase_group pg
         LEFT JOIN purchases p ON pg.purchase_group_id = p.purchase_group_id
         LEFT JOIN partners pt ON pg.partner_id = pt.partner_id
WHERE pg.purchase_group_id < $1
  AND pg.branch_uuid = $2
  AND pg.organization_id = $3
  AND pt.partner_name like $4
  AND (cast($5 as date) IS NULL OR pg.purchase_date >= $5)
  AND (cast($6 as date) IS NULL OR pg.purchase_date <= $6)

GROUP BY pg.purchase_group_id
ORDER BY pg.purchase_group_id DESC
    LIMIT $7;


-- name: DeletePurchase :exec
DELETE
FROM purchases
WHERE purchase_id = $1
  AND organization_id = $2;

-- name: GetPurchase :one
SELECT *
FROM purchases
WHERE purchases.purchase_id = $1
  AND branch_uuid = $2
  AND organization_id = $3;



-- -- name: ConditionalUpdatePurchase :one
-- UPDATE purchases
-- SET product_id          = CASE
--                               WHEN $1::INT = 1 THEN $2
--                               ELSE product_id
--     END,
--     product_name        = CASE
--                               WHEN $3::INT = 1 THEN $4
--                               ELSE product_name
--         END,
--     unit_purchase_price = CASE
--                               WHEN $5::INT = 1 THEN $6
--                               ELSE unit_purchase_price
--         END,
--     units               = CASE
--                               WHEN $7::INT = 1 THEN $8
--                               ELSE units
--         END,
--     purchase_date       = CASE
--                               WHEN $9::INT = 1 THEN $10
--                               ELSE purchase_date
--         END,
--     supplier            = CASE
--                               WHEN $11::INT = 1 THEN $12
--                               ELSE supplier
--         END,
--     comments            = CASE
--                               WHEN $13::INT = 1 THEN $14
--                               ELSE comments
--         END,
--     total_cost          = CASE
--                               WHEN $15::INT = 1 THEN $16
--                               ELSE total_cost
--         END
-- WHERE purchase_id = $17
--   AND branch_uuid = $18
--   AND organization_id = $19
-- RETURNING *;