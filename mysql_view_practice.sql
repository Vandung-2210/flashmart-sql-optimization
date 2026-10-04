-- 1. Sử dụng cơ sở dữ liệu classicmodels
USE classicmodels;

-- 2. Tạo View có tên customer_views để lấy các cột customerNumber, customerName, phone
CREATE VIEW customer_views AS
SELECT customerNumber, customerName, phone
FROM customers;

-- 3. Truy vấn dữ liệu từ bảng ảo (View) vừa tạo
SELECT * FROM customer_views;

-- 4. Cập nhật View (thêm điều kiện WHERE city = 'Nantes' và các cột liên lạc)
CREATE OR REPLACE VIEW customer_views AS
SELECT customerNumber, customerName, contactFirstName, contactLastName, phone
FROM customers
WHERE city = 'Nantes';

-- Kiểm tra lại dữ liệu sau khi cập nhật View
SELECT * FROM customer_views;

-- 5. Xóa View khi không còn sử dụng nữa
DROP VIEW customer_views;