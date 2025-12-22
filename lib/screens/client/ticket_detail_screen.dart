import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm import Firestore
import '../../config/palette.dart';

class TicketDetailScreen extends StatefulWidget {
  final String bookingId;
  final String tourName;
  final String status;
  final double totalPrice;
  final int guestCount;
  final DateTime bookingDate;
  // Các trường bổ sung
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String note;
  final List<String> guestNames;

  const TicketDetailScreen({
    super.key,
    required this.bookingId,
    required this.tourName,
    required this.status,
    required this.totalPrice,
    required this.guestCount,
    required this.bookingDate,
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.note = '',
    this.guestNames = const [],
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isCancelling = false;

  // HÀM XỬ LÝ HỦY VÉ
  Future<void> _handleCancelBooking() async {
    // 1. Hiện hộp thoại xác nhận
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận hủy vé", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Bạn có chắc chắn muốn hủy vé này không?\nHành động này không thể hoàn tác."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Xác nhận Hủy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      // 2. Gọi API cập nhật trạng thái lên Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': 'cancelled',
        // Có thể thêm lý do hủy hoặc thời gian hủy nếu cần
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // 3. Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã hủy vé thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        // Quay lại màn hình trước (Danh sách vé) để thấy trạng thái mới
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi hủy vé: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);
    final statusText = _getStatusText(widget.status);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Chi tiết vé", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PHẦN VÉ CHÍNH ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // Header trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getStatusIcon(widget.status), color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(statusText.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên Tour
                        Text(widget.tourName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3), textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Center(child: Text("Mã vé: #${widget.bookingId.substring(0, widget.bookingId.length > 8 ? 8 : widget.bookingId.length).toUpperCase()}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),

                        const Divider(height: 40, thickness: 1),

                        // Thông tin ngày giờ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem("Ngày khởi hành", DateFormat('dd/MM/yyyy').format(widget.bookingDate)),
                            _buildInfoItem("Thời gian", "08:00 AM"), // Giả định giờ
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem("Số lượng khách", "${widget.guestCount} người"),
                            _buildInfoItem("Tổng thanh toán", "${NumberFormat('#,###').format(widget.totalPrice)} đ", isHighlight: true),
                          ],
                        ),

                        const SizedBox(height: 30),
                        const Text("Danh sách hành khách", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                          child: widget.guestNames.isEmpty
                              ? const Text("Chưa cập nhật danh sách khách", style: TextStyle(color: Colors.grey))
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.guestNames.map((name) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- PHẦN THÔNG TIN LIÊN HỆ ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin liên hệ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildContactRow(Icons.person_outline, "Người đặt", widget.contactName),
                  _buildContactRow(Icons.phone_outlined, "Số điện thoại", widget.contactPhone),
                  _buildContactRow(Icons.email_outlined, "Email", widget.contactEmail),
                  if (widget.note.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildContactRow(Icons.note_alt_outlined, "Ghi chú", widget.note),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Nút Hủy (Chỉ hiện khi trạng thái là pending)
            if (widget.status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _handleCancelBooking, // Gắn hàm xử lý tại đây
                  icon: _isCancelling
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(_isCancelling ? "Đang xử lý..." : "Yêu cầu hủy vé", style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isHighlight ? Palette.primary : Colors.black87)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.access_time_filled;
    }
  }
}