-- ========================================================
-- PHẦN 1: QUICKFEED_INDEX_OPTIMIZATION.SQL
-- ========================================================

CREATE DATABASE IF NOT EXISTS quickfeed_db;
USE quickfeed_db;

CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    post_type VARCHAR(10), -- Chỉ chứa 3 giá trị: 'TEXT', 'IMAGE', 'VIDEO'
    is_visible BOOLEAN DEFAULT 1, -- Chỉ chứa 1 (Hiện) hoặc 0 (Ẩn)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- (Mô phỏng) Lập trình viên cũ đã lạm dụng tạo 5 Index
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_content ON Posts(content(255)); 
CREATE INDEX idx_post_type ON Posts(post_type); 
CREATE INDEX idx_is_visible ON Posts(is_visible); 
CREATE INDEX idx_created_at ON Posts(created_at);

-- Kiểm tra dung lượng lưu trữ (Data vs Index) trước khi tối ưu
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 2) AS `Data Size (MB)`,
    ROUND(((index_length) / 1024 / 1024), 2) AS `Index Size (MB)`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Total Size (MB)`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' 
  AND table_name = 'Posts';

-- Tiến hành cắt bỏ các Index vô dụng (Low Cardinality & Text)
ALTER TABLE Posts DROP INDEX idx_content;
ALTER TABLE Posts DROP INDEX idx_post_type;
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- Kiểm tra lại dung lượng sau khi tối ưu
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 2) AS `Data Size (MB)`,
    ROUND(((index_length) / 1024 / 1024), 2) AS `Index Size (MB)`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Total Size (MB)`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' 
  AND table_name = 'Posts';


-- ========================================================
-- PHẦN 2: STORAGE_PERFORMANCE_REPORT.MD (BÁO CÁO HIỆU NĂNG)
-- ========================================================
/*
BÁO CÁO TỐI ƯU HÓA LƯU TRỮ VÀ HIỆU NĂNG TẠI QUICKFEED

1. Chẩn đoán nguyên nhân (The Bottleneck):
- Việc lạm dụng tạo 5 Index trên một bảng dữ liệu mạng xã hội khiến mỗi thao tác INSERT (đăng bài) bị chậm trầm trọng (gây lỗi Timeout). Lý do ở tầng vật lý: mỗi khi chèn 1 dòng mới, MySQL không chỉ ghi dữ liệu vào bảng mà bắt buộc phải cập nhật đồng thời cấu trúc cây B-Tree cho tất cả 5 Index, làm tăng vọt số lượng thao tác ghi đĩa (Disk I/O).
- Các Index như idx_content (trên cột TEXT dài), idx_post_type (3 giá trị), và idx_is_visible (2 giá trị) có độ phân giải dữ liệu (Cardinality) cực kỳ thấp hoặc cấu trúc quá lớn, dẫn đến việc MySQL Optimizer thường xuyên bỏ qua Index và chiếm dụng dung lượng ổ cứng vô ích.

2. Giải pháp thực thi:
- Giữ lại các Index thực sự chất lượng và có tính chọn lọc cao: idx_user_id (phục vụ load trang cá nhân) và idx_created_at (phục vụ sắp xếp Newsfeed).
- Triệt tiêu 3 Index gây nghẽn: idx_content, idx_post_type, và idx_is_visible.

3. Đánh giá kết quả (Trade-off & Metrics):
- Hiệu năng (Write Performance): Thao tác INSERT được giải phóng hoàn toàn, giảm tải được 3 lần cập nhật cây B-Tree ngầm, đưa thời gian phản hồi về mức mili-giây và khắc phục triệt để lỗi Timeout cho người dùng.
- Dung lượng (Storage): Qua truy vấn từ information_schema.TABLES, kích thước Index_length sụt giảm mạnh mẽ, giải cứu không gian ổ cứng cho máy chủ.
*/


-- ========================================================
-- PHẦN 3: AI_PROMPT_LOG.MD (NHẬT KÝ TRA CỨU AI)
-- ========================================================
/*
NHẬT KÝ TRA CỨU VÀ TƯƠNG TÁC AI (AI PROMPT LOG)

- Câu hỏi 1: Trong MySQL, nếu tôi tạo Index trên một cột chứa văn bản dài (TEXT) và một cột kiểu BOOLEAN (0 và 1), thì điều này gây hại như thế nào đến bộ nhớ RAM, dung lượng Disk và bộ tối ưu hóa (Query Optimizer)?
  + Giải đáp: Tạo Index trên cột TEXT gây tốn kém dung lượng khủng khiếp vì cây B-Tree phải lưu trữ các đoạn chuỗi dài. Cột kiểu BOOLEAN có Cardinality cực thấp (chỉ có 2 giá trị), khiến tỷ lệ lọc dữ liệu kém; Query Optimizer sẽ tính toán và thấy việc quét toàn bảng nhanh hơn là nhảy qua lại giữa Index và bảng gốc, dẫn đến Index bị bỏ phí nhưng vẫn ngốn tài nguyên bảo trì.

- Câu hỏi 2: Tại sao khi tôi truy vấn SELECT * FROM Posts WHERE is_visible = 1 trên một bảng có hàng triệu dòng (trong đó 99% bài viết là visible = 1), MySQL lại quyết định quét toàn bảng (Full Table Scan) thay vì sử dụng Index idx_is_visible đã tạo?
  + Giải đáp: Do tính chọn lọc (Selectivity) quá kém. Nếu 99% dữ liệu đều thỏa mãn điều kiện, việc sử dụng Index buộc MySQL phải tra cứu cây B-Tree trước rồi mới quay lại bảng chính cho gần như toàn bộ số dòng, chậm hơn rất nhiều so với quét toàn bảng trực tiếp.

- Câu hỏi 3: Nếu muốn tìm kiếm từ khóa bên trong cột content (kiểu TEXT) mà không bị tốn quá nhiều dung lượng như B-Tree Index thông thường, tôi nên sử dụng cơ chế nào của MySQL?
  + Giải đáp: Nên sử dụng FULLTEXT Index kết hợp với hàm tìm kiếm toàn văn (MATCH()...AGAINST()). Loại Index này được thiết kế tối ưu riêng cho dữ liệu văn bản lớn, giúp lập chỉ mục theo từng từ thay vì lưu trữ nguyên đoạn chuỗi dài cồng kềnh.
*/