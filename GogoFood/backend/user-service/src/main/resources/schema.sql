-- ========================================
-- ENUM TYPES
-- ========================================
CREATE TYPE user_role AS ENUM ('ADMIN', 'CUSTOMER', 'RESTAURANT');
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'BANNED');
CREATE TYPE gender_type AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE restaurant_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'BANNED', 'CLOSED');

-- CASTS (để convert string → enum tự động)
CREATE CAST (character varying AS gender_type) WITH INOUT AS IMPLICIT;
CREATE CAST (text AS gender_type) WITH INOUT AS IMPLICIT;
CREATE CAST (character varying AS user_role) WITH INOUT AS IMPLICIT;
CREATE CAST (text AS user_role) WITH INOUT AS IMPLICIT;
CREATE CAST (character varying AS user_status) WITH INOUT AS IMPLICIT;
CREATE CAST (text AS user_status) WITH INOUT AS IMPLICIT;
CREATE CAST (character varying AS restaurant_status) WITH INOUT AS IMPLICIT;
CREATE CAST (text AS restaurant_status) WITH INOUT AS IMPLICIT;

-- ========================================
-- EXTENSIONS
-- ========================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ========================================
-- USERS
-- ========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(15),
    gender gender_type DEFAULT 'OTHER',
    date_of_birth DATE DEFAULT '1900-01-01',
    avatar_url VARCHAR(255),
    role user_role NOT NULL DEFAULT 'CUSTOMER',
    status user_status NOT NULL DEFAULT 'INACTIVE',
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    -- CHECK constraints
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$'),
    CONSTRAINT chk_phone_format CHECK (phone IS NULL OR phone ~ '^[0-9]{8,15}$'),
    CONSTRAINT chk_date_of_birth CHECK (date_of_birth <= CURRENT_DATE)
);

-- ========================================
-- ADDRESSES
-- ========================================
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    street VARCHAR(255) NOT NULL,
    ward VARCHAR(100),
    district VARCHAR(100),
    city VARCHAR(100),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT now()
);

-- Mỗi user chỉ được phép có 1 địa chỉ mặc định
CREATE UNIQUE INDEX idx_unique_default_address_per_user
    ON addresses(user_id)
    WHERE is_default = TRUE;

-- ========================================
-- RESTAURANT PROFILES
-- ========================================
CREATE TABLE restaurant_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    opening_hours VARCHAR(100),
    image_url VARCHAR(255),
    is_open BOOLEAN DEFAULT FALSE,
    status restaurant_status DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),

    -- Không cho phép mở cửa khi chưa được duyệt
    CONSTRAINT chk_open_requires_approved CHECK (
        (status = 'APPROVED' AND is_open IN (TRUE, FALSE))
        OR (status <> 'APPROVED' AND is_open = FALSE)
    )
);

-- Trigger kiểm tra chỉ user role RESTAURANT mới được có profile
CREATE OR REPLACE FUNCTION check_restaurant_user_role()
RETURNS TRIGGER AS $$
DECLARE
    user_role_value user_role;
BEGIN
    SELECT role INTO user_role_value FROM users WHERE id = NEW.user_id;
    IF user_role_value <> 'RESTAURANT' THEN
        RAISE EXCEPTION 'Only users with role RESTAURANT can have restaurant_profiles.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_restaurant_user_role
BEFORE INSERT OR UPDATE ON restaurant_profiles
FOR EACH ROW
EXECUTE FUNCTION check_restaurant_user_role();

-- ========================================
-- INDEXES
-- ========================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_restaurant_status ON restaurant_profiles(status);
CREATE INDEX idx_restaurant_user_id ON restaurant_profiles(user_id);
CREATE INDEX idx_restaurant_is_open ON restaurant_profiles(is_open);

-- ========================================
-- TRIGGERS: timestamps
-- ========================================
CREATE OR REPLACE FUNCTION set_created_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_created_at
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION set_created_at();

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Restaurant triggers
CREATE OR REPLACE FUNCTION update_restaurant_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_restaurant_timestamp
BEFORE UPDATE ON restaurant_profiles
FOR EACH ROW
EXECUTE FUNCTION update_restaurant_updated_at();

CREATE OR REPLACE FUNCTION set_restaurant_created_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_restaurant_created_at
BEFORE INSERT ON restaurant_profiles
FOR EACH ROW
EXECUTE FUNCTION set_restaurant_created_at();

-- ========================================
-- FINAL DEFAULTS
-- ========================================
ALTER TABLE users
ALTER COLUMN status SET DEFAULT 'INACTIVE';
