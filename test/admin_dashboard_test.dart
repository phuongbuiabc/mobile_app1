import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/admin/admin_dashboard_screen.dart'; 

void main() {
  // Nhóm các bài test cho màn hình này
  group('AdminDashboardScreen Test', () {
    
    testWidgets('Kiểm tra các thành phần UI chính hiển thị đúng', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AdminDashboardScreen(),
      ));

      expect(find.text('Trivok | Quản trị Tour'), findsOneWidget);

      expect(find.byIcon(Icons.logout), findsOneWidget);

      expect(find.text('THÊM TOUR MỚI'), findsOneWidget);

      expect(find.text('Quản lý Đơn đặt vé'), findsOneWidget);
      expect(find.text('Danh sách Tour'), findsOneWidget);
      expect(find.text('Quản lý Người dùng'), findsOneWidget);
    });
  });
}