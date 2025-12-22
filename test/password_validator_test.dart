import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/utils/password_validator.dart';

void main() {
  group('PasswordValidator - validateNewPassword', () {
    // Test case 1: Mật khẩu rỗng hoặc null
    test('Trả về lỗi khi mật khẩu rỗng', () {
      // Arrange: Chuẩn bị dữ liệu đầu vào là chuỗi rỗng
      String? emptyPassword = '';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(emptyPassword);
      
      // Assert: Kiểm tra kết quả trả về phải là thông báo lỗi
      expect(result, isNotNull, reason: 'Mật khẩu rỗng phải trả về lỗi');
      expect(result, 'Vui lòng nhập mật khẩu mới.');
    });

    test('Trả về lỗi khi mật khẩu null', () {
      // Arrange: Chuẩn bị dữ liệu đầu vào là null
      String? nullPassword = null;
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(nullPassword);
      
      // Assert: Kiểm tra kết quả trả về phải là thông báo lỗi
      expect(result, isNotNull);
      expect(result, 'Vui lòng nhập mật khẩu mới.');
    });

    // Test case 2: Mật khẩu quá ngắn (< 6 ký tự)
    test('Trả về lỗi khi mật khẩu có ít hơn 6 ký tự', () {
      // Arrange: Chuẩn bị mật khẩu ngắn (5 ký tự)
      String shortPassword = '12345';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(shortPassword);
      
      // Assert: Kiểm tra kết quả trả về phải là thông báo lỗi về độ dài
      expect(result, isNotNull);
      expect(result, 'Mật khẩu phải có ít nhất 6 ký tự.');
    });

    test('Trả về lỗi khi mật khẩu chỉ có 1 ký tự', () {
      // Arrange: Chuẩn bị mật khẩu rất ngắn
      String veryShortPassword = '1';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(veryShortPassword);
      
      // Assert: Kiểm tra kết quả
      expect(result, isNotNull);
      expect(result, 'Mật khẩu phải có ít nhất 6 ký tự.');
    });

    // Test case 3: Mật khẩu hợp lệ (>= 6 ký tự)
    test('Trả về null khi mật khẩu có đúng 6 ký tự', () {
      // Arrange: Chuẩn bị mật khẩu đúng độ dài tối thiểu
      String validPassword = '123456';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(validPassword);
      
      // Assert: Kiểm tra kết quả trả về null (hợp lệ)
      expect(result, isNull, reason: 'Mật khẩu hợp lệ phải trả về null');
    });

    test('Trả về null khi mật khẩu dài hơn 6 ký tự', () {
      // Arrange: Chuẩn bị mật khẩu dài
      String longPassword = 'password123';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateNewPassword(longPassword);
      
      // Assert: Kiểm tra kết quả trả về null (hợp lệ)
      expect(result, isNull);
    });
  });

  group('PasswordValidator - validateConfirmPassword', () {
    // Test case 1: Mật khẩu xác nhận khớp với mật khẩu mới
    test('Trả về null khi mật khẩu xác nhận khớp', () {
      // Arrange: Chuẩn bị mật khẩu mới và mật khẩu xác nhận giống nhau
      String newPassword = 'password123';
      String confirmPassword = 'password123';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateConfirmPassword(
        confirmPassword,
        newPassword,
      );
      
      // Assert: Kiểm tra kết quả trả về null (hợp lệ)
      expect(result, isNull, reason: 'Mật khẩu khớp phải trả về null');
    });

    // Test case 2: Mật khẩu xác nhận không khớp
    test('Trả về lỗi khi mật khẩu xác nhận không khớp', () {
      // Arrange: Chuẩn bị mật khẩu mới và mật khẩu xác nhận khác nhau
      String newPassword = 'password123';
      String confirmPassword = 'password456';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateConfirmPassword(
        confirmPassword,
        newPassword,
      );
      
      // Assert: Kiểm tra kết quả trả về thông báo lỗi
      expect(result, isNotNull);
      expect(result, 'Mật khẩu xác nhận không khớp.');
    });

    test('Trả về lỗi khi mật khẩu xác nhận rỗng nhưng mật khẩu mới không rỗng', () {
      // Arrange: Mật khẩu mới có giá trị, mật khẩu xác nhận rỗng
      String newPassword = 'password123';
      String confirmPassword = '';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateConfirmPassword(
        confirmPassword,
        newPassword,
      );
      
      // Assert: Kiểm tra kết quả trả về lỗi
      expect(result, isNotNull);
      expect(result, 'Mật khẩu xác nhận không khớp.');
    });

    test('Trả về null khi cả hai mật khẩu đều rỗng', () {
      // Arrange: Cả hai mật khẩu đều rỗng
      String newPassword = '';
      String confirmPassword = '';
      
      // Act: Gọi hàm validate
      String? result = PasswordValidator.validateConfirmPassword(
        confirmPassword,
        newPassword,
      );
      
      // Assert: Kiểm tra kết quả (rỗng khớp rỗng nên hợp lệ)
      expect(result, isNull);
    });
  });
}

