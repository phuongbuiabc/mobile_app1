import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Đảm bảo đã thêm: flutter pub add cached_network_image
import 'package:intl/intl.dart'; // Đảm bảo đã thêm: flutter pub add intl
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import 'booking_screen.dart';

class TourDetailScreen extends StatefulWidget {
  final TourModel tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false; // Giả lập trạng thái yêu thích

  // Tính toán thời gian dựa trên lịch trình
  String get _duration => "${widget.tour.itinerary.length} Ngày ${widget.tour.itinerary.length - 1} Đêm";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR & GALLERY
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.black
                    ),
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Logic chia sẻ
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: widget.tour.images.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.tour.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      );
                    },
                  ),
                  // Gradient Overlay để text dễ đọc hơn nếu cần
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                        ),
                      ),
                    ),
                  ),
                  // Chỉ số trang ảnh (Indicator)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1}/${widget.tour.images.length}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. NỘI DUNG CHI TIẾT
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Bo tròn phần tiếp giáp
              ),
              transform: Matrix4.translationValues(0, -20, 0), // Đẩy lên đè nhẹ lên ảnh
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100), // Bottom padding lớn để tránh nút đặt vé
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Tiêu đề & Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.tour.title,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.tour.rate.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "(120 đánh giá)", // Giả lập
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            )
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Palette.primary),
                        const SizedBox(width: 4),
                        Text(
                            widget.tour.destination,
                            style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Stats (Thời gian, Phương tiện, Trạng thái)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickStat(Icons.access_time_filled, "Thời gian", _duration, Colors.blue),
                        _buildQuickStat(Icons.directions_bus, "Di chuyển", "Xe du lịch", Colors.purple), // Giả lập
                        _buildQuickStat(
                            widget.tour.isActive ? Icons.check_circle : Icons.cancel,
                            "Trạng thái",
                            widget.tour.isActive ? "Sẵn sàng" : "Tạm đóng",
                            widget.tour.isActive ? Colors.green : Colors.red
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Mô tả
                    const Text("Giới thiệu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      widget.tour.description,
                      style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 30),

                    // Lịch trình (Timeline)
                    const Text("Lịch trình chi tiết", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.tour.itinerary.length,
                      itemBuilder: (context, index) {
                        bool isLast = index == widget.tour.itinerary.length - 1;
                        return _buildTimelineItem(index + 1, widget.tour.itinerary[index], isLast);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // THANH ĐẶT VÉ (Bottom Bar)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Giá vé trọn gói", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      "${NumberFormat('#,###').format(widget.tour.price)} đ",
                      style: const TextStyle(color: Palette.primary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: widget.tour.isActive
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(tour: widget.tour)))
                      : null, // Disable nếu tour đóng
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Palette.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    widget.tour.isActive ? "ĐẶT NGAY" : "TẠM ĐÓNG",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thống kê nhanh (Icon + Label + Value)
  Widget _buildQuickStat(IconData icon, String label, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget hiển thị timeline lịch trình
  Widget _buildTimelineItem(int day, String content, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột bên trái: Dấu tròn và đường nối
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Palette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Palette.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Center(
                    child: Text(
                        "$day",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Cột bên phải: Nội dung
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Ngày $day",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Text(
                      content,
                      style: const TextStyle(height: 1.5, color: Colors.black87, fontSize: 14),
                    ),
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