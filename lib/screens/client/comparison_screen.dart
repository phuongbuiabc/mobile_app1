import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/palette.dart';
import '../../../models/tour_model.dart';
import '../../../providers/comparison_provider.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final tours = comparisonProvider.comparisonList;

    // Đảm bảo có 2 Tour để so sánh
    if (tours.length < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn 2 Tour để so sánh!")));
      });
      return const Scaffold(body: Center(child: Text("Đang quay lại...")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("So Sánh Tour", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              comparisonProvider.clearComparison();
              Navigator.pop(context);
            },
            tooltip: 'Xóa danh sách so sánh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(tours),
            const Divider(height: 1),
            _buildComparisonRow("Tên Tour", tours, (t) => t.name, true),
            _buildComparisonRow("Giá Tour (VNĐ)", tours, (t) => "${t.price.toStringAsFixed(0)} đ", false),
            _buildComparisonRow("Thời gian", tours, (t) => t.duration, false),
            _buildComparisonRow("Mô tả", tours, (t) => t.description, true),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<TourModel> tours) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: Palette.background,
      child: Row(
        children: tours.map((tour) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: tour.imageUrl,
                      width: 150,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tour.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<TourModel> tours, String Function(TourModel) getValue, bool isLongText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Palette.background,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Palette.textMain)),
          ),
          const VerticalDivider(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                getValue(tours[0]),
                maxLines: isLongText ? 5 : 2,
                overflow: isLongText ? TextOverflow.ellipsis : TextOverflow.fade,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                getValue(tours[1]),
                maxLines: isLongText ? 5 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}