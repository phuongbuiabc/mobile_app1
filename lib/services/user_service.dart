import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tour_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy ID user hiện tại
  String? get currentUserId => _auth.currentUser?.uid;

  // 1. Thêm/Xóa Tour khỏi danh sách yêu thích
  Future<void> toggleFavorite(String tourId) async {
    if (currentUserId == null) return;

    final userRef = _firestore.collection('users').doc(currentUserId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      List<dynamic> favorites = userDoc.data()?['favorites'] ?? [];

      if (favorites.contains(tourId)) {
        // Nếu đã có -> Xóa
        await userRef.update({
          'favorites': FieldValue.arrayRemove([tourId])
        });
      } else {
        // Nếu chưa có -> Thêm
        await userRef.update({
          'favorites': FieldValue.arrayUnion([tourId])
        });
      }
    }
  }

  // 2. Lấy danh sách Tour yêu thích (Stream để tự động cập nhật)
  Stream<List<TourModel>> getFavoriteToursStream() {
    if (currentUserId == null) return Stream.value([]);

    // Logic: Lắng nghe user -> lấy mảng favorites -> query bảng tours
    return _firestore.collection('users').doc(currentUserId).snapshots().asyncMap((userSnapshot) async {
      List<dynamic> favoriteIds = userSnapshot.data()?['favorites'] ?? [];

      if (favoriteIds.isEmpty) return [];

      // Query bảng tours để lấy thông tin chi tiết các tour trong list ID
      // Lưu ý: Firestore whereIn giới hạn 10 phần tử. Với đồ án nhỏ thì OK.
      // Nếu > 10, cần chia mảng để query (Nâng cao).
      final toursSnapshot = await _firestore
          .collection('tours')
          .where(FieldPath.documentId, whereIn: favoriteIds.take(10).toList())
          .get();

      return toursSnapshot.docs.map((doc) {
        return TourModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}