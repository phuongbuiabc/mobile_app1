import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cập nhật thông tin người dùng (Admin)
  Future<String?> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null && fullName.isNotEmpty) {
        updates['fullName'] = fullName;
        // Cập nhật displayName trong Firebase Auth nếu có thể
        try {
          final user = await _auth.currentUser;
          if (user != null && user.uid == userId) {
            await user.updateDisplayName(fullName);
            await user.reload();
          }
        } catch (e) {
          // Nếu không thể cập nhật Auth, chỉ cập nhật Firestore
          print("Không thể cập nhật displayName trong Auth: $e");
        }
      }

      if (email != null && email.isNotEmpty) {
        updates['email'] = email;
      }

      if (phone != null) {
        if (phone.isEmpty) {
          // Nếu phone rỗng, xóa field khỏi Firestore
          updates['phone'] = FieldValue.delete();
        } else {
          updates['phone'] = phone;
        }
      }

      if (role != null && role.isNotEmpty) {
        updates['role'] = role;
      }

      if (avatar != null) {
        if (avatar.isEmpty) {
          updates['avatar'] = FieldValue.delete();
        } else {
          updates['avatar'] = avatar;
        }
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }

      return null; // Thành công
    } catch (e) {
      return 'Lỗi cập nhật thông tin người dùng: ${e.toString()}';
    }
  }

  // Lấy thông tin chi tiết của một user
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Lỗi lấy thông tin user: $e");
      return null;
    }
  }
}

