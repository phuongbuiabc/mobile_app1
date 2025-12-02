import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import 'booking_screen.dart'; // Sẽ tạo ở bước sau

class TourDetailScreen extends StatelessWidget {
  final TourModel tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Ảnh nền Full
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: tour.imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Nút Back
          Positioned(
            top: 40, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 2. Thông tin chi tiết (Kéo từ dưới lên)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Palette.accent, size: 20),
                      const Text(" Việt Nam", style: TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Text(" 5.0 (Review)", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Mô tả", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        tour.description.isNotEmpty ? tour.description : "Một hành trình tuyệt vời đang chờ đón bạn...",
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                      ),
                    ),
                  ),

                  // 3. Thanh Booking
                  const Divider(),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Giá vé", style: TextStyle(color: Colors.grey)),
                          Text(
                            "${tour.price.toStringAsFixed(0)} đ",
                            style: const TextStyle(color: Palette.primary, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Chuyển sang màn hình Đặt vé
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(tour: tour)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Đặt Ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}