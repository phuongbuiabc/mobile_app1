import 'package:flutter/material.dart';
import '../models/tour_model.dart';

class ComparisonProvider extends ChangeNotifier {
  // Danh sách lưu trữ các Tour đang được so sánh (Tối đa 2 Tour)
  final List<TourModel> _comparisonList = [];

  List<TourModel> get comparisonList => _comparisonList;

  // Thêm/Xóa Tour vào danh sách so sánh
  void toggleComparison(TourModel tour) {
    if (_comparisonList.any((t) => t.id == tour.id)) {
      // Nếu Tour đã có -> Xóa ra
      _comparisonList.removeWhere((t) => t.id == tour.id);
    } else {
      // Nếu Tour chưa có
      if (_comparisonList.length < 2) {
        // Nếu chưa đủ 2 Tour -> Thêm vào
        _comparisonList.add(tour);
      } else {
        // Nếu đã đủ 2 Tour (Tự động thay thế Tour cũ nhất)
        _comparisonList.removeAt(0); // Xóa Tour đầu tiên
        _comparisonList.add(tour);    // Thêm Tour mới vào
      }
    }
    notifyListeners();
  }

  // Xóa toàn bộ danh sách
  void clearComparison() {
    _comparisonList.clear();
    notifyListeners();
  }

  // Kiểm tra xem Tour có đang nằm trong danh sách so sánh không
  bool isInComparison(TourModel tour) {
    return _comparisonList.any((t) => t.id == tour.id);
  }
}