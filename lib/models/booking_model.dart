import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String tourId;
  final String tourName;
  final double totalPrice;
  final int guestCount;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String paymentStatus; // 'unpaid', 'waiting', 'paid'
  final DateTime? createdAt; // Thêm trường này để lưu thời gian tạo

  BookingModel({
    required this.id,
    required this.userId,
    required this.tourId,
    required this.tourName,
    required this.totalPrice,
    required this.guestCount,
    required this.bookingDate,
    required this.status,
    required this.paymentStatus,
    this.createdAt, // Có thể null khi mới tạo object trên client
  });

  // Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tourId': tourId,
      'tourName': tourName,
      'totalPrice': totalPrice,
      'guestCount': guestCount,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status,
      'paymentStatus': paymentStatus,
      // Nếu đã có createdAt (khi update) thì giữ nguyên, nếu chưa (tạo mới) thì dùng serverTimestamp
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Factory method: Chuyển từ Firestore DocumentSnapshot sang Object
  factory BookingModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      tourId: data['tourId'] ?? '',
      tourName: data['tourName'] ?? 'Chuyến đi không tên',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      guestCount: data['guestCount'] ?? 1,
      // Xử lý Timestamp an toàn
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'unpaid',
      // Lấy createdAt nếu có
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }
}