-- 1. Sử dụng cơ sở dữ liệu classicmodels
USE classicmodels;

-- ========================================================
-- PHẦN 1: THAM SỐ LOẠI IN
-- ========================================================
DELIMITER //

CREATE PROCEDURE getCusById

(IN cusNum INT(11))

BEGIN

  SELECT * FROM customers WHERE customerNumber = cusNum;

END //

DELIMITER ;

-- Gọi Stored Procedure với tham số IN
CALL getCusById(175);


-- ========================================================
-- PHẦN 2: THAM SỐ LOẠI OUT
-- ========================================================
DELIMITER //

CREATE PROCEDURE GetCustomersCountByCity(

    IN  in_city VARCHAR(50),

    OUT total INT

)

BEGIN

    SELECT COUNT(customerNumber)

    INTO total

    FROM customers

    WHERE city = in_city;

END//

DELIMITER ;

-- Gọi Stored Procedure với tham số OUT và xem kết quả
CALL GetCustomersCountByCity('Lyon', @total);

SELECT @total;


-- ========================================================
-- PHẦN 3: THAM SỐ LOẠI INOUT
-- ========================================================
DELIMITER //

CREATE PROCEDURE SetCounter(

    INOUT counter INT,

    IN inc INT

)

BEGIN

    SET counter = counter + inc;

END//

DELIMITER ;

-- Gọi Stored Procedure với tham số INOUT
SET @counter = 1;
CALL SetCounter(@counter, 1); -- Trả về 2
CALL SetCounter(@counter, 1); -- Trả về 3
CALL SetCounter(@counter, 5); -- Trả về 8
SELECT @counter; -- Kết quả cuối cùng là 8