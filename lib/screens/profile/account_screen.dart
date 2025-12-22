import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/palette.dart';
import 'package:intl/intl.dart';
import './change_userInfor_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      // In ra lỗi để debug
      print("Error fetching user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin từ cả hai nguồn, ưu tiên Firestore
    final String displayName =
        _userData?['fullName'] ?? _currentUser?.displayName ?? 'Không có tên';
    final String email =
        _userData?['email'] ?? _currentUser?.email ?? 'Không có email';
    final String? avatarUrl = _userData?['avatar'] ?? _currentUser?.photoURL;

    // Lấy số điện thoại: ưu tiên Firestore, sau đó Auth, cuối cùng là "Chưa cập nhật"
    final String phone;
    final phoneFromFirestore = _userData?['phone'];
    if (phoneFromFirestore != null &&
        phoneFromFirestore.toString().isNotEmpty) {
      phone = phoneFromFirestore.toString();
    } else {
      final phoneFromAuth = _currentUser?.phoneNumber;
      if (phoneFromAuth != null && phoneFromAuth.isNotEmpty) {
        phone = phoneFromAuth;
      } else {
        phone = 'Chưa cập nhật số điện thoại';
      }
    }

    final String createAt;
    if (_userData?['createdAt'] != null) {
      final timestamp = _userData!['createdAt'] as Timestamp;
      final dateTime = timestamp.toDate();
      createAt = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } else {
      createAt = 'Không có ngày tạo';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? const Center(child: Text("Không tìm thấy người dùng."))
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 40),
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: 'Họ và tên',
                  value: displayName,
                ),
                const Divider(height: 30),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
                const Divider(height: 30),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Số điện thoại',
                  value: phone,
                ),
                const Divider(height: 30),
                _buildInfoTile(
                  icon: Icons.done_all_sharp,
                  label: 'Ngày tạo',
                  value: createAt, // Giả sử chưa có
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    // 1. Thêm từ khóa 'await' để đợi màn hình ChangeUserInfoScreen trả về kết quả
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangeUserInfoScreen(),
                      ),
                    );

                    // 2. Kiểm tra kết quả. Nếu trả về true nghĩa là người dùng đã bấm "Lưu thay đổi"
                    if (result == true) {
                      _fetchUserData();
                      if (context.mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CHỈNH SỬA THÔNG TIN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Palette.textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
