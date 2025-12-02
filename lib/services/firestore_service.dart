import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. THÊM Tour mới (Admin)
  // Đã cập nhật: Nhận URL trực tiếp, thêm field duration/description cho tính năng So sánh
  Future<String?> addTour({
    required String name,
    required double price,
    required String imageUrl,
    required String duration,
    required String description,
  }) async {
    try {
      if (imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
        return "URL ảnh chính không hợp lệ. Vui lòng dán link ảnh công khai.";
      }

      await _firestore.collection('tours').add({
        'name': name,
        'price': price,
        'image': imageUrl,
        'duration': duration,
        'description': description,

        // Các trường mặc định
        'location': 'Việt Nam',
        'rating': 5.0,
        'isFeatured': false,
        'createdAt': Timestamp.now(),
      });

      return null; // Thành công
    } catch (e) {
      return 'Lỗi thêm tour: ${e.toString()}';
    }
  }

  // 2. ĐẶT VÉ (Client)
  // Hàm này nhận đối tượng BookingModel và lưu lên Firestore
  Future<String?> placeBooking(BookingModel booking) async {
    try {
      // Lưu đơn hàng vào collection 'bookings'
      DocumentReference ref = await _firestore.collection('bookings').add(booking.toJson());
      return ref.id; // Trả về ID đơn hàng (để tạo QR Code)
    } catch (e) {
      print("Lỗi đặt vé: $e");
      return null;
    }
  }

  // 3. Tiện ích: Lấy User ID hiện tại
  String? get currentUserId => _auth.currentUser?.uid;
}