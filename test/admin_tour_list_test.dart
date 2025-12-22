import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/admin/admin_tourList_screen.dart';

void main() {
  group('AdminTourListScreen Logic Tests', () {
    
    test('Hàm formatPrice phải hiển thị đúng định dạng tiền tệ Việt Nam', () {
      
      // Case 1: Số tiền hàng triệu
      expect(AdminTourListScreen.formatPrice(5000000), '5,000,000');
      
      // Case 2: Số tiền lẻ
      expect(AdminTourListScreen.formatPrice(123456), '123,456');
      
      // Case 3: Số tiền nhỏ
      expect(AdminTourListScreen.formatPrice(500), '500');
      
      // Case 4: Số 0
      expect(AdminTourListScreen.formatPrice(0), '0');

      // Case 5: Số thập phân (Logic code hiện tại của cậu là toStringAsFixed(0) nên sẽ làm tròn)
      expect(AdminTourListScreen.formatPrice(1000.5), '1,001'); 
    });
  });
}