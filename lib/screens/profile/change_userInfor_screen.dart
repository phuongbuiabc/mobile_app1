import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Đảm bảo đường dẫn import này đúng trong dự án của bạn
import '../../config/palette.dart';

class ChangeUserInfoScreen extends StatefulWidget {
  const ChangeUserInfoScreen({super.key});

  @override
  State<ChangeUserInfoScreen> createState() => _ChangeUserInfoScreenState();
}

class _ChangeUserInfoScreenState extends State<ChangeUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Khởi tạo map controller rỗng
  final Map<String, TextEditingController> _controllers = {};

  // Biến check loading khi lưu
  bool _isSaving = false;
  // Biến check loading khi mới vào màn hình (lấy dữ liệu)
  bool _isFetching = true;

  Map<String, dynamic>? _userData;

  final List<_FieldDef> _fields = [
    _FieldDef(
      key: 'displayName',
      label: 'Tên hiển thị',
      hint: 'Nhập tên của bạn',
    ),
    _FieldDef(
      key: 'phone',
      label: 'Số điện thoại',
      hint: 'Nhập số điện thoại của bạn',
    ),
    _FieldDef(
      key: 'avatar',
      label: 'Link ảnh đại diện',
      hint: 'Nhập link ảnh đại diện (tùy chọn)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 1. Khởi tạo controller ngay lập tức với giá trị rỗng để tránh lỗi null ở hàm build
    for (final f in _fields) {
      _controllers[f.key] = TextEditingController();
    }
    // 2. Sau đó mới đi lấy dữ liệu
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isFetching = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userData = doc.data();
      }

      // Cập nhật text cho từng controller dựa trên dữ liệu lấy về
      for (final f in _fields) {
        final initialValue = _getInitialValueForField(user, f.key);
        // Lưu ý: Cần gán vào thuộc tính .text của controller đã tồn tại
        if (_controllers.containsKey(f.key)) {
          _controllers[f.key]!.text = initialValue ?? '';
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu user: $e");
      // Nếu lỗi, thử fill bằng dữ liệu từ Auth (fallback)
      for (final f in _fields) {
        if (_controllers.containsKey(f.key)) {
          _controllers[f.key]!.text =
              _getInitialValueForField(user, f.key) ?? '';
        }
      }
    } finally {
      // QUAN TRỌNG: Phải setState để giao diện hiển thị dữ liệu vừa điền vào controller
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  String? _getInitialValueForField(User? user, String key) {
    if (user == null) return '';

    switch (key) {
      case 'displayName':
        // Ưu tiên lấy fullName trong collection users
        final fullNameFromFirestore = _userData?['fullName'];
        if (fullNameFromFirestore != null &&
            fullNameFromFirestore.toString().isNotEmpty) {
          return fullNameFromFirestore.toString();
        }
        // Nếu không có thì lấy từ Auth
        return user.displayName ?? '';

      case 'phone':
        // Ưu tiên lấy phone trong collection users
        final phoneFromFirestore = _userData?['phone'];
        if (phoneFromFirestore != null &&
            phoneFromFirestore.toString().isNotEmpty) {
          return phoneFromFirestore.toString();
        }
        // Nếu không có thì lấy từ Auth
        return user.phoneNumber ?? '';

      case 'avatar':
        // Lấy avatar từ Firestore
        final avatarFromFirestore = _userData?['avatar'];
        if (avatarFromFirestore != null &&
            avatarFromFirestore.toString().isNotEmpty) {
          return avatarFromFirestore.toString();
        }
        // Nếu không có thì để trống
        return '';

      default:
        return '';
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      setState(() => _isSaving = false);
      return;
    }

    try {
      final updates = <String, dynamic>{};

      // Xử lý Tên hiển thị
      final displayNameInput = _controllers['displayName']!.text.trim();
      // Logic kiểm tra thay đổi tên
      // Lấy tên hiện tại từ Auth
      final currentAuthName = user.displayName;

      // Nếu tên nhập vào khác tên trong DB hoặc (nếu DB chưa có thì khác Auth)
      if (displayNameInput.isNotEmpty) {
        updates['fullName'] = displayNameInput;
        // Cập nhật luôn profile Auth để đồng bộ
        if (displayNameInput != currentAuthName) {
          await user.updateDisplayName(displayNameInput);
        }
      }

      // Xử lý Số điện thoại
      final phoneInput = _controllers['phone']!.text.trim();
      final currentPhone =
          _userData?['phone']?.toString() ?? user.phoneNumber ?? '';

      if (phoneInput.isNotEmpty && phoneInput != currentPhone) {
        updates['phone'] = phoneInput;
      } else if (phoneInput.isEmpty && currentPhone.isNotEmpty) {
        // Nếu người dùng xóa sđt, xóa field đó trong firestore
        updates['phone'] = FieldValue.delete();
      }

      // Xử lý Avatar
      final avatarInput = _controllers['avatar']!.text.trim();
      final currentAvatar = _userData?['avatar']?.toString() ?? '';

      if (avatarInput != currentAvatar) {
        if (avatarInput.isNotEmpty) {
          updates['avatar'] = avatarInput;
        } else {
          // Nếu người dùng xóa avatar, xóa field đó trong firestore
          updates['avatar'] = FieldValue.delete();
        }
      }

      if (updates.isNotEmpty) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        // Sử dụng set với merge: true để tạo doc nếu chưa có, hoặc update nếu đã có
        await docRef.set(updates, SetOptions(merge: true));

        // Cập nhật lại _userData cục bộ để lần sau check không bị sai
        // (Hoặc đơn giản là reload lại data)
        if (_userData == null) {
          _userData = updates;
        } else {
          _userData!.addAll(updates);
        }
      }

      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Trả về true để báo hiệu đã cập nhật thành công
      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      _showError('Lỗi Firebase: ${e.message}');
    } catch (e) {
      _showError('Đã xảy ra lỗi không xác định.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      // Hiển thị vòng xoay loading khi đang tải dữ liệu ban đầu
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  ..._fields.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _controllers[f.key],
                        decoration: InputDecoration(
                          labelText: f.label,
                          hintText: f.hint,
                          border: const OutlineInputBorder(),
                          // Thêm prefix icon cho đẹp (tùy chọn)
                          prefixIcon: f.key == 'displayName'
                              ? const Icon(Icons.person)
                              : f.key == 'phone'
                                  ? const Icon(Icons.phone)
                                  : const Icon(Icons.image),
                        ),
                        keyboardType: f.key == 'phone'
                            ? TextInputType.phone
                            : f.key == 'avatar'
                                ? TextInputType.url
                                : TextInputType.text,
                        validator: (value) {
                          if (f.key == 'displayName') {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên.';
                            }
                            if (value.trim().length < 2) return 'Tên quá ngắn.';
                          } else if (f.key == 'phone') {
                            if (value != null && value.trim().isNotEmpty) {
                              final phoneRegex = RegExp(r'^[0-9]{10,11}$');
                              if (!phoneRegex.hasMatch(value.trim())) {
                                return 'Số điện thoại không hợp lệ (10-11 số).';
                              }
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
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
}

class _FieldDef {
  final String key;
  final String label;
  final String hint;
  const _FieldDef({required this.key, required this.label, this.hint = ''});
}
