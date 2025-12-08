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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // DANH SÁCH ĐỘNG CHO ẢNH
  final List<TextEditingController> _imageControllers = [];

  // DANH SÁCH ĐỘNG CHO LỊCH TRÌNH (MỚI)
  final List<TextEditingController> _itineraryControllers = [];

  @override
  void initState() {
    super.initState();
    // Mặc định luôn có ít nhất 1 ô nhập ảnh và 1 dòng lịch trình
    _addImageField();
    _addItineraryField();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();

    // Dispose tất cả controller trong list
    for (var controller in _imageControllers) controller.dispose();
    for (var controller in _itineraryControllers) controller.dispose();

    super.dispose();
  }

  // --- LOGIC XỬ LÝ ẢNH ---
  void _addImageField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    setState(() {
      _imageControllers[index].dispose();
      _imageControllers.removeAt(index);
    });
  }

  // --- LOGIC XỬ LÝ LỊCH TRÌNH (MỚI) ---
  void _addItineraryField() {
    setState(() {
      _itineraryControllers.add(TextEditingController());
    });
  }

  void _removeItineraryField(int index) {
    setState(() {
      _itineraryControllers[index].dispose();
      _itineraryControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Lấy danh sách link ảnh
    List<String> imagesList = _imageControllers
        .map((controller) => controller.text.trim())
        .where((link) => link.isNotEmpty)
        .toList();

    // 2. Lấy danh sách lịch trình
    List<String> itineraryList = _itineraryControllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    // Kiểm tra dữ liệu rỗng
    if (imagesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập ít nhất 1 link ảnh!")));
      return;
    }
    if (itineraryList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập ít nhất 1 ngày lịch trình!")));
      return;
    }

    setState(() => _isLoading = true);

    double price = double.tryParse(_priceController.text) ?? 0.0;

    String? error = await _firestoreService.addTour(
      title: _titleController.text.trim(),
      price: price,
      images: imagesList,
      description: _descriptionController.text.trim(),
      destination: _destinationController.text.trim(),
      itinerary: itineraryList,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thêm Tour thành công!")));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Tour Mới", style: TextStyle(color: Colors.white)),
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
              _buildTextField(_titleController, "Tên Tour", Icons.title),
              const SizedBox(height: 10),
              _buildTextField(_destinationController, "Điểm đến", Icons.location_on),
              const SizedBox(height: 10),
              _buildTextField(_priceController, "Giá (VNĐ)", Icons.attach_money, keyboardType: TextInputType.number),

              const SizedBox(height: 25),

              // --- PHẦN 1: HÌNH ẢNH (DYNAMIC LIST) ---
              _buildSectionTitle("Hình ảnh (Images)"),
              const Text("Dán đường link ảnh vào bên dưới:", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),
              ..._imageControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                            entry.value,
                            "Link ảnh ${index + 1}",
                            Icons.image,
                            hintText: "https://example.com/image.jpg"
                        ),
                      ),
                      if (_imageControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeImageField(index),
                        ),
                    ],
                  ),
                );
              }).toList(),
              // Nút Thêm ảnh
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addImageField,
                  icon: const Icon(Icons.add_circle, color: Palette.primary),
                  label: const Text("Thêm ảnh khác", style: TextStyle(color: Palette.primary, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Chi tiết Tour"),
              _buildTextField(_descriptionController, "Mô tả chung", Icons.description, maxLines: 3),

              const SizedBox(height: 25),

              // --- PHẦN 2: LỊCH TRÌNH (DYNAMIC LIST - MỚI) ---
              _buildSectionTitle("Lịch trình (Itinerary)"),
              const Text("Nhập hoạt động chi tiết cho từng ngày:", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),
              ..._itineraryControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nhãn ngày (Ngày 1, Ngày 2...)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        decoration: BoxDecoration(color: Palette.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text("Ngày ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Palette.primary)),
                      ),
                      // Ô nhập nội dung
                      Expanded(
                        child: _buildTextField(
                            entry.value,
                            "Hoạt động ngày ${index + 1}",
                            Icons.event_note,
                            hintText: "VD: Đón khách, tham quan...",
                            maxLines: 2
                        ),
                      ),
                      // Nút xóa ngày
                      if (_itineraryControllers.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItineraryField(index),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              // Nút Thêm ngày
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addItineraryField,
                  icon: const Icon(Icons.add_circle, color: Palette.primary),
                  label: const Text("Thêm ngày tiếp theo", style: TextStyle(color: Palette.primary, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 40),

              // Nút Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Palette.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LƯU DATABASE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.primary)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, String hintText = '', int? maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 0), child: Icon(icon, color: Palette.primary)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Vui lòng nhập thông tin" : null,
    );
  }
}