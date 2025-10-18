-- name: InsertUserProfile :one
WITH user_profile_insert AS (
INSERT INTO user_profile (full_name, address, user_role)
VALUES ($1, $2, $3)
    RETURNING id
)
INSERT INTO auth (user_email, password, user_profile_id)
VALUES ($4, $5, (SELECT id FROM user_profile_insert))
    RETURNING *;


-- name: GetUserProfile :one
SELECT up.full_name, up.user_role, a.user_email
FROM user_profile up
INNER JOIN auth a USING (id)
WHERE a.user_email = $1;

-- name: GetUserKeySet :one
SELECT user_profile_id, keyset_data, encryption_key
FROM auth
WHERE user_profile_id = $1;

-- name: DeleteUserKeySet :one
UPDATE auth
SET keyset_data = '',  encryption_key = ''
WHERE user_profile_id = $1
RETURNING *;

-- name: GetAllUserKeySet :many
SELECT user_profile_id, keyset_data, encryption_key
FROM auth
ORDER BY id DESC;

-- name: GetUserAuth :one
SELECT user_email, password, user_profile_id
FROM auth
WHERE user_email = $1;


-- name: ConditionalUpdateAuth :one
UPDATE auth
SET password        = CASE
                       WHEN $1::INT = 1 THEN $2
                       ELSE password
END,
    keyset_data     = CASE
                       WHEN $3::INT = 1 THEN $4
                       ELSE keyset_data
END,
    encryption_key  = CASE
                       WHEN $5::INT = 1 THEN $6
                       ELSE encryption_key
END
WHERE user_profile_id = $7
RETURNING *;

-- name: InsertOrganization :one
INSERT INTO organization (name)
VALUES ($1)
    RETURNING *;


-- name: GetOrganization :one
SELECT *
FROM organization
WHERE name = $1;

