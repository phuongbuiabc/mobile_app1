import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/utils/password_validator.dart';

void main() {
  group('PasswordValidator Tests', () {
    
    group('validateNewPassword', () {
      test('Trả về lỗi khi mật khẩu trống hoặc quá ngắn', () {
        // Kiểm tra null/rỗng
        expect(PasswordValidator.validateNewPassword(null), 'Vui lòng nhập mật khẩu mới.');
        expect(PasswordValidator.validateNewPassword(''), 'Vui lòng nhập mật khẩu mới.');
        
        // Kiểm tra độ dài < 6
        expect(PasswordValidator.validateNewPassword('12345'), 'Mật khẩu phải có ít nhất 6 ký tự.');
      });

      test('Trả về null khi mật khẩu hợp lệ (>= 6 ký tự)', () {
        expect(PasswordValidator.validateNewPassword('123456'), isNull);
        expect(PasswordValidator.validateNewPassword('password123'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('Trả về null khi mật khẩu xác nhận khớp hoàn toàn', () {
        const pass = 'password123';
        expect(PasswordValidator.validateConfirmPassword(pass, pass), isNull);
      });

      test('Trả về lỗi khi mật khẩu xác nhận không khớp hoặc để trống', () {
        const pass = 'password123';
        
        // Không khớp
        expect(PasswordValidator.validateConfirmPassword('wrong_pass', pass), 'Mật khẩu xác nhận không khớp.');
        
        // Để trống khi pass mới có giá trị
        expect(PasswordValidator.validateConfirmPassword('', pass), 'Mật khẩu xác nhận không khớp.');
      });
    });
    
  });
}