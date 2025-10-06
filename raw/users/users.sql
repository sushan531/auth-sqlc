-- name: InsertAuth :one
INSERT INTO auth (user_email, password, organization_id, role, branch_uuids)
VALUES ($1, $2, $3, $4, $5)
    RETURNING *;

-- name: GetAuth :one
SELECT user_email, organization_id, role, password, branch_uuids
FROM auth
WHERE user_email = $1;

-- name: GetUserByEmail :one
SELECT user_email, organization_id, role, branch_uuids
FROM auth
WHERE user_email = $1;

-- name: GetAllUsers :many
SELECT user_email, role, branch_uuids
FROM auth
WHERE organization_id = $1;


-- name: ConditionalUpdateAuth :one
UPDATE auth
SET password     = CASE
                       WHEN $1::INT = 1 THEN $2
                       ELSE password
END,
    branch_uuids = CASE
                       WHEN $3::INT = 1 THEN $4
                       ELSE branch_uuids
END,
    role         = CASE
                       WHEN $5::INT = 1 THEN $6
                       ELSE role
END
WHERE user_email = $7
  AND organization_id = $8
RETURNING *;

-- name: InsertOrganization :one
INSERT INTO organization (name)
VALUES ($1)
    RETURNING *;


-- name: GetOrganization :one
SELECT *
FROM organization
WHERE name = $1;

