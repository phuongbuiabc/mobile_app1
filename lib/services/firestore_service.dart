import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. THÊM Tour mới (Admin) - Cập nhật Schema
  Future<String?> addTour({
    required String title,
    required double price,
    required List<String> images,
    required String description,
    required String destination,
    required List<String> itinerary,
    double rate = 5.0,
    bool isActive = true,
  }) async {
    try {
      if (images.isEmpty) {
        return "Vui lòng cung cấp ít nhất 1 ảnh.";
      }

      await _firestore.collection('tours').add({
        'title': title,
        'price': price,
        'images': images, // Lưu mảng ảnh
        'description': description,
        'destination': destination,
        'itinerary': itinerary, // Lưu mảng lịch trình
        'rate': rate,
        'is_active': isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Thành công
    } catch (e) {
      return 'Lỗi thêm tour: ${e.toString()}';
    }
  }

  // 2. ĐẶT VÉ (Client) - Giữ nguyên
  Future<String?> placeBooking(BookingModel booking) async {
    try {
      DocumentReference ref = await _firestore.collection('bookings').add(booking.toJson());
      return ref.id;
    } catch (e) {
      print("Lỗi đặt vé: $e");
      return null;
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;
}