import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import BỔ SUNG

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Khởi tạo BỔ SUNG

  // 1. Đăng ký tài khoản mới (Sử dụng sau khi OTP thành công)
  Future<String?> signUp({required String email, required String password, required String name}) async {
    try {
      // Tạo user trong Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Quan trọng: Lưu thông tin chi tiết vào Firestore để quản lý
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': name,
          'role': 'user', // Mặc định là user, Admin sẽ sửa trong Database sau
          'createdAt': Timestamp.now(),
          'favorites': [], // Tạo sẵn mảng rỗng
        });
        return null; // Thành công (không có lỗi)
      }
      return "Lỗi không xác định";
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về thông báo lỗi (VD: Email đã tồn tại)
    }
  }

  // 2. Đăng nhập
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi thường gặp
      if (e.code == 'user-not-found') return 'Không tìm thấy người dùng với Email này.';
      if (e.code == 'wrong-password') return 'Mật khẩu không đúng.';
      return e.message;
    }
  }

  // 3. Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. Lấy Role (Quyền) của User hiện tại
  Future<String> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc['role'] ?? 'user';
      }
    }
    return 'user';
  }

  // 5. Đăng nhập bằng Google
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Mở cửa sổ chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Hủy đăng nhập"; // Người dùng tắt bảng chọn

      // 2. Lấy xác thực từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Tạo credential để gửi cho Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // 5. Nếu là user mới -> Lưu vào Firestore
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'fullName': user.displayName,
            'role': 'user',
            'createdAt': Timestamp.now(),
            'favorites': [],
            'avatar': user.photoURL, // Lấy luôn ảnh đại diện Google
          });
        }
      }
      return null; // Thành công
    } catch (e) {
      return e.toString();
    }
  }

  // 6. Quên mật khẩu
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}