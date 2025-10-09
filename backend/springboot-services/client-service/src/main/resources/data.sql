CREATE EXTENSION IF NOT EXISTS "pgcrypto";
ALTER TABLE roles
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

INSERT INTO roles (id, name, note) VALUES
                                       (gen_random_uuid(), 'CUSTOMER', 'Người dùng cuối đặt món ăn'),
                                       (gen_random_uuid(), 'RESTAURANT', 'Nhà hàng hoặc quán ăn, đăng món và xử lý đơn hàng'),
                                       (gen_random_uuid(), 'DRIVER', 'Tài xế giao hàng'),
                                       (gen_random_uuid(), 'ADMIN', 'Quản trị hệ thống');
