import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../config/palette.dart';

class ChangeUserInfoScreen extends StatefulWidget {
  const ChangeUserInfoScreen({super.key});

  @override
  State<ChangeUserInfoScreen> createState() => _ChangeUserInfoScreenState();
}

class _ChangeUserInfoScreenState extends State<ChangeUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  // Define fields here so it's easy to add more later.
  final List<_FieldDef> _fields = [
    _FieldDef(
      key: 'displayName',
      label: 'Tên hiển thị',
      hint: 'Nhập tên của bạn',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    for (final f in _fields) {
      final initial = _getInitialValueForField(user, f.key);
      _controllers[f.key] = TextEditingController(text: initial);
    }
  }

  String? _getInitialValueForField(User? user, String key) {
    if (user == null) return null;
    switch (key) {
      case 'displayName':
        return user.displayName ?? '';
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

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final updates = <String, dynamic>{};

      // Currently we only handle displayName, but this scales easily.
      final displayName = _controllers['displayName']!.text.trim();
      if (displayName.isNotEmpty && displayName != user.displayName) {
        // Update Firebase Auth profile
        await user.updateDisplayName(displayName);
        // Store the user's full name in Firestore under the `fullName` field.
        updates['fullName'] = displayName;
      }

      // Persist to Firestore users collection (merge so we don't overwrite other fields)
      if (updates.isNotEmpty) {
        final doc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await doc.set(updates, SetOptions(merge: true));
      }

      // Optionally reload user so changes are reflected in currentUser
      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      _showError('Đã xảy ra lỗi khi lưu: ${e.message}');
    } catch (e) {
      _showError('Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
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
                  ),
                  validator: (value) {
                    if (f.key == 'displayName') {
                      if (value == null || value.trim().isEmpty)
                        return 'Vui lòng nhập tên.';
                      if (value.trim().length < 2) return 'Tên quá ngắn.';
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
                onPressed: _isLoading ? null : _save,
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
}

// Simple field definition to make adding fields later straightforward.
class _FieldDef {
  final String key;
  final String label;
  final String hint;
  const _FieldDef({required this.key, required this.label, this.hint = ''});
}
