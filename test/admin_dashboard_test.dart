import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sửa dòng dưới đây thành đường dẫn đúng tới file admin_dashboard_screen.dart trong project của bạn
import 'package:trivok/screens/admin/admin_dashboard_screen.dart'; 

void main() {
  // Nhóm các bài test cho màn hình này
  group('AdminDashboardScreen Test', () {
    
    testWidgets('Kiểm tra các thành phần UI chính hiển thị đúng', (WidgetTester tester) async {
      // 1. Giả lập việc build màn hình. 
      // Phải bọc trong MaterialApp vì màn hình có dùng Scaffold và Navigator.
      await tester.pumpWidget(const MaterialApp(
        home: AdminDashboardScreen(),
      ));

      // 2. Kiểm tra xem Tiêu đề AppBar có hiện không
      expect(find.text('Trivok | Quản trị Tour'), findsOneWidget);

      // 3. Kiểm tra xem nút Logout có hiện không
      expect(find.byIcon(Icons.logout), findsOneWidget);

      // 4. Kiểm tra nút quan trọng nhất "THÊM TOUR MỚI" có hiện không
      expect(find.text('THÊM TOUR MỚI'), findsOneWidget);

      // 5. Kiểm tra các mục menu khác có hiện đủ không
      expect(find.text('Quản lý Đơn đặt vé'), findsOneWidget);
      expect(find.text('Danh sách Tour'), findsOneWidget);
      expect(find.text('Quản lý Người dùng'), findsOneWidget);
    });
  });
}