# Báo cáo Phân tích Đánh đổi Hiệu năng và Lưu trữ tại SmartFactory

## 1. Bản chất vấn đề "Fat Index" (Covering Index cực đoan)
Trong hệ thống nhà máy thông minh SmartFactory, các cảm biến liên tục gửi dữ liệu thời gian thực với tần suất hàng chục nghìn bản ghi mỗi giây. Việc lập trình viên cũ tạo một **Covering Index** khổng lồ chứa toàn bộ các cột (`sensor_id`, `recorded_at`, `temperature`, `humidity`, `status`) giúp màn hình Dashboard đọc dữ liệu cực nhanh do không cần lookup bảng. 
Tuy nhiên, cấu trúc này gây ra hiện tượng **Write Penalty** (Hình phạt khi Ghi) trầm trọng: mỗi thao tác `INSERT` buộc hệ thống phải cập nhật cấu trúc cây B-Tree quá lớn, làm nghẽn dòng dữ liệu và gây rớt dữ liệu (Data Loss) của cảm biến, đồng thời làm dung lượng ổ cứng phình to nhanh chóng.

## 2. Giải pháp chuyển đổi sang Lean Index
Chúng ta đã tiến hành cắt bỏ `idx_fat_covering` và thay thế bằng **Lean Index** tinh gọn: `idx_lean_search(sensor_id, recorded_at)`. Index mới chỉ giữ lại các trường phục vụ trực tiếp cho việc lọc dữ liệu (`WHERE`) và sắp xếp.

## 3. Đánh giá sự đánh đổi (Trade-off Analysis)
- **Tốc độ Ghi (Write Performance):** Tăng gấp nhiều lần, thao tác `INSERT` diễn ra mượt mà, giúp đường ống dữ liệu (Data Pipeline) bắt kịp tốc độ thời gian thực của 10,000 cảm biến.
- **Không gian lưu trữ (Storage):** Giảm thiểu tối đa kích thước `Index_length` trên ổ đĩa SSD, tiết kiệm chi phí hạ tầng Cloud đáng kể.
- **Tốc độ Đọc (Read Performance):** Chấp nhận hy sinh một phần nhỏ hiệu năng SELECT (do chuyển từ `Using index` sang việc phải thực hiện thêm bước Table Lookup để lấy các cột nhiệt độ, độ ẩm). Đây là sự đánh đổi kỹ thuật hoàn toàn chính xác và tối ưu cho bài toán hệ thống ghi nặng (Write-heavy).