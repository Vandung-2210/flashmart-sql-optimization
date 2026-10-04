-- 1. Sử dụng cơ sở dữ liệu classicmodels
USE classicmodels;

-- 2. Tạo Stored Procedure đầu tiên để tìm tất cả khách hàng
DELIMITER //

CREATE PROCEDURE findAllCustomers()

BEGIN

  SELECT * FROM customers;

END //

DELIMITER ;

-- 3. Cách gọi Stored Procedure findAllCustomers
CALL findAllCustomers();

-- 4. Sửa Stored Procedure bằng cách DROP nếu tồn tại và tạo lại với điều kiện mới
DELIMITER //

DROP PROCEDURE IF EXISTS `findAllCustomers`//

CREATE PROCEDURE findAllCustomers()

BEGIN

  SELECT * FROM customers WHERE customerNumber = 175;

END //

DELIMITER ;

-- 5. Gọi lại Stored Procedure sau khi đã được cập nhật
CALL findAllCustomers();