import 'package:flutter/material.dart';
import '../../config/palette.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Giả lập trạng thái của các cài đặt
  bool _ticketStatusNotif = true;
  bool _promoNotif = true;
  bool _tripReminderNotif = false;
  String _themeMode = 'Hệ thống';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Quản lý thông báo'),
          _buildSwitchTile(
            title: 'Cập nhật trạng thái vé',
            subtitle: 'Nhận thông báo khi vé được duyệt, hủy...',
            value: _ticketStatusNotif,
            onChanged: (val) => setState(() => _ticketStatusNotif = val),
          ),
          _buildSwitchTile(
            title: 'Khuyến mãi & Tour mới',
            subtitle: 'Nhận thông báo về các ưu đãi đặc biệt',
            value: _promoNotif,
            onChanged: (val) => setState(() => _promoNotif = val),
          ),
          _buildSwitchTile(
            title: 'Nhắc nhở chuyến đi',
            subtitle: 'Nhận thông báo trước ngày khởi hành',
            value: _tripReminderNotif,
            onChanged: (val) => setState(() => _tripReminderNotif = val),
          ),
          const Divider(height: 20),
          _buildSectionHeader('Tài khoản & Bảo mật'),
          _buildNavigationTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(height: 20),
          _buildSectionHeader('Giao diện'),
          _buildNavigationTile(
            icon: Icons.brightness_6_outlined,
            title: 'Chế độ hiển thị',
            trailing: Text(
              _themeMode,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            onTap: _showThemeDialog,
          ),
          const Divider(height: 20),
          _buildSectionHeader('Pháp lý & Thông tin'),
          _buildNavigationTile(
            icon: Icons.description_outlined,
            title: 'Điều khoản dịch vụ',
            onTap: () {},
          ),
          _buildNavigationTile(
            icon: Icons.shield_outlined,
            title: 'Chính sách bảo mật',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Widget cho tiêu đề của mỗi nhóm cài đặt
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget cho cài đặt dạng bật/tắt
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Palette.textMain)),
      subtitle: Text(subtitle, style: const TextStyle(color: Palette.textSub)),
      value: value,
      onChanged: onChanged,
      activeColor: Palette.accent,
      inactiveThumbColor: Colors.grey,
    );
  }

  // Widget cho cài đặt điều hướng đến trang khác
  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(color: Palette.textMain)),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Hiển thị dialog chọn chế độ sáng/tối
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn chế độ hiển thị'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Sáng'),
                value: 'Sáng',
                groupValue: _themeMode,
                onChanged: (val) => setState(() {
                  _themeMode = val!;
                  Navigator.pop(context);
                }),
              ),
              RadioListTile<String>(
                title: const Text('Tối'),
                value: 'Tối',
                groupValue: _themeMode,
                onChanged: (val) => setState(() {
                  _themeMode = val!;
                  Navigator.pop(context);
                }),
              ),
              RadioListTile<String>(
                title: const Text('Theo hệ thống'),
                value: 'Hệ thống',
                groupValue: _themeMode,
                onChanged: (val) => setState(() {
                  _themeMode = val!;
                  Navigator.pop(context);
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
