-- Create User Profile Table
CREATE TABLE IF NOT EXISTS user_profile(
    id          uuid DEFAULT uuidv7() PRIMARY KEY,
    full_name   VARCHAR(255) NOT NULL,
    address     VARCHAR(255),
    user_role   TEXT CHECK (
            user_role IN ('admin', 'adminReadOnly', 'branchManager', 'branchReadOnly', 'sales')
        )
    );


-- Creating the Auth table
CREATE TABLE IF NOT EXISTS auth
(
    id              uuid DEFAULT uuidv7() PRIMARY KEY,
    user_email      VARCHAR(255) NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    keyset_data     TEXT,
    encryption_key  TEXT,
    user_profile_id uuid NOT NULL,
    FOREIGN KEY (user_profile_id) REFERENCES user_profile (id) ON DELETE CASCADE
    );


-- Creating the ParentCompany table
CREATE TABLE IF NOT EXISTS organization
(
    id   uuid DEFAULT uuidv7() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
    );


-- Creating the Branches table
CREATE TABLE IF NOT EXISTS branches
(
    id              uuid DEFAULT uuidv7() PRIMARY KEY,
    unique_name     VARCHAR(255) NOT NULL UNIQUE,
    branch_name     VARCHAR(255) NOT NULL,
    organization_id uuid NOT NULL,
    FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE
    );


-- Create UserOrganizationBranchTable
CREATE TABLE IF NOT EXISTS user_organization_branches(
    id              uuid DEFAULT uuidv7() PRIMARY KEY,
    organization_id uuid NOT NULL,
    user_profile_id uuid NOT NULL,
    branch_uuids    uuid[] DEFAULT '{}', -- changed from TEXT ARRAY to uuid[]
    FOREIGN KEY (user_profile_id) REFERENCES user_profile (id) ON DELETE CASCADE,
    FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE
    );

-- -- Create the ProductsTable
-- CREATE TABLE IF NOT EXISTS products
-- (
--     product_id         uuid DEFAULT uuidv7() PRIMARY KEY,
--     product_name       VARCHAR(255) NOT NULL,
--     unique_name        VARCHAR(255) NOT NULL UNIQUE,
--     product_image      VARCHAR(60000),
--     description        TEXT,
--     selling_price      DECIMAL NOT NULL,
--     remaining_quantity DECIMAL NOT NULL,
--     branch_uuid        uuid NOT NULL, -- changed to uuid
--     measurement_unit   VARCHAR(16) NOT NULL,
--     organization_id    uuid NOT NULL,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE
--     );
--
-- -- Create the SalesGroup table
-- CREATE TABLE IF NOT EXISTS sales_group
-- (
--     sales_group_id  uuid DEFAULT uuidv7() PRIMARY KEY,
--     total_amount    DECIMAL(20, 2) NOT NULL,
--     total_profit    DECIMAL(20, 2) NOT NULL,
--     payment_method  TEXT CHECK (payment_method IN ('cash', 'bank', 'credit')),
--     sold_date       TIMESTAMP NOT NULL DEFAULT NOW(),
--     branch_uuid     uuid NOT NULL,
--     user_profile_id uuid,
--     organization_id uuid NOT NULL,
--     customer_name   VARCHAR(255),
--     comments        TEXT,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (user_profile_id) REFERENCES user_profile (id) ON DELETE SET NULL
--     );
--
-- -- Create the SalesTable
-- CREATE TABLE IF NOT EXISTS sales
-- (
--     sales_id           uuid DEFAULT uuidv7() PRIMARY KEY,
--     sales_group_id     uuid,
--     product_id         uuid NOT NULL,
--     quantity           DECIMAL(20, 2) NOT NULL,
--     current_cost_price DECIMAL(20, 2) NOT NULL,
--     sales_price        DECIMAL(20, 2) NOT NULL,
--     total              DECIMAL(20, 2) NOT NULL,
--     profit             DECIMAL(20, 2) NOT NULL,
--     FOREIGN KEY (product_id) REFERENCES products (product_id),
--     FOREIGN KEY (sales_group_id) REFERENCES sales_group (sales_group_id)
--     );
--
-- -- Create the PartnersTable
-- CREATE TABLE IF NOT EXISTS partners
-- (
--     partner_id      uuid DEFAULT uuidv7() PRIMARY KEY,
--     unique_name     VARCHAR(255) NOT NULL UNIQUE,
--     partner_name    VARCHAR(255) NOT NULL,
--     contact_number  VARCHAR(20),
--     pan_number      INT,
--     address         VARCHAR(255),
--     email           VARCHAR(50),
--     branch_uuid     uuid NOT NULL, -- changed
--     organization_id uuid NOT NULL,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE
--     );
--
-- -- Create the PartnersPaymentReceipt
-- CREATE TABLE IF NOT EXISTS partner_payment_receipt
-- (
--     pr_id           uuid DEFAULT uuidv7() PRIMARY KEY,
--     partner_id      uuid NOT NULL,
--     record_type     TEXT CHECK (record_type IN ('debit', 'credit')),
--     amount          DECIMAL(20, 2) NOT NULL,
--     branch_uuid     uuid NOT NULL, -- changed
--     user_profile_id uuid,
--     comments        TEXT,
--     organization_id uuid NOT NULL,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (user_profile_id) REFERENCES user_profile (id) ON DELETE SET NULL,
--     FOREIGN KEY (partner_id) REFERENCES partners (partner_id) ON DELETE CASCADE,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE
--     );
--
-- -- Create the PurchaseGroup table
-- CREATE TABLE IF NOT EXISTS purchase_group
-- (
--     purchase_group_id uuid DEFAULT uuidv7() PRIMARY KEY,
--     supplier          VARCHAR(255),
--     total_cost        DECIMAL(20, 2) NOT NULL,
--     purchase_date     TIMESTAMP NOT NULL DEFAULT NOW(),
--     payment_method    TEXT CHECK (payment_method IN ('cash', 'bank', 'credit')),
--     branch_uuid       uuid NOT NULL,
--     user_profile_id   uuid,
--     comments          TEXT,
--     partner_id        uuid,
--     organization_id   uuid NOT NULL,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (partner_id) REFERENCES partners (partner_id) ON DELETE SET NULL,
--     FOREIGN KEY (user_profile_id) REFERENCES user_profile (id) ON DELETE SET NULL
--     );
--
-- -- Create the ProductPurchaseTable
-- CREATE TABLE IF NOT EXISTS purchases
-- (
--     purchase_id         uuid DEFAULT uuidv7() PRIMARY KEY,
--     purchase_group_id   uuid,
--     product_id          uuid,
--     product_name        VARCHAR(255) NOT NULL,
--     unit_purchase_price DECIMAL(20, 2) NOT NULL,
--     units               DECIMAL(20, 2) NOT NULL,
--     branch_uuid         uuid NOT NULL,
--     organization_id     uuid NOT NULL,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
--     FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE SET NULL,
--     FOREIGN KEY (purchase_group_id) REFERENCES purchase_group (purchase_group_id) ON DELETE CASCADE,
--     FOREIGN KEY (branch_uuid) REFERENCES branches (id) ON DELETE CASCADE
--     );
--
-- -- Create enum type for operation
-- DROP TYPE IF EXISTS operation_type;
-- CREATE TYPE operation_type AS ENUM ('read', 'write', 'update', 'delete', 'login');
--
-- -- Create activity table
-- CREATE TABLE activity
-- (
--     id              uuid DEFAULT uuidv7() PRIMARY KEY,
--     identity        VARCHAR(255) NOT NULL,
--     operation       operation_type NOT NULL, -- better use enum
--     resource        VARCHAR(255)[] NOT NULL,
--     old_value       VARCHAR(255)[],
--     new_value       VARCHAR(255)[],
--     status          BOOLEAN NOT NULL,
--     time            TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     organization_id uuid NOT NULL,
--     FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE
-- );
--
-- -- Create table configurations
-- CREATE TABLE configurations
-- (
--     id               INT NOT NULL DEFAULT 1,
--     latest_migration VARCHAR(8) NOT NULL,
--     CONSTRAINT Configuration_PK PRIMARY KEY (id),
--     CONSTRAINT Configuration_OnlyOneRow CHECK (id = 1)
-- );
