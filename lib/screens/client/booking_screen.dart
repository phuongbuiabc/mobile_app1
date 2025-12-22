import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // flutter pub add intl
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import này để sửa lỗi DocumentReference
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import '../../models/booking_model.dart';
// import '../../services/firestore_service.dart'; // Có thể bỏ nếu không dùng hàm nào trong service này nữa
import 'payment_qr_screen.dart';

class BookingScreen extends StatefulWidget {
  final TourModel tour;
  const BookingScreen({super.key, required this.tour});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // State
  int _guestCount = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // List controller cho tên từng khách
  List<TextEditingController> _guestNameControllers = [];

  // final FirestoreService _service = FirestoreService(); // Không cần dùng service nếu gọi trực tiếp Firestore instance
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Auto-fill thông tin nếu đã đăng nhập
    if (currentUser != null) {
      _emailController.text = currentUser!.email ?? "";
      _nameController.text = currentUser!.displayName ?? "";
      // Phone thường phải lấy từ Firestore profile, ở đây tạm để trống
    }
    _updateGuestControllers();
  }

  void _updateGuestControllers() {
    // Điều chỉnh số lượng controller theo số khách
    while (_guestNameControllers.length < _guestCount) {
      _guestNameControllers.add(TextEditingController());
    }
    while (_guestNameControllers.length > _guestCount) {
      _guestNameControllers.last.dispose();
      _guestNameControllers.removeLast();
    }
    // Auto-fill khách đầu tiên là người đặt
    if (_guestNameControllers.isNotEmpty && _guestNameControllers[0].text.isEmpty) {
      _guestNameControllers[0].text = _nameController.text;
    }
  }

  double get _totalPrice => widget.tour.price * _guestCount;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Palette.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _processBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = currentUser?.uid ?? 'guest'; // Cho phép đặt vé guest hoặc yêu cầu login

      // Tạo map danh sách tên khách
      List<String> guestNames = _guestNameControllers.map((e) => e.text.trim()).toList();

      // Tạo Model Booking
      BookingModel newBooking = BookingModel(
        id: '',
        userId: userId,
        tourId: widget.tour.id,
        tourName: widget.tour.name, // Sử dụng getter name từ TourModel
        totalPrice: _totalPrice,
        guestCount: _guestCount,
        bookingDate: _selectedDate,
        status: 'pending',
        paymentStatus: 'unpaid',
        createdAt: DateTime.now(),
      );

      // Tạo Map dữ liệu đầy đủ để gửi lên Firestore
      Map<String, dynamic> bookingData = newBooking.toJson();
      bookingData['contactName'] = _nameController.text.trim();
      bookingData['contactPhone'] = _phoneController.text.trim();
      bookingData['contactEmail'] = _emailController.text.trim();
      bookingData['note'] = _noteController.text.trim();
      bookingData['guestNames'] = guestNames; // Lưu danh sách tên khách

      // SỬA LỖI: Gọi trực tiếp FirebaseFirestore.instance thay vì _service.db
      // Điều này sửa lỗi "The getter 'db' isn't defined" và lỗi "DocumentReference"
      DocumentReference docRef = await FirebaseFirestore.instance.collection('bookings').add(bookingData);
      String bookingId = docRef.id;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentQRScreen(
                bookingId: bookingId,
                amount: _totalPrice,
                content: "Thanh toan tour ${widget.tour.name}"
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Xác nhận đặt vé", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTourSummaryCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Thông tin chuyến đi"),
                      _buildTripConfigCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Thông tin liên hệ"),
                      _buildContactForm(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Danh sách hành khách (${_guestNameControllers.length})"),
                      _buildGuestListForm(),
                      const SizedBox(height: 20),
                      _buildSectionTitle("Ghi chú (Tùy chọn)"),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Yêu cầu đặc biệt (ăn chay, xe lăn...)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTourSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              // Sử dụng getter imageUrl từ TourModel
              image: widget.tour.imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(widget.tour.imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: widget.tour.imageUrl.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sử dụng getter name từ TourModel
                Text(widget.tour.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("${NumberFormat('#,###').format(widget.tour.price)} đ / khách", style: const TextStyle(color: Palette.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    // SỬA LỖI: Thay location bằng destination
                    Text(widget.tour.destination, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTripConfigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Chọn ngày
          InkWell(
            onTap: _pickDate,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Palette.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.calendar_month, color: Palette.primary),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ngày khởi hành", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.edit, size: 18, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 30),
          // Chọn số khách
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Palette.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.people, color: Palette.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Số lượng khách", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("$_guestCount người", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildQtyBtn(Icons.remove, () {
                    if (_guestCount > 1) {
                      setState(() => _guestCount--);
                      _updateGuestControllers();
                    }
                  }),
                  const SizedBox(width: 12),
                  _buildQtyBtn(Icons.add, () {
                    setState(() => _guestCount++);
                    _updateGuestControllers();
                  }),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: "Họ và tên người đặt",
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? "Vui lòng nhập họ tên" : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: "Số điện thoại",
            icon: Icons.phone_android,
            inputType: TextInputType.phone,
            validator: (v) => v!.length < 9 ? "Số điện thoại không hợp lệ" : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: "Email (Nhận vé điện tử)",
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            validator: (v) => !v!.contains("@") ? "Email không hợp lệ" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestListForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _guestNameControllers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Row(
            children: [
              Text("${index + 1}.", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _guestNameControllers[index],
                    decoration: InputDecoration(
                      hintText: index == 0 ? "Tên khách (Người đặt)" : "Tên hành khách ${index + 1}",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Tổng cộng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                    "${NumberFormat('#,###').format(_totalPrice)} đ",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Palette.primary)
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("THANH TOÁN NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}