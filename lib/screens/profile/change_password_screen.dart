import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../config/palette.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showError("Không tìm thấy người dùng. Vui lòng đăng nhập lại.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Bước 1: Yêu cầu người dùng xác thực lại. Đây là bước bảo mật bắt buộc của Firebase.
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Bước 2: Nếu xác thực thành công, tiến hành đổi mật khẩu mới.
      await user.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đổi mật khẩu thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showError("Mật khẩu hiện tại không đúng.");
      } else if (e.code == 'weak-password') {
        _showError("Mật khẩu mới phải có ít nhất 6 ký tự.");
      } else {
        _showError("Đã xảy ra lỗi: ${e.message}");
      }
    } catch (e) {
      _showError("Đã xảy ra lỗi không xác định. Vui lòng thử lại.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Mật khẩu hiện tại',
              obscureText: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Mật khẩu mới',
              obscureText: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới.';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Xác nhận mật khẩu mới',
              obscureText: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Mật khẩu xác nhận không khớp.';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'LƯU THAY ĐỔI',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty)
              return 'Vui lòng nhập thông tin.';
            return null;
          },
    );
  }
}
