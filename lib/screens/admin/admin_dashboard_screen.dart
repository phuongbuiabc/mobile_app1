import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/palette.dart';
import 'add_tour_screen.dart';
import 'admin_booking_screen.dart'; // Import màn hình quản lý đơn hàng

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trivok | Quản trị Tour", style: TextStyle(color: Colors.white)),
        backgroundColor: Palette.accent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ chào mừng
            Card(
              color: Palette.accent.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.verified_user, color: Palette.accent),
                title: Text("Trang quản trị"),
                subtitle: Text("Quản lý Tour, Đơn hàng và Người dùng."),
              ),
            ),

            const SizedBox(height: 20),

            // Nút quan trọng nhất: THÊM TOUR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTourScreen()));
                },
                icon: const Icon(Icons.add_box, color: Colors.white),
                label: const Text("THÊM TOUR MỚI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Các chức năng quản lý khác:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),

            // Nút Quản lý Đơn hàng (Đã kích hoạt)
            _buildAdminTile(
                context,
                "Quản lý Đơn đặt vé",
                Icons.receipt_long,
                Palette.primary,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingScreen()))
            ),

            // Các nút Placeholder (Chưa kích hoạt)
            _buildAdminTile(context, "Danh sách Tour", Icons.list, Palette.primary, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
            }),
            _buildAdminTile(context, "Quản lý Người dùng", Icons.group, Palette.primary, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}