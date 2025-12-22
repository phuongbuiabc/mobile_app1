import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/palette.dart';
import '../../services/user_admin_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditUserScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserAdminService _userAdminService = UserAdminService();
  bool _isLoading = false;

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _avatarController = TextEditingController(text: widget.userData['avatar'] ?? '');
    _selectedRole = widget.userData['role'] ?? 'user';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error = await _userAdminService.updateUser(
      userId: widget.userId,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      avatar: _avatarController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin người dùng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa Người dùng", style: TextStyle(color: Colors.white)),
        backgroundColor: Palette.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Thông tin cơ bản"),
              _buildTextField(
                _fullNameController,
                "Họ và tên",
                Icons.person,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                "Email",
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                "Số điện thoại",
                Icons.phone,
                keyboardType: TextInputType.phone,
                hintText: "Nhập số điện thoại",
                isRequired: true,
                isPhone: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _avatarController,
                "Link ảnh đại diện",
                Icons.image,
                hintText: "https://example.com/avatar.jpg (tùy chọn)",
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Vai trò"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn vai trò',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Người dùng'),
                        subtitle: const Text('Quyền truy cập cơ bản'),
                        value: 'user',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        activeColor: Palette.primary,
                      ),
                      RadioListTile<String>(
                        title: const Text('Quản trị viên'),
                        subtitle: const Text('Quyền truy cập đầy đủ'),
                        value: 'admin',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "CẬP NHẬT THÔNG TIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Palette.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String hintText = '',
    bool isRequired = false,
    bool isPhone = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: Palette.primary),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      validator: (val) {
        final value = val?.trim() ?? '';

        if (isRequired && value.isEmpty) {
          return "Vui lòng nhập $label";
        }

        if (isPhone && value.isNotEmpty) {
          // Chỉ cho phép số, bắt đầu bằng 0 và đủ 10 ký tự
          final numericRegex = RegExp(r'^\d+$');
          if (!numericRegex.hasMatch(value)) {
            return "Số điện thoại chỉ được chứa số";
          }
          if (value.length != 10) {
            return "Số điện thoại phải có đúng 10 chữ số";
          }
          if (!value.startsWith('0')) {
            return "Số điện thoại phải bắt đầu bằng số 0";
          }
        }

        return null;
      },
    );
  }
}

