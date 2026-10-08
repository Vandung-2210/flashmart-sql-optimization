package haha;
import java.util.Scanner;

public class HeThongDangNhap {
	
    public String tenDangNhap;
    public String matKhau;
    public String quyenTruyCap;

    public HeThongDangNhap() {
        tenDangNhap = "";
        matKhau = "";
        quyenTruyCap = "";
    }

    public void nhapThongTin() {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Nhập tên đăng nhập: ");
        tenDangNhap = scanner.nextLine();
        System.out.print("Nhập mật khẩu: ");
        matKhau = scanner.nextLine();
        System.out.print("Nhập quyền truy cập: ");
        quyenTruyCap = scanner.nextLine();
    }

    public void hienThiThongTin() {
        System.out.println("Tên đăng nhập: " + tenDangNhap);
        System.out.println("Mật khẩu: " + matKhau);
        System.out.println("Quyền truy cập: " + quyenTruyCap);
    }

    public static void main(String[] args) {
        HeThongDangNhap htdn = new HeThongDangNhap();
        htdn.nhapThongTin();
        htdn.hienThiThongTin();
    }
}
