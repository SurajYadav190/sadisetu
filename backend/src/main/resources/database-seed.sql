-- ====================================================================
-- Shaadi Setu - Complete MySQL Database Schema & Realistic Seed Data
-- ====================================================================

CREATE DATABASE IF NOT EXISTS shadisetu_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shadisetu_db;

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    avatar_url VARCHAR(500),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    slug VARCHAR(255) NOT NULL UNIQUE,
    icon VARCHAR(100),
    description TEXT,
    starting_price DOUBLE DEFAULT 0.0,
    active BOOLEAN DEFAULT TRUE,
    dynamic_fields_json TEXT
) ENGINE=InnoDB;

-- 3. VENDOR PROFILES TABLE
CREATE TABLE IF NOT EXISTS vendor_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    category_id BIGINT,
    business_name VARCHAR(255) NOT NULL,
    bio TEXT,
    address VARCHAR(500),
    city VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE,
    kyc_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    business_license_url VARCHAR(500),
    id_proof_url VARCHAR(500),
    kyc_rejection_reason TEXT,
    bank_account_number VARCHAR(100),
    bank_ifsc VARCHAR(50),
    bank_holder_name VARCHAR(255),
    is_online BOOLEAN DEFAULT TRUE,
    rating DOUBLE DEFAULT 4.8,
    review_count INT DEFAULT 0,
    commission_rate DOUBLE DEFAULT 10.0,
    wallet_balance DOUBLE DEFAULT 0.0,
    CONSTRAINT fk_vendor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_vendor_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. SERVICE PACKAGES TABLE
CREATE TABLE IF NOT EXISTS service_packages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vendor_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DOUBLE NOT NULL,
    discounted_price DOUBLE,
    features_json TEXT,
    image_urls_json TEXT,
    duration_hours INT DEFAULT 8,
    active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_pkg_vendor FOREIGN KEY (vendor_id) REFERENCES vendor_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_number VARCHAR(100) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    package_id BIGINT,
    booking_date DATE NOT NULL,
    time_slot VARCHAR(100),
    venue_address TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    total_amount DOUBLE,
    commission_amount DOUBLE,
    payout_amount DOUBLE,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'ESCROW_HELD',
    payment_transaction_id VARCHAR(100),
    customer_notes TEXT,
    vendor_notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bkg_customer FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_bkg_vendor FOREIGN KEY (vendor_id) REFERENCES vendor_profiles(id) ON DELETE CASCADE,
    CONSTRAINT fk_bkg_package FOREIGN KEY (package_id) REFERENCES service_packages(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 6. BANNERS TABLE
CREATE TABLE IF NOT EXISTS banners (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    image_url VARCHAR(500) NOT NULL,
    target_route VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    expiry_date DATE,
    display_order INT DEFAULT 1
) ENGINE=InnoDB;

-- 7. PROMOTION COUPONS TABLE
CREATE TABLE IF NOT EXISTS coupons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    discount_percent DOUBLE NOT NULL,
    max_discount_amount DOUBLE,
    min_booking_amount DOUBLE DEFAULT 0.0,
    valid_until DATE,
    usage_limit INT DEFAULT 1000,
    usage_count INT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- 8. SUPPORT TICKETS TABLE
CREATE TABLE IF NOT EXISTS support_tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(100) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    booking_id BIGINT,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(50) DEFAULT 'MEDIUM',
    status VARCHAR(50) DEFAULT 'OPEN',
    resolution_notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ticket_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ticket_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 9. AVAILABILITY SLOTS TABLE
CREATE TABLE IF NOT EXISTS availability_slots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vendor_id BIGINT NOT NULL,
    slot_date DATE NOT NULL,
    time_slot VARCHAR(100) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    blocked_reason VARCHAR(255),
    booking_id BIGINT,
    CONSTRAINT fk_slot_vendor FOREIGN KEY (vendor_id) REFERENCES vendor_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    vendor_id BIGINT NOT NULL,
    booking_id BIGINT,
    rating DOUBLE NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_vendor FOREIGN KEY (vendor_id) REFERENCES vendor_profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. CHAT MESSAGES TABLE
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    booking_id BIGINT,
    message TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_chat_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_receiver FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ====================================================================
-- ====================================================================
-- INSERT INITIAL PLATFORM DATA (CATEGORIES, BANNERS, COUPONS, SUPER ADMIN)
-- All dummy vendors, dummy customers & bookings are removed.
-- Real vendors and customers register via Customer & Vendor portals.
-- ====================================================================

-- 1. USERS (Only Super Admin is seeded for platform governance)
INSERT IGNORE INTO users (id, full_name, phone, email, password, role, status, created_at) VALUES
(1, 'Shaadi Setu Super Admin', '9999999999', 'admin@shadisetu.com', '$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1p1Qv8m2t4l5X3Z6G6C1y2X3W4V5U6', 'ROLE_ADMIN', 'ACTIVE', NOW());

-- 2. CATEGORIES
INSERT IGNORE INTO categories (id, name, slug, icon, description, starting_price, active, dynamic_fields_json) VALUES
(1, 'Camera & Photography', 'camera-photography', 'camera', 'Candid wedding photographers, pre-wedding shoots, drone video and cinematic films.', 25000.0, 1, '[{\"name\":\"droneCoverage\",\"type\":\"boolean\"},{\"name\":\"albumCount\",\"type\":\"number\"}]'),
(2, 'Luxury Cars', 'luxury-cars', 'car', 'Vintage Rolls Royce, Audi, BMW, Mercedes for groom entry and doli.', 15000.0, 1, '[{\"name\":\"carModel\",\"type\":\"select\"},{\"name\":\"flowerDecorIncluded\",\"type\":\"boolean\"}]'),
(3, 'DJ & Sound Systems', 'dj-sound-systems', 'disc', 'Concert line-array sound systems, moving heads, LED walls, and celebrity DJs.', 30000.0, 1, '[{\"name\":\"ledWallSize\",\"type\":\"string\"},{\"name\":\"bassCount\",\"type\":\"number\"}]'),
(4, 'Decorators & Mandap', 'decorators-mandap', 'flower', 'Theme stages, floral mandap, grand entrance gates, and ambient lighting.', 50000.0, 1, '[{\"name\":\"themeType\",\"type\":\"select\"}]'),
(5, 'Baaja & Brass Band', 'baaja-brass-band', 'music', 'Traditional royal brass band, Punjabi dhol, Tasha, and illuminating lights trolley.', 18000.0, 1, '[{\"name\":\"musiciansCount\",\"type\":\"number\"}]'),
(6, 'Royal Catering', 'royal-catering', 'utensils', 'Multi-cuisine live counters, dessert lounges, and traditional royal feast.', 600.0, 1, '[{\"name\":\"perPlatePricing\",\"type\":\"boolean\"}]');

-- 3. BANNERS
INSERT IGNORE INTO banners (id, title, subtitle, image_url, target_route, active, display_order) VALUES
(1, 'Grand Wedding Season 2026', 'Book Top Photographers & Luxury Cars with 15% Cashback', 'https://images.unsplash.com/photo-1519741497674-611481863552', '/services/camera-photography', 1, 1),
(2, 'Royal Baraat Entries', 'Vintage & Luxury Cars starting at ₹14,999', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341', '/services/luxury-cars', 1, 2),
(3, 'Electric DJ & Live Sangeet', 'Concert sound systems & celebrity DJs', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745', '/services/dj-sound-systems', 1, 3);

-- 4. COUPONS
INSERT IGNORE INTO coupons (id, code, discount_percent, max_discount_amount, min_booking_amount, valid_until, usage_limit, usage_count, active) VALUES
(1, 'SHADI2026', 15.0, 5000.0, 20000.0, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 1000, 42, 1),
(2, 'WELCOME500', 10.0, 1000.0, 5000.0, DATE_ADD(CURDATE(), INTERVAL 12 MONTH), 1000, 110, 1);

