import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import 'booking_screen.dart';

class TourDetailScreen extends StatelessWidget {
  final TourModel tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar với Ảnh Gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: tour.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: tour.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                  );
                },
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
          ),

          // 2. Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(tour.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          const Icon(Icons.star, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(tour.rate.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    Text(" ${tour.destination}", style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    Text(tour.isActive ? "Đang mở" : "Tạm đóng", style: TextStyle(color: tour.isActive ? Colors.green : Colors.red)),
                  ]),

                  const SizedBox(height: 20),
                  const Text("Mô tả", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(tour.description, style: const TextStyle(color: Colors.black87, height: 1.5)),

                  const SizedBox(height: 20),
                  const Text("Lịch trình chi tiết", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Danh sách Lịch trình (Timeline)
                  ...tour.itinerary.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 30, height: 30,
                                decoration: const BoxDecoration(color: Palette.primary, shape: BoxShape.circle),
                                child: Center(child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              ),
                              if (entry.key != tour.itinerary.length - 1)
                                Container(width: 2, height: 40, color: Colors.grey[300]),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                              child: Text(entry.value, style: const TextStyle(height: 1.4)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 80), // Khoảng trống cho nút đặt vé
                ],
              ),
            ),
          )
        ],
      ),

      // Thanh Đặt vé cố định ở dưới
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tổng giá", style: TextStyle(color: Colors.grey)),
                Text("${tour.price.toStringAsFixed(0)} đ", style: const TextStyle(color: Palette.primary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(tour: tour))),
              style: ElevatedButton.styleFrom(backgroundColor: Palette.accent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("ĐẶT NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}