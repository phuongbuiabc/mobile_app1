import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../config/palette.dart';
import 'ticket_detail_screen.dart'; // IMPORT MÀN HÌNH CHI TIẾT

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Vé của tôi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: Text("Vui lòng đăng nhập để xem vé"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}", textAlign: TextAlign.center));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Bạn chưa có vé nào!"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // --- PARSE DỮ LIỆU ---
              final String id = doc.id;
              final String tourName = data['tourName'] ?? 'Chuyến đi không tên';
              final String status = data['status'] ?? 'pending';
              final double totalPrice = (data['totalPrice'] is int)
                  ? (data['totalPrice'] as int).toDouble()
                  : (data['totalPrice'] as double? ?? 0.0);
              final int guestCount = data['guestCount'] ?? 1;

              DateTime bookingDate = DateTime.now();
              if (data['bookingDate'] != null && data['bookingDate'] is Timestamp) {
                bookingDate = (data['bookingDate'] as Timestamp).toDate();
              }

              // Các trường chi tiết bổ sung
              final String contactName = data['contactName'] ?? '';
              final String contactPhone = data['contactPhone'] ?? '';
              final String contactEmail = data['contactEmail'] ?? '';
              final String note = data['note'] ?? '';
              final List<String> guestNames = List<String>.from(data['guestNames'] ?? []);

              // --- SỰ KIỆN CLICK (INKWELL) ---
              return InkWell(
                onTap: () {
                  // Chuyển sang màn hình chi tiết
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailScreen(
                        bookingId: id,
                        tourName: tourName,
                        status: status,
                        totalPrice: totalPrice,
                        guestCount: guestCount,
                        bookingDate: bookingDate,
                        contactName: contactName,
                        contactPhone: contactPhone,
                        contactEmail: contactEmail,
                        note: note,
                        guestNames: guestNames,
                      ),
                    ),
                  );
                },
                child: _buildTicketCard(
                  context: context,
                  id: id,
                  tourName: tourName,
                  status: status,
                  totalPrice: totalPrice,
                  guestCount: guestCount,
                  bookingDate: bookingDate,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTicketCard({
    required BuildContext context,
    required String id,
    required String tourName,
    required String status,
    required double totalPrice,
    required int guestCount,
    required DateTime bookingDate,
  }) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("MÃ: #${id.substring(0, id.length > 6 ? 6 : id.length).toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          _buildStatusBadge(statusText, statusColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(tourName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.primary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(DateFormat('dd/MM/yyyy').format(bookingDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text("${NumberFormat('#,###').format(totalPrice)} đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Palette.primary)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed': return "Thành công";
      case 'cancelled': return "Đã hủy";
      default: return "Chờ duyệt";
    }
  }
}