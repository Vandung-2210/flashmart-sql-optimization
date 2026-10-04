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

-- ========================================================
-- BƯỚC 2: XÓA BỎ "FAT INDEX" GÂY NGHẺN CỔ CHAI GHI (WRITE BOTTLENECK)
-- ========================================================
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- ========================================================
-- BƯỚC 3: TẠO "LEAN INDEX" TINH GỌN
-- ========================================================
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

-- ========================================================
-- BƯỚC 4: CHẠY EXPLAIN VÀ PHÂN TÍCH KẾT QUẢ
-- ========================================================
EXPLAIN 
SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 
  AND recorded_at >= '2026-06-20';

/*
-- KẾT QUẢ PHÂN TÍCH EXPLAIN VÀ CỘT EXTRA:
1. Trước khi tối ưu (dùng Fat Covering Index):
   - Cột `key`: `idx_fat_covering`
   - Cột `Extra`: Hiển thị `Using index`. (Nghĩa là Covering Index: MySQL lấy toàn bộ dữ liệu nhiệt độ, độ ẩm trực tiếp từ cây Index mà không cần truy cập vào bảng chính, giúp Đọc cực nhanh nhưng đánh đổi bằng Write Penalty khổng lồ khi INSERT).

2. Sau khi tối ưu (dùng Lean Index):
   - Cột `key`: `idx_lean_search`
   - Cột `type`: `range` hoặc `ref`
   - Cột `Extra`: Sẽ chuyển thành trống (hoặc không còn `Using index`), nghĩa là sau khi lọc `sensor_id` và `recorded_at` qua Index, MySQL phải thực hiện thêm bước **Table Lookup** để nhảy vào bảng chính lấy các cột `temperature`, `humidity`, `status`. 
   - Sự đánh đổi này hoàn toàn hợp lý trong hệ thống IoT lưu lượng ghi cao: Chấp nhận tốn một phần nghìn giây ở tầng Đọc để giải phóng hoàn toàn nghẽn cổ chai Ghi (INSERT) và tiết kiệm không gian lưu trữ ổ cứng.
*/