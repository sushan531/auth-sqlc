-- name: InsertBranch :one
INSERT INTO branches (unique_name, branch_name, organization_id)
VALUES ($1, $2, $3)
    RETURNING *;


-- name: GetBranchToProductMapping :many
SELECT DISTINCT p.product_name, b.branch_name
FROM products p
         INNER JOIN branches b ON p.branch_uuid = b.id
WHERE b.organization_id = $1
GROUP BY b.branch_name, p.product_name;


-- name: GetBranchToProductMappingFiltered :many
SELECT DISTINCT p.product_name, b.branch_name
FROM products p
         INNER JOIN branches b ON p.branch_uuid = b.id
         INNER JOIN auth a ON (a.branch_uuids @> '{p.branch_uuid}') -- Check if branches UUID is in users's branches list (text array)
WHERE a.user_email = $1
  AND b.organization_id = $2
GROUP BY p.product_name, b.branch_name;


-- name: GetOrganizationBranches :many
SELECT id, branch_name
FROM branches
WHERE organization_id = $1;


-- name: GetUserBranchesUnNested :many
SELECT unnest(branch_uuids)
FROM auth
WHERE user_email = $1;