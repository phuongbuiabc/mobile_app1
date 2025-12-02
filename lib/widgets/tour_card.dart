import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../models/tour_model.dart';
import '../../../config/palette.dart';
import '../../../providers/comparison_provider.dart';
import '../../screens/client/tour_detail_screen.dart'; // Import màn hình chi tiết

class TourCard extends StatelessWidget {
  final TourModel tour;

  const TourCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isComparing = comparisonProvider.isInComparison(tour);

    return GestureDetector(
      // BẤM VÀO THẺ ĐỂ XEM CHI TIẾT & ĐẶT VÉ
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. Ảnh nền (Full Card)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: tour.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              // 2. Lớp phủ đen mờ
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),

              // 3. Thông tin Tour
              Positioned(
                bottom: 20, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.name,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Palette.accent, size: 18),
                        const SizedBox(width: 5),
                        Text(tour.duration, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                        const Spacer(),
                        Text("${tour.price.toStringAsFixed(0)} đ", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. Nút SO SÁNH (Giữ nguyên)
              Positioned(
                top: 20, right: 20,
                child: GestureDetector(
                  onTap: () {
                    comparisonProvider.toggleComparison(tour);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        isComparing ? "Đã loại bỏ ${tour.name} khỏi danh sách so sánh." : "Đã thêm ${tour.name} vào danh sách so sánh.",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: isComparing ? Colors.redAccent : Colors.teal,
                      duration: const Duration(milliseconds: 1000),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isComparing ? Palette.accent : Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(isComparing ? Icons.check : Icons.compare_arrows, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(isComparing ? "ĐANG SO SÁNH" : "SO SÁNH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}