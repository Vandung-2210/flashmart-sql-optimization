-- Bước 1: Tạo CSDL và Bảng
CREATE DATABASE IF NOT EXISTS company;
USE company;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- Bước 2: Tạo Trigger tự động cập nhật phòng ban dựa trên mức lương trước khi thêm dữ liệu
DELIMITER //

CREATE TRIGGER update_department
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
     IF NEW.salary >= 5000 THEN
          SET NEW.department = 'Management';
     ELSEIF NEW.salary >= 3000 THEN
          SET NEW.department = 'Sales';
     ELSE
          SET NEW.department = 'Support';
     END IF;
END //

DELIMITER ;

-- Bước 3: Demo sử dụng trigger bằng cách thêm dữ liệu mẫu
INSERT INTO employees (name, department, salary)
VALUES ('John Doe', 'A', 3500),
       ('Jane Smith', 'A', 2000),
       ('David Johnson', 'A', 6000);

-- Kiểm tra lại bảng nhân viên sau khi trigger hoạt động
SELECT * FROM employees;