/// Helper class chứa các hàm logic validate mật khẩu
/// Tách logic này ra để dễ dàng viết unit test
class PasswordValidator {
  /// Validate mật khẩu mới
  /// Trả về null nếu hợp lệ, trả về thông báo lỗi nếu không hợp lệ
  static String? validateNewPassword(String? value) {
    // Kiểm tra nếu giá trị rỗng hoặc null
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới.';
    }
    
    // Kiểm tra độ dài tối thiểu (ít nhất 6 ký tự)
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    
    // Nếu tất cả điều kiện đều thỏa mãn, trả về null (hợp lệ)
    return null;
  }

  /// Validate xác nhận mật khẩu (so sánh với mật khẩu mới)
  /// Trả về null nếu khớp, trả về thông báo lỗi nếu không khớp
  static String? validateConfirmPassword(String? value, String newPassword) {
    // So sánh giá trị nhập vào với mật khẩu mới
    if (value != newPassword) {
      return 'Mật khẩu xác nhận không khớp.';
    }
    
    // Nếu khớp, trả về null (hợp lệ)
    return null;
  }
}

