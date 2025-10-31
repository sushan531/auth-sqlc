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

--Branch Operations

-- name: CreateBranchAndUpdateUserAccess :one
WITH new_branch AS (
    INSERT INTO branches (unique_name, branch_name, organization_id)
    VALUES ($1, $2, $3)
    RETURNING id, unique_name, branch_name, organization_id
),
update_user_branches AS (
    UPDATE user_organization_branches
    SET branch_uuids = array_append(branch_uuids, (SELECT id FROM new_branch))
    WHERE user_profile_id = $4 AND organization_id = $3
    RETURNING user_profile_id, organization_id, branch_uuids
)
SELECT nb.id, nb.unique_name, nb.branch_name, nb.organization_id
FROM new_branch nb;

-- name: RemoveBranchFromUserAccess :exec
UPDATE user_organization_branches
SET branch_uuids = array_remove(branch_uuids, $1)
WHERE user_profile_id = $2 AND organization_id = $3;

-- name: DeleteBranch :exec
DELETE FROM branches
WHERE id = $1;

-- name: RemoveBranchFromUserAccessAndDelete :exec
WITH remove_from_users AS (
    UPDATE user_organization_branches
    SET branch_uuids = array_remove(branch_uuids, $1)
    WHERE user_organization_branches.organization_id = $2
    RETURNING user_organization_branches.organization_id
)
DELETE FROM branches
WHERE branches.id = $1;

-- name: GetUserOrganizationBranchDetailsById :many
SELECT
    up.id as user_profile_id,
    up.full_name,
    up.user_role,
    a.user_email,
    o.id as organization_id,
    o.name as organization_name,
    uob.branch_uuids,
    COALESCE(
        array_agg(
            json_build_object(
                'branch_id', b.id,
                'unique_name', b.unique_name,
                'branch_name', b.branch_name
            )
        ) FILTER (WHERE b.id IS NOT NULL),
        '{}'::json[]
    ) as branch_details
FROM user_profile up
INNER JOIN auth a ON up.id = a.user_profile_id
INNER JOIN user_organization_branches uob ON up.id = uob.user_profile_id
INNER JOIN organization o ON uob.organization_id = o.id
LEFT JOIN branches b ON b.id = ANY(uob.branch_uuids) AND b.organization_id = o.id
WHERE up.id = $1
GROUP BY up.id, up.full_name, up.user_role, a.user_email, o.id, o.name, uob.branch_uuids;

-- name: GetUserOrganizationBranchDetailsByEmail :many
SELECT 
    up.id as user_profile_id,
    up.full_name,
    up.user_role,
    a.user_email,
    o.id as organization_id,
    o.name as organization_name,
    uob.branch_uuids,
    COALESCE(
        array_agg(
            json_build_object(
                'branch_id', b.id,
                'unique_name', b.unique_name,
                'branch_name', b.branch_name
            )
        ) FILTER (WHERE b.id IS NOT NULL),
        '{}'::json[]
    ) as branch_details
FROM user_profile up
INNER JOIN auth a ON up.id = a.user_profile_id
INNER JOIN user_organization_branches uob ON up.id = uob.user_profile_id
INNER JOIN organization o ON uob.organization_id = o.id
LEFT JOIN branches b ON b.id = ANY(uob.branch_uuids) AND b.organization_id = o.id
WHERE a.user_email = $1
GROUP BY up.id, up.full_name, up.user_role, a.user_email, o.id, o.name, uob.branch_uuids;

-- name: GetAllBranchesForOrganization :many
SELECT id, unique_name, branch_name, organization_id
FROM branches
WHERE organization_id = $1
ORDER BY branch_name;

-- name: GetBranchById :one
SELECT id, unique_name, branch_name, organization_id
FROM branches
WHERE id = $1;

-- name: UpdateBranch :one
UPDATE branches
SET unique_name = $2, branch_name = $3
WHERE id = $1
RETURNING id, unique_name, branch_name, organization_id;

