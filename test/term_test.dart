import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Nhớ thay 'trivok' bằng tên project thực tế của cậu trong pubspec.yaml
import 'package:trivok/screens/profile/terms_of_service_screen.dart';

void main() {
  group('TermsOfServiceScreen Test', () {
    
    testWidgets('Hiển thị đầy đủ nội dung điều khoản và cuộn được', (WidgetTester tester) async {
      // 1. Build màn hình
      // Vì màn hình này "tĩnh" hoàn toàn, ta không cần mock cái gì cả. Sướng chưa?
      await tester.pumpWidget(const MaterialApp(
        home: TermsOfServiceScreen(),
      ));

      // 2. Kiểm tra Tiêu đề màn hình
      expect(find.text('Điều khoản dịch vụ'), findsOneWidget);

      // 3. Kiểm tra sự tồn tại của mục đầu tiên (thường sẽ nhìn thấy ngay)
      expect(find.text('1. Chấp nhận Điều khoản'), findsOneWidget);

      // 4. Kiểm tra tính năng Cuộn (Scroll)
      // Các mục ở dưới cùng (như mục 6) có thể bị che khuất trên màn hình điện thoại nhỏ.
      // Ta dùng scrollUntilVisible để giả lập hành động vuốt của người dùng.
      
      final lastSectionFinder = find.text('6. Thay đổi Điều khoản');
      final dateFinder = find.text('Cập nhật lần cuối: 08/12/2025');

      // Ra lệnh cho tester: "Hãy cuộn cái list cho đến khi thấy mục số 6"
      await tester.scrollUntilVisible(
        lastSectionFinder,
        500.0, // Mỗi lần vuốt 500 pixel
        scrollable: find.byType(Scrollable), // Tìm cái gì cuộn được (ListView)
      );

      // Sau khi cuộn xong, kiểm tra xem nó có hiện ra không
      expect(lastSectionFinder, findsOneWidget);

      // Cuộn tiếp xuống đáy để xem ngày cập nhật
      await tester.scrollUntilVisible(
        dateFinder,
        500.0,
        scrollable: find.byType(Scrollable),
      );
      
      expect(dateFinder, findsOneWidget);
    });
  });
}