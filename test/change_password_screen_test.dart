import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/profile/change_password_screen.dart';

void main() {
  group('ChangePasswordScreen Tests', () {
    // 1. Kiểm tra cấu trúc giao diện cơ bản
    testWidgets('Hiển thị đầy đủ các thành phần giao diện chính', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('LƯU THAY ĐỔI'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
    });

    // 2. Kiểm tra tính năng ẩn/hiện mật khẩu (Thực tế người dùng hay dùng)
    testWidgets('Tính năng ẩn/hiện mật khẩu hoạt động chính xác', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      // Nhấn vào icon hiện mật khẩu đầu tiên
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      // Kiểm tra icon thay đổi trạng thái
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    // 3. Kiểm tra logic ràng buộc dữ liệu (Validation)
    testWidgets('Hiển thị lỗi khi dữ liệu nhập vào không hợp lệ', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      final btnSave = find.text('LƯU THAY ĐỔI');

      // Case 1: Để trống toàn bộ
      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Vui lòng nhập thông tin.'), findsWidgets);

      // Case 2: Mật khẩu quá ngắn
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), '123');
      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự.'), findsOneWidget);

      // Case 3: Xác nhận mật khẩu không khớp
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'), 'wrongpass');
      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Mật khẩu xác nhận không khớp.'), findsOneWidget);
    });

    // 4. Kiểm tra luồng nhập liệu hợp lệ
    testWidgets('Cho phép nhập liệu hợp lệ vào tất cả các trường', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu hiện tại'), 'old_pass_123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'new_pass_123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'), 'new_pass_123');
      
      await tester.pump();

      // Xác nhận giá trị hiển thị trên UI
      expect(find.text('old_pass_123'), findsOneWidget);
      expect(find.text('new_pass_123'), findsNWidgets(2));
      
      // Không còn thông báo lỗi nào xuất hiện
      expect(find.text('Vui lòng nhập thông tin.'), findsNothing);
    });
  });
}