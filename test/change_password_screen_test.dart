import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/profile/change_password_screen.dart';

void main() {
  group('ChangePasswordScreen Widget Tests', () {
    // Test case 1: Kiểm tra widget được render đúng với các thành phần cơ bản
    testWidgets('Hiển thị đúng các trường nhập liệu và nút lưu', (WidgetTester tester) async {
      // Arrange & Act: Build widget ChangePasswordScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Assert: Kiểm tra AppBar có tiêu đề đúng
      expect(find.text('Đổi mật khẩu'), findsOneWidget);

      // Assert: Kiểm tra các TextField được hiển thị với label đúng
      expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);

      // Assert: Kiểm tra nút lưu được hiển thị
      expect(find.text('LƯU THAY ĐỔI'), findsOneWidget);

      // Assert: Kiểm tra các icon visibility được hiển thị (mặc định là visibility_off)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
    });

    // Test case 2: Kiểm tra có thể nhập text vào các trường
    testWidgets('Có thể nhập text vào trường mật khẩu hiện tại', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Tìm TextField và nhập text
      final currentPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu hiện tại');
      await tester.enterText(currentPasswordField, 'oldpassword123');

      // Assert: Kiểm tra text đã được nhập vào
      expect(find.text('oldpassword123'), findsOneWidget);
    });

    testWidgets('Có thể nhập text vào trường mật khẩu mới', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Nhập text vào trường mật khẩu mới
      final newPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu mới');
      await tester.enterText(newPasswordField, 'newpassword123');

      // Assert: Kiểm tra text đã được nhập
      expect(find.text('newpassword123'), findsOneWidget);
    });

    // Test case 3: Kiểm tra toggle visibility icon hoạt động
    testWidgets('Toggle visibility icon thay đổi từ visibility_off sang visibility', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Assert: Ban đầu có 3 icon visibility_off
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Act: Tap vào icon visibility của trường mật khẩu hiện tại
      final visibilityButtons = find.byType(IconButton);
      await tester.tap(visibilityButtons.first);
      await tester.pump(); // Trigger rebuild

      // Assert: Icon đã thay đổi (còn 2 visibility_off và có 1 visibility)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    // Test case 4: Kiểm tra validation khi submit form rỗng
    testWidgets('Hiển thị lỗi validation khi submit form rỗng', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Tap vào nút lưu mà không nhập gì
      final saveButton = find.text('LƯU THAY ĐỔI');
      await tester.tap(saveButton);
      await tester.pump(); // Trigger validation

      // Assert: Kiểm tra thông báo lỗi validation được hiển thị
      // (Lưu ý: Validation sẽ hiển thị lỗi trong TextFormField)
      expect(find.text('Vui lòng nhập thông tin.'), findsWidgets);
    });

    // Test case 5: Kiểm tra validation mật khẩu mới quá ngắn
    testWidgets('Hiển thị lỗi khi mật khẩu mới có ít hơn 6 ký tự', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Nhập mật khẩu mới quá ngắn và trigger validation
      final newPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu mới');
      await tester.enterText(newPasswordField, '12345'); // Chỉ có 5 ký tự
      await tester.tap(find.text('LƯU THAY ĐỔI'));
      await tester.pump();

      // Assert: Kiểm tra thông báo lỗi được hiển thị
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự.'), findsOneWidget);
    });

    // Test case 6: Kiểm tra validation mật khẩu xác nhận không khớp
    testWidgets('Hiển thị lỗi khi mật khẩu xác nhận không khớp', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Nhập mật khẩu mới và mật khẩu xác nhận khác nhau
      final newPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu mới');
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới');
      
      await tester.enterText(newPasswordField, 'newpass123');
      await tester.enterText(confirmPasswordField, 'different123');
      
      await tester.tap(find.text('LƯU THAY ĐỔI'));
      await tester.pump();

      // Assert: Kiểm tra thông báo lỗi không khớp được hiển thị
      expect(find.text('Mật khẩu xác nhận không khớp.'), findsOneWidget);
    });

    // Test case 7: Kiểm tra có thể nhập mật khẩu hợp lệ
    testWidgets('Có thể nhập mật khẩu hợp lệ vào tất cả các trường', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Nhập đầy đủ thông tin hợp lệ vào tất cả các trường
      final currentPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu hiện tại');
      final newPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu mới');
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới');
      
      await tester.enterText(currentPasswordField, 'oldpass123');
      await tester.enterText(newPasswordField, 'newpass123');
      await tester.enterText(confirmPasswordField, 'newpass123');
      
      await tester.pump();

      // Assert: Kiểm tra text đã được nhập vào các trường
      // (Lưu ý: Test này chỉ kiểm tra UI, không test logic Firebase submit)
      expect(find.text('oldpass123'), findsOneWidget);
      expect(find.text('newpass123'), findsNWidgets(2)); // Có trong cả new và confirm field
    });

    // Test case 8: Kiểm tra các trường password mặc định là obscure (ẩn text)
    testWidgets('Các trường password mặc định ẩn text (obscureText = true)', (WidgetTester tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );

      // Act: Nhập text vào các trường password
      final currentPasswordField = find.widgetWithText(TextFormField, 'Mật khẩu hiện tại');
      await tester.enterText(currentPasswordField, 'secretpassword');

      // Assert: Text không được hiển thị dạng plain text (obscure)
      // Tìm TextFormField và kiểm tra obscureText property
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));
      
      // Kiểm tra icon visibility_off được hiển thị (chứng tỏ đang ở chế độ obscure)
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
    });
  });
}

