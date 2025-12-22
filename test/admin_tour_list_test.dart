import 'package:flutter_test/flutter_test.dart';
import 'package:trivok/screens/admin/admin_tourList_screen.dart';

void main() {
  group('AdminTourListScreen Logic Tests', () {
    
    test('Hàm formatPrice phải hiển thị đúng định dạng tiền tệ Việt Nam', () {
      
      expect(AdminTourListScreen.formatPrice(5000000), '5,000,000');
      
      expect(AdminTourListScreen.formatPrice(123456), '123,456');
      
      expect(AdminTourListScreen.formatPrice(500), '500');
      
      expect(AdminTourListScreen.formatPrice(0), '0');

      expect(AdminTourListScreen.formatPrice(1000.5), '1,001'); 
    });
  });
}