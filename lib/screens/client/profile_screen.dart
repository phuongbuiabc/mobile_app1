import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/palette.dart';
import '../../../services/auth_service.dart';
import '../profile/about_us_screen.dart';
import '../profile/account_screen.dart';
import '../profile/help_screen.dart';
import '../profile/settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Vui lòng đăng nhập để xem thông tin", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AuthService().signOut(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Tới trang đăng nhập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final displayName = userData['fullName'] ?? user.displayName ?? "Khách hàng";
          final avatarUrl = userData['avatar'] ?? user.photoURL;
          final userRole = userData['role'] ?? 'Thành viên';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Cong với Gradient
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Palette.primary,
                elevation: 0,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gradient Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4CA1AF), Color(0xFF2C3E50)], // Gradient sang trọng
                          ),
                        ),
                      ),
                      // Họa tiết trang trí mờ
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: -50,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                        ),
                      ),

                      // Phần cong ở đáy header
                      Positioned(
                        bottom: -1,
                        left: 0, right: 0,
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                          ),
                        ),
                      ),

                      // Thông tin User
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
                              child: avatarUrl == null
                                  ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'K', style: const TextStyle(fontSize: 35, color: Palette.primary, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            displayName,
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black26, blurRadius: 5)]),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(userRole, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Danh sách Menu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),

                      _buildSectionTitle("Cài đặt tài khoản"),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: "Thông tin cá nhân",
                          subtitle: "Chỉnh sửa hồ sơ, ảnh đại diện",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: "Cài đặt ứng dụng",
                          subtitle: "Ngôn ngữ, thông báo",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _buildSectionTitle("Hỗ trợ & Khác"),
                      _buildMenuContainer([
                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: "Trợ giúp & FAQ",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: "Về Trivok",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                        ),
                      ]),

                      const SizedBox(height: 30),

                      // Nút Đăng xuất
                      TextButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        label: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Palette.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Hiệu ứng ripple bo tròn
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Palette.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, color: Palette.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3436))),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 60, endIndent: 20);
  }
}