-- HỆ THỐNG SMARTFACTORY - TỐI ƯU HÓA LẠI INDEX (LEAN INDEX)
CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- ========================================================
-- BƯỚC 1: TẠO "FAT INDEX" (MÔ PHỎNG LẬP TRÌNH VIÊN CŨ)
-- ========================================================
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);

-- Kiểm tra dung lượng bảng và Index trước khi xử lý
SHOW TABLE STATUS LIKE 'SensorLogs';

-- ========================================================
-- BƯỚC 2: XÓA BỎ "FAT INDEX" GÂY NGHẺN CỔ CHAI GHI (WRITE BOTTLENECK)
-- ========================================================
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- ========================================================
-- BƯỚC 3: TẠO "LEAN INDEX" TINH GỌN (CHỈ DÙNG ĐỂ LỌC VÀ SẮP XẾP)
-- ========================================================
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

-- ========================================================
-- BƯỚC 4: CHẠY EXPLAIN ĐỂ ĐỐI CHỐNG HIỆU NĂNG
-- ========================================================
EXPLAIN 
SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 
  AND recorded_at >= '2026-06-20';