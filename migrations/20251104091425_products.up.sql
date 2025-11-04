-- Create category table first (referenced by product table)
CREATE TABLE IF NOT EXISTS category (
    id          uuid DEFAULT uuidv7() PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- Create product table
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
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_product_category_id ON product(category_id);
CREATE INDEX IF NOT EXISTS idx_product_name ON product(name);
CREATE INDEX IF NOT EXISTS idx_product_is_active ON product(is_active);
CREATE INDEX IF NOT EXISTS idx_category_name ON category(name);