import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/palette.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vé của tôi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text("Vui lòng đăng nhập"))
          : StreamBuilder<QuerySnapshot>(
        // Chỉ lấy vé của user hiện tại
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.airplane_ticket_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Bạn chưa đặt vé nào cả!"),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final DateTime date = (data['bookingDate'] as Timestamp).toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    // Phần màu trạng thái
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: status == 'confirmed' ? Colors.green : (status == 'pending' ? Colors.orange : Colors.red),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon vé
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Palette.background, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.confirmation_number, color: Palette.primary, size: 30),
                          ),
                          const SizedBox(width: 15),
                          // Thông tin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['tourName'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Ngày đi: ${date.day}/${date.month}/${date.year}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                Text("${data['totalPrice']} đ • ${data['guestCount']} khách", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          // Trạng thái text
                          Column(
                            children: [
                              if(status == 'confirmed') const Icon(Icons.check_circle, color: Colors.green),
                              if(status == 'pending') const Icon(Icons.access_time_filled, color: Colors.orange),
                              if(status == 'cancelled') const Icon(Icons.cancel, color: Colors.red),
                              const SizedBox(height: 4),
                              Text(
                                status == 'confirmed' ? "Thành công" : (status == 'pending' ? "Chờ duyệt" : "Đã hủy"),
                                style: TextStyle(fontSize: 12, color: status == 'confirmed' ? Colors.green : Colors.grey),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}