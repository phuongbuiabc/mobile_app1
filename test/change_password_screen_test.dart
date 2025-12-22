import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/profile/change_password_screen.dart';

void main() {
  group('ChangePasswordScreen Tests', () {
    testWidgets('Hiển thị đầy đủ các thành phần giao diện chính', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('LƯU THAY ĐỔI'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
    });

    testWidgets('Tính năng ẩn/hiện mật khẩu hoạt động chính xác', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('Hiển thị lỗi khi dữ liệu nhập vào không hợp lệ', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      final btnSave = find.text('LƯU THAY ĐỔI');

      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Vui lòng nhập thông tin.'), findsWidgets);

      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), '123');
      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'), 'wrongpass');
      await tester.tap(btnSave);
      await tester.pump();
      expect(find.text('Mật khẩu xác nhận không khớp.'), findsOneWidget);
    });

    testWidgets('Cho phép nhập liệu hợp lệ vào tất cả các trường', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu hiện tại'), 'old_pass_123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'new_pass_123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'), 'new_pass_123');
      
      await tester.pump();

      expect(find.text('old_pass_123'), findsOneWidget);
      expect(find.text('new_pass_123'), findsNWidgets(2));
      
      expect(find.text('Vui lòng nhập thông tin.'), findsNothing);
    });
  });
}