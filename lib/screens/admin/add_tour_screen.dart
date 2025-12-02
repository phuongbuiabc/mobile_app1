import 'package:flutter/material.dart';
import '../../config/palette.dart';
import '../../services/firestore_service.dart';

class AddTourScreen extends StatefulWidget {
  const AddTourScreen({super.key});

  @override
  State<AddTourScreen> createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Controllers cho các trường nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(); // Thời gian (VD: 3N2Đ)
  final TextEditingController _descriptionController = TextEditingController(); // Mô tả chi tiết

  // Hàm xử lý khi bấm nút LƯU
  Future<void> _submit() async {
    // 1. Validate Form (Kiểm tra dữ liệu rỗng)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ thông tin.")));
      return;
    }

    // Kiểm tra riêng URL ảnh (phải có giá trị)
    if (_imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng dán URL ảnh chính.")));
      return;
    }

    setState(() => _isLoading = true);

    // Chuyển đổi giá từ String sang Double
    double price = double.tryParse(_priceController.text) ?? 0.0;

    // 2. Gọi Service để lưu vào Firestore
    String? error = await _firestoreService.addTour(
      name: _nameController.text.trim(),
      price: price,
      imageUrl: _imageUrlController.text.trim(),
      duration: _durationController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);

    // 3. Xử lý kết quả
    if (error == null) {
      // Thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thêm Tour thành công!")));
        Navigator.pop(context); // Quay về Dashboard
      }
    } else {
      // Thất bại
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ controller khi thoát màn hình
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Tour Mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Palette.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ô nhập URL Ảnh (Quan trọng nhất để hiển thị đẹp)
              _buildTextField(
                  _imageUrlController,
                  "URL Ảnh Chính",
                  Icons.photo_size_select_actual,
                  hintText: "Dán link ảnh chất lượng cao (VD: Imgur, Google Photos)"
              ),
              const SizedBox(height: 20),

              // Tên Tour
              _buildTextField(_nameController, "Tên Tour", Icons.title),
              const SizedBox(height: 15),

              // Giá Tour
              _buildTextField(
                  _priceController,
                  "Giá Tour (VNĐ)",
                  Icons.attach_money,
                  keyboardType: TextInputType.number
              ),
              const SizedBox(height: 15),

              // Thời gian (Quan trọng cho so sánh)
              _buildTextField(
                  _durationController,
                  "Thời gian Tour",
                  Icons.access_time,
                  hintText: "Ví dụ: 3 ngày 2 đêm"
              ),
              const SizedBox(height: 15),

              // Mô tả ngắn
              _buildTextField(
                  _descriptionController,
                  "Mô tả ngắn",
                  Icons.description,
                  maxLines: 4 // Cho phép nhập nhiều dòng
              ),
              const SizedBox(height: 40),

              // Nút Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("LƯU TOUR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con dùng chung để vẽ các ô nhập liệu đẹp mắt
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      {
        TextInputType keyboardType = TextInputType.text,
        String hintText = '',
        int? maxLines = 1
      }
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Palette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.accent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Không được để trống";
        if (keyboardType == TextInputType.number && double.tryParse(value) == null) return "Vui lòng nhập số hợp lệ";
        return null;
      },
    );
  }
}