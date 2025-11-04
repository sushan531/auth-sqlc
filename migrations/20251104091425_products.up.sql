-- Create category table first (referenced by product table)
-- Categories are organization-wide (shared across branches)
CREATE TABLE IF NOT EXISTS category (
    id              uuid DEFAULT uuidv7() PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    organization_id uuid NOT NULL,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
    UNIQUE(name, organization_id) -- Category names must be unique within organization
);

-- Create product table
-- Products are branch-specific for inventory management
CREATE TABLE IF NOT EXISTS product (
    id                  uuid DEFAULT uuidv7() PRIMARY KEY,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    category_id         uuid NOT NULL,
    cost_price          NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    selling_price       NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    quantity_in_stock   INTEGER NOT NULL DEFAULT 0,
    reorder_level       INTEGER NOT NULL DEFAULT 10,
    -- Primary and Sub Units
    unit_of_measure     VARCHAR(50) NOT NULL DEFAULT 'pcs',
    sub_unit_of_measure VARCHAR(50),
    sub_unit_conversion NUMERIC(10, 3),
    is_active           BOOLEAN DEFAULT TRUE,
    image_url           TEXT,
    -- Organization and Branch linking
    organization_id     uuid NOT NULL,
    branch_id           uuid NOT NULL,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE RESTRICT,
    FOREIGN KEY (organization_id) REFERENCES organization (id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches (id) ON DELETE CASCADE,
    UNIQUE(name, branch_id) -- Product names must be unique within branch
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_product_category_id ON product(category_id);
CREATE INDEX IF NOT EXISTS idx_product_name ON product(name);
CREATE INDEX IF NOT EXISTS idx_product_is_active ON product(is_active);
CREATE INDEX IF NOT EXISTS idx_product_organization_id ON product(organization_id);
CREATE INDEX IF NOT EXISTS idx_product_branch_id ON product(branch_id);
CREATE INDEX IF NOT EXISTS idx_product_branch_active ON product(branch_id, is_active);
CREATE INDEX IF NOT EXISTS idx_category_name ON category(name);
CREATE INDEX IF NOT EXISTS idx_category_organization_id ON category(organization_id);