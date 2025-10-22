-- Organization CRUD Operations

-- name: CreateOrganizationWithID :one
INSERT INTO organization (name)
VALUES ($1)
RETURNING id, name;

-- name: GetOrganizationByID :one
SELECT id, name
FROM organization
WHERE id = $1;

-- name: GetOrganizationByName :one
SELECT id, name
FROM organization
WHERE name = $1;

-- name: ListOrganizations :many
SELECT id, name
FROM organization
ORDER BY name;

-- name: ListOrganizationsWithCursorPagination :many
SELECT id, name
FROM organization
WHERE ($1::uuid IS NULL OR id > $1)
ORDER BY id
LIMIT $2;

-- name: UpdateOrganization :one
UPDATE organization
SET name = $2
WHERE id = $1
RETURNING id, name;

-- name: DeleteOrganization :exec
DELETE FROM organization
WHERE id = $1;

-- name: DeleteOrganizationCascade :one
DELETE FROM organization
WHERE id = $1
RETURNING id, name;

-- name: CountOrganizations :one
SELECT COUNT(*) FROM organization;

-- name: OrganizationExists :one
SELECT EXISTS(
    SELECT 1 FROM organization WHERE id = $1
);

-- name: OrganizationNameExists :one
SELECT EXISTS(
    SELECT 1 FROM organization WHERE name = $1
);

-- name: SearchOrganizationsByName :many
SELECT id, name
FROM organization
WHERE name ILIKE '%' || $1 || '%'
ORDER BY name
LIMIT $2;

-- name: ListOrganizationsWithNameCursor :many
SELECT id, name
FROM organization
WHERE ($1::text IS NULL OR name > $1)
ORDER BY name, id
LIMIT $2;

-- name: GetOrganizationStats :one
SELECT 
    COUNT(*) as total_organizations,
    COUNT(CASE WHEN EXISTS(SELECT 1 FROM branches WHERE organization_id = organization.id) THEN 1 END) as organizations_with_branches,
    COUNT(CASE WHEN EXISTS(SELECT 1 FROM products WHERE organization_id = organization.id) THEN 1 END) as organizations_with_products
FROM organization;

-- name: ListOrganizationsWithRelatedCounts :many
SELECT 
    o.id,
    o.name,
    COUNT(DISTINCT b.id) as branch_count,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT u.id) as user_count
FROM organization o
LEFT JOIN branches b ON o.id = b.organization_id
LEFT JOIN products p ON o.id = p.organization_id
LEFT JOIN user_organization_branches uob ON o.id = uob.organization_id
LEFT JOIN user_profile u ON uob.user_profile_id = u.id
WHERE ($1::uuid IS NULL OR o.id > $1)
GROUP BY o.id, o.name
ORDER BY o.id
LIMIT $2;