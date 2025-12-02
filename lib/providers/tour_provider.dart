import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_model.dart';

class TourProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TourModel> _tours = [];
  bool _isLoading = false;

  List<TourModel> get tours => _tours;
  bool get isLoading => _isLoading;

  TourProvider() {
    fetchTours();
  }

  Future<void> fetchTours() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Query dữ liệu từ Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('tours')
          .get();

      // 2. Chuyển đổi Firestore data sang List<TourModel>
      _tours = snapshot.docs.map((doc) {
        return TourModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

    } catch (e) {
      print("Lỗi khi fetch tours: $e");
      // Có thể hiển thị thông báo lỗi ra UI nếu cần
    }

    _isLoading = false;
    notifyListeners();
  }
}