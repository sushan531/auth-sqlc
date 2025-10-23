-- Organization CRUD Operations

-- name: CreateOrganization :one
INSERT INTO organization (name)
VALUES ($1)
RETURNING id, name;

-- name: UpdateOrganization :one
UPDATE organization
SET name = $2
WHERE id = $1
RETURNING id, name;

-- name: DeleteOrganization :exec
DELETE FROM organization
WHERE id = $1;


-- name: OrganizationExists :one
SELECT EXISTS(
    SELECT 1 FROM organization WHERE id = $1
);

-- name: OrganizationNameExists :one
SELECT EXISTS(
    SELECT 1 FROM organization WHERE name = $1
);

-- name: CreateOrganizationWithUser :one
WITH new_org AS (
    INSERT INTO organization (name)
    VALUES ($1)
    RETURNING id, name
),
user_org_link AS (
    INSERT INTO user_organization_branches (organization_id, user_profile_id)
    SELECT new_org.id, $2
    FROM new_org
    RETURNING organization_id, user_profile_id
)
SELECT new_org.id, new_org.name
FROM new_org;
