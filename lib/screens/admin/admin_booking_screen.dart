import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/palette.dart';

class AdminBookingScreen extends StatelessWidget {
  const AdminBookingScreen({super.key});

  // Hàm cập nhật trạng thái đơn hàng
  Future<void> _updateStatus(String bookingId, String newStatus, String paymentStatus) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': newStatus,
      'paymentStatus': paymentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Đơn đặt vé", style: TextStyle(color: Colors.white)),
        backgroundColor: Palette.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lắng nghe dữ liệu realtime từ collection 'bookings'
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn đặt vé nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bookingId = docs[index].id;
              final status = data['status'] ?? 'pending';
              // Cẩn thận: Nếu bookingDate không tồn tại, .toDate() sẽ gây lỗi.
              final DateTime date = (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                // LỖI ĐÃ SỬA: Chỉ giữ lại một tham số 'shape' duy nhất.
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      // SỬ DỤNG switch expression để tăng khả năng đọc
                        color: switch (status) {
                          'confirmed' => Colors.green,
                          'cancelled' => Colors.red,
                          _ => Colors.orange,
                        },
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Mã: ...${bookingId.substring(bookingId.length - 5)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(data['tourName'] ?? 'Tên Tour', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.primary)),
                      const SizedBox(height: 5),
                      Text("Khách hàng ID: ${data['userId']}"), // Có thể nâng cấp để hiển thị Tên user
                      // Sử dụng IntL để format ngày tháng
                      Text("Ngày đi: ${DateFormat('dd/MM/yyyy').format(date)}"),
                      Text("Số khách: ${data['guestCount']} - Tổng: ${data['totalPrice']} đ", style: const TextStyle(fontWeight: FontWeight.bold)),

                      const Divider(),

                      // Nút hành động (Chỉ hiện khi đơn đang chờ)
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _updateStatus(bookingId, 'cancelled', 'unpaid'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text("Từ chối"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _updateStatus(bookingId, 'confirmed', 'paid'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text("ĐÃ NHẬN TIỀN (DUYỆT)", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      else
                        Text(
                          status == 'confirmed' ? "Đã hoàn tất thanh toán" : "Đơn đã bị hủy",
                          style: TextStyle(color: status == 'confirmed' ? Colors.green : Colors.red, fontStyle: FontStyle.italic),
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        text = "Thành công";
        break;
      case 'cancelled':
        color = Colors.red;
        text = "Đã hủy";
        break;
      default:
        color = Colors.orange;
        text = "Chờ duyệt";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // LỖI ĐÃ SỬA: Thay thế .withOpacity(0.1) bằng .withValues(alpha: 26)
      decoration: BoxDecoration(color: color.withValues(alpha: 26), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}