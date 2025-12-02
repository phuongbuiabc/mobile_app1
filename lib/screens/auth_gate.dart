import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'client/client_home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. StreamBuilder lắng nghe trạng thái Đăng nhập của Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // App đang khởi động hoặc kiểm tra trạng thái
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // 2. Nếu CHƯA ĐĂNG NHẬP
        if (user == null) {
          return const LoginScreen();
        }

        // 3. Nếu ĐÃ ĐĂNG NHẬP -> Kiểm tra Role (Quyền)
        return FutureBuilder<String>(
          future: AuthService().getUserRole(), // Gọi hàm kiểm tra Role từ Firestore
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data;

            // 4. Phân luồng theo Role
            if (role == 'admin') {
              return const AdminDashboardScreen();
            } else {
              // Mặc định là 'user' hoặc Role khác
              return const ClientHomeScreen();
            }
          },
        );
      },
    );
  }
}