-- ========================================================
-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU DEMO
-- ========================================================
CREATE DATABASE IF NOT EXISTS demo_product_db;
USE demo_product_db;

-- ========================================================
-- BƯỚC 2: TẠO BẢNG PRODUCTS VÀ CHÈN DỮ LIỆU MẪU
-- ========================================================
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(50) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(10,2) NOT NULL,
    productAmount INT NOT NULL,
    productDescription TEXT,
    productStatus VARCHAR(50)
);

-- Chèn dữ liệu mẫu
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus) VALUES
('P001', 'Laptop Dell Inspiron', 15000000.00, 10, 'Core i5, RAM 8GB', 'Available'),
('P002', 'Smartphone iPhone 14', 20000000.00, 25, '128GB, Bản chính hãng', 'Available'),
('P003', 'Tai nghe Bluetooth', 1200000.00, 50, 'Chống ồn chủ động', 'Available'),
('P004', 'Chuột không dây Logitech', 350000.00, 100, 'Pin trâu, độ nhạy cao', 'Out of Stock');


-- ========================================================
-- BƯỚC 3: TẠO INDEX VÀ SỬ DỤNG EXPLAIN SO SÁNH
-- ========================================================
-- Kiểm tra EXPLAIN trước khi tạo Index
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';

-- Tạo Unique Index trên cột productCode
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- Tạo Composite Index trên 2 cột productName và productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- Kiểm tra EXPLAIN sau khi tạo Index để thấy sự thay đổi (type, key, rows)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'Smartphone iPhone 14' AND productPrice = 20000000.00;


-- ========================================================
-- BƯỚC 4: TẠO, SỬA ĐỔI VÀ XÓA VIEW
-- ========================================================
-- Tạo View lấy thông tin productCode, productName, productPrice, productStatus
CREATE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Xem thử dữ liệu từ View
SELECT * FROM view_products;

-- Sửa đổi View (thêm cột productAmount)
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products;

-- Xóa View khi không dùng nữa
DROP VIEW view_products;


-- ========================================================
-- BƯỚC 5: TẠO CÁC STORED PROCEDURE
-- ========================================================
-- 5.1. Stored Procedure lấy tất cả thông tin của tất cả sản phẩm
DELIMITER //
CREATE PROCEDURE GetAllProducts()
BEGIN
    SELECT * FROM Products;
END //
DELIMITER ;

-- Gọi thử thủ tục
CALL GetAllProducts();


-- 5.2. Stored Procedure thêm một sản phẩm mới
DELIMITER //
CREATE PROCEDURE InsertProduct(
    IN p_code VARCHAR(50),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(50)
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //
DELIMITER ;

-- Gọi thử thủ tục thêm sản phẩm
CALL InsertProduct('P005', 'Bàn phím cơ', 850000.00, 30, 'RGB Switch Blue', 'Available');


-- 5.3. Stored Procedure sửa thông tin sản phẩm theo id
DELIMITER //
CREATE PROCEDURE UpdateProductById(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_amount INT,
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE Products
    SET productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productStatus = p_status
    WHERE Id = p_id;
END //
DELIMITER ;

-- Gọi thử thủ tục sửa sản phẩm có Id = 3
CALL UpdateProductById(3, 'Tai nghe Bluetooth Pro', 1400000.00, 40, 'Available');


-- 5.4. Stored Procedure xóa sản phẩm theo id
DELIMITER //
CREATE PROCEDURE DeleteProductById(
    IN p_id INT
)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;

-- Gọi thử thủ tục xóa sản phẩm có Id = 4
CALL DeleteProductById(4);