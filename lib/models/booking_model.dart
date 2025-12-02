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
  });

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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}