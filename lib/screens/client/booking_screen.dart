import 'package:flutter/material.dart';
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import 'payment_qr_screen.dart'; // Sẽ tạo bước sau

class BookingScreen extends StatefulWidget {
  final TourModel tour;
  const BookingScreen({super.key, required this.tour});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _guestCount = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Mặc định là ngày mai
  final FirestoreService _service = FirestoreService();
  bool _isLoading = false;

  // Tính tổng tiền
  double get _totalPrice => widget.tour.price * _guestCount;

  // Chọn ngày
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Xử lý đặt vé
  void _processBooking() async {
    final userId = _service.currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    // 1. Tạo Model Booking
    BookingModel newBooking = BookingModel(
      id: '', // Firestore sẽ tự sinh ID sau
      userId: userId,
      tourId: widget.tour.id,
      tourName: widget.tour.name,
      totalPrice: _totalPrice,
      guestCount: _guestCount,
      bookingDate: _selectedDate,
      status: 'pending',
      paymentStatus: 'unpaid',
    );

    // 2. Gửi lên Firebase
    String? bookingId = await _service.placeBooking(newBooking);

    setState(() => _isLoading = false);

    if (bookingId != null) {
      // 3. Chuyển sang màn hình Thanh toán QR
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi đặt vé, vui lòng thử lại!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin đặt vé"), backgroundColor: Palette.primary, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin Tour tóm tắt
            Text(widget.tour.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 1. Chọn ngày
            const Text("Ngày khởi hành", style: TextStyle(color: Colors.grey)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.calendar_today, color: Palette.primary),
              onTap: _pickDate,
            ),
            const Divider(),

            // 2. Chọn số người
            const SizedBox(height: 10),
            const Text("Số lượng khách", style: TextStyle(color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$_guestCount người", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_guestCount > 1) setState(() => _guestCount--);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Palette.primary),
                      onPressed: () => setState(() => _guestCount++),
                    ),
                  ],
                )
              ],
            ),
            const Divider(),

            const Spacer(),

            // 3. Tổng tiền & Nút Đặt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng cộng:", style: TextStyle(fontSize: 18)),
                Text("${_totalPrice.toStringAsFixed(0)} đ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.accent)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processBooking,
                style: ElevatedButton.styleFrom(backgroundColor: Palette.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("TIẾP TỤC THANH TOÁN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}