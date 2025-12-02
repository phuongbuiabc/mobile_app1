import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/palette.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../providers/tour_provider.dart';
import '../../widgets/tour_card.dart';
import '../../widgets/comparison_bar.dart';
import '../../models/tour_model.dart';
import 'booking_history_screen.dart';
import 'favorites_screen.dart';
import 'tour_detail_screen.dart';
import 'booking_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final UserService _userService = UserService();
  final PageController _pageController = PageController();

  // Trạng thái chuyển đổi giao diện: true = Reels, false = Grid
  bool _isReelMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TourProvider>(context, listen: false).fetchTours();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu ở chế độ Grid thì nền trắng, Reels thì nền đen
    Color bgColor = _isReelMode ? Colors.black : Palette.background;
    Color iconColor = _isReelMode ? Colors.white : Palette.primary;
    Color textColor = _isReelMode ? Colors.white : Palette.textMain;

    return Scaffold(
      backgroundColor: bgColor,
      // AppBar chỉ trong suốt khi ở chế độ Reels
      extendBodyBehindAppBar: _isReelMode,

      appBar: AppBar(
        backgroundColor: _isReelMode ? Colors.transparent : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        title: Row(
          children: [
            Icon(Icons.travel_explore, color: _isReelMode ? Colors.white : Palette.primary, size: 28),
            const SizedBox(width: 8),
            Text(
                "Trivok",
                style: GoogleFonts.nunito(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                )
            ),
          ],
        ),
        actions: [
          // NÚT CHUYỂN ĐỔI CHẾ ĐỘ XEM (QUAN TRỌNG)
          IconButton(
            icon: Icon(_isReelMode ? Icons.grid_view : Icons.view_stream, color: iconColor),
            tooltip: _isReelMode ? "Xem dạng lưới" : "Xem dạng Reels",
            onPressed: () {
              setState(() {
                _isReelMode = !_isReelMode;
              });
            },
          ),

          _buildCircleAction(Icons.favorite, iconColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
          const SizedBox(width: 8),
          _buildCircleAction(Icons.confirmation_number, iconColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()))),
          const SizedBox(width: 8),
        ],
      ),

      body: Consumer<TourProvider>(
        builder: (context, tourProvider, child) {
          if (tourProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: iconColor));
          }

          if (tourProvider.tours.isEmpty) {
            return Center(child: Text("Chưa có địa điểm nào!", style: TextStyle(color: textColor)));
          }

          // LOGIC CHUYỂN ĐỔI GIAO DIỆN
          return _isReelMode
              ? _buildReelView(tourProvider.tours) // Giao diện TikTok
              : _buildGridView(tourProvider.tours); // Giao diện Lưới truyền thống
        },
      ),

      bottomNavigationBar: const ComparisonBar(),
    );
  }

  // 1. GIAO DIỆN REELS (FULL MÀN HÌNH)
  Widget _buildReelView(List<TourModel> tours) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: tours.length,
      itemBuilder: (context, index) {
        return _buildReelItem(context, tours[index]);
      },
    );
  }

  // 2. GIAO DIỆN GRID (LƯỚI DỄ TÌM KIẾM)
  Widget _buildGridView(List<TourModel> tours) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80), // Padding đáy để tránh thanh Comparison
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cột
        childAspectRatio: 0.7, // Tỷ lệ khung hình chữ nhật đứng
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: tour.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                // Thông tin
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tour.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("${tour.price.toStringAsFixed(0)} đ", style: const TextStyle(color: Palette.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [const Icon(Icons.star, size: 12, color: Colors.amber), const Text(" 5.0", style: TextStyle(fontSize: 11))]),
                          InkWell(
                            onTap: () {
                              _userService.toggleFavorite(tour.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật yêu thích!"), duration: Duration(milliseconds: 500)));
                            },
                            child: const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ITEM CỦA REEL VIEW ---
  Widget _buildReelItem(BuildContext context, TourModel tour) {
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: tour.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[900], child: const Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => Container(color: Colors.grey[900], child: const Icon(Icons.broken_image, color: Colors.white)),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.0, 0.2, 0.6, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80, left: 20, right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Palette.accent, borderRadius: BorderRadius.circular(20)),
                child: const Text("Trending 🔥", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(tour.name, style: GoogleFonts.nunito(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
              const SizedBox(height: 10),
              Text("${tour.price.toStringAsFixed(0)} đ", style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                tour.description.isNotEmpty ? tour.description : "Khám phá vẻ đẹp tuyệt vời...",
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour))),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text("Chi tiết"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 80, right: 15,
          child: Column(
            children: [
              _buildSideAction(Icons.favorite, "Thích", () {
                _userService.toggleFavorite(tour.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thêm vào Yêu thích! ❤️"), duration: Duration(milliseconds: 500)));
              }),
              const SizedBox(height: 20),
              _buildSideAction(Icons.airplane_ticket, "Đặt vé", () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(tour: tour)))),
              const SizedBox(height: 20),
              _buildSideAction(Icons.share, "Chia sẻ", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép liên kết!")))),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
                child: const CircleAvatar(radius: 22, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3")),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _isReelMode ? Colors.black26 : Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSideAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}