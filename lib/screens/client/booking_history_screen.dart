import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../config/palette.dart';
import 'ticket_detail_screen.dart';

// Enum for sorting options
enum BookingSortOption { newest, oldest, priceAsc, priceDesc }

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  BookingSortOption _selectedSort = BookingSortOption.newest; // Default sort

  // Function to process and sort the list of documents
  List<DocumentSnapshot> _processBookings(List<DocumentSnapshot> docs) {
    List<DocumentSnapshot> sortedList = List.from(docs);

    sortedList.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      switch (_selectedSort) {
        case BookingSortOption.priceAsc:
          final priceA = (dataA['totalPrice'] is int)
              ? (dataA['totalPrice'] as int).toDouble()
              : (dataA['totalPrice'] as double? ?? 0.0);
          final priceB = (dataB['totalPrice'] is int)
              ? (dataB['totalPrice'] as int).toDouble()
              : (dataB['totalPrice'] as double? ?? 0.0);
          return priceA.compareTo(priceB);

        case BookingSortOption.priceDesc:
          final priceA = (dataA['totalPrice'] is int)
              ? (dataA['totalPrice'] as int).toDouble()
              : (dataA['totalPrice'] as double? ?? 0.0);
          final priceB = (dataB['totalPrice'] is int)
              ? (dataB['totalPrice'] as int).toDouble()
              : (dataB['totalPrice'] as double? ?? 0.0);
          return priceB.compareTo(priceA);

        case BookingSortOption.oldest:
          final dateA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final dateB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return dateA.compareTo(dateB);

        case BookingSortOption.newest:
        default:
          final dateA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final dateB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return dateB.compareTo(dateA);
      }
    });

    return sortedList;
  }

  // Modal to select sort option
  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Sắp xếp theo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortOptionItem("Mới nhất", BookingSortOption.newest),
              _buildSortOptionItem("Cũ nhất", BookingSortOption.oldest),
              _buildSortOptionItem("Giá: Thấp đến Cao", BookingSortOption.priceAsc, icon: Icons.trending_up),
              _buildSortOptionItem("Giá: Cao đến Thấp", BookingSortOption.priceDesc, icon: Icons.trending_down),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOptionItem(String title, BookingSortOption value, {IconData? icon}) {
    final isSelected = _selectedSort == value;
    return ListTile(
      leading: Icon(
        icon ?? Icons.sort,
        color: isSelected ? Palette.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Palette.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Palette.primary)
          : null,
      onTap: () {
        setState(() => _selectedSort = value);
        Navigator.pop(context);
      },
    );
  }

  String _getSortLabel() {
    switch (_selectedSort) {
      case BookingSortOption.priceAsc: return "Giá tăng dần";
      case BookingSortOption.priceDesc: return "Giá giảm dần";
      case BookingSortOption.oldest: return "Cũ nhất";
      default: return "Mới nhất";
    }
  }

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
            .snapshots(), // Remove orderBy here to handle client-side sorting or keep default
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}", textAlign: TextAlign.center));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawDocs = snapshot.data?.docs ?? [];

          if (rawDocs.isEmpty) {
            return const Center(child: Text("Bạn chưa có vé nào!"));
          }

          // Apply sorting
          final docs = _processBookings(rawDocs);

          return Column(
            children: [
              // --- SORT HEADER ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.grey.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${docs.length} vé đã đặt",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 15),
                    ),
                    InkWell(
                      onTap: () => _showSortModal(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort_rounded, size: 18, color: Palette.primary),
                            const SizedBox(width: 6),
                            Text(
                              _getSortLabel(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Palette.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- LIST ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // --- PARSE DATA ---
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

                    // Extra details
                    final String contactName = data['contactName'] ?? '';
                    final String contactPhone = data['contactPhone'] ?? '';
                    final String contactEmail = data['contactEmail'] ?? '';
                    final String note = data['note'] ?? '';
                    final List<String> guestNames = List<String>.from(data['guestNames'] ?? []);

                    // --- ITEM CLICK ---
                    return InkWell(
                      onTap: () {
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
                ),
              ),
            ],
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