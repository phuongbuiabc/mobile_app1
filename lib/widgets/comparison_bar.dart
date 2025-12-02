import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/palette.dart';
import '../../../providers/comparison_provider.dart';
import '../../screens/client/comparison_screen.dart';

class ComparisonBar extends StatelessWidget {
  const ComparisonBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComparisonProvider>(
      builder: (context, provider, child) {
        if (provider.comparisonList.isEmpty) {
          return const SizedBox.shrink(); // Ẩn nếu không có Tour nào
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Palette.primary,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Số lượng Tour đang so sánh
              Text(
                "${provider.comparisonList.length}/2 Tour đã chọn",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),

              // Nút Xem So sánh hoặc Xóa
              if (provider.comparisonList.length == 2)
              // Nút Xem So sánh
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                    );
                  },
                  icon: const Icon(Icons.view_carousel, size: 18, color: Palette.primary),
                  label: const Text("XEM SO SÁNH", style: TextStyle(color: Palette.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
              // Nút Xóa (Hoặc thông báo)
                TextButton.icon(
                  onPressed: provider.clearComparison,
                  icon: const Icon(Icons.clear_all, color: Colors.white70, size: 18),
                  label: const Text("Xóa", style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        );
      },
    );
  }
}