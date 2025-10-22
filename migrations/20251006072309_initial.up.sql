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
    FOREIGN KEY (user_profile_id) REFERENCES user_profile (id)
    );

