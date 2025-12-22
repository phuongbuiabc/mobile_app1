import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/palette.dart';
import '../../models/tour_model.dart';
import '../../services/user_service.dart';
import 'tour_detail_screen.dart';

// Cập nhật Enum thêm nameDesc (Z-A)
enum SortOption { newest, priceAsc, priceDesc, nameAsc, nameDesc }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final UserService _userService = UserService();
  SortOption _selectedSort = SortOption.newest; // Mặc định là mới nhất

  // Hàm xử lý sắp xếp danh sách
  List<TourModel> _processTours(List<TourModel> tours) {
    List<TourModel> sortedList = List.from(tours);
    switch (_selectedSort) {
      case SortOption.priceAsc:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAsc:
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        sortedList.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.newest:
      default:
      // Giữ nguyên thứ tự (mới nhất)
        break;
    }
    return sortedList;
  }

  // Hàm hiển thị Modal chọn kiểu sắp xếp
  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Sắp xếp theo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortOptionItem("Mặc định (Mới nhất)", SortOption.newest),
              _buildSortOptionItem("Giá: Thấp đến Cao", SortOption.priceAsc, icon: Icons.trending_up),
              _buildSortOptionItem("Giá: Cao đến Thấp", SortOption.priceDesc, icon: Icons.trending_down),
              _buildSortOptionItem("Tên: A - Z", SortOption.nameAsc, icon: Icons.sort_by_alpha),
              _buildSortOptionItem("Tên: Z - A", SortOption.nameDesc, icon: Icons.sort_by_alpha),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOptionItem(String title, SortOption value, {IconData? icon}) {
    final isSelected = _selectedSort == value;
    return ListTile(
      leading: Icon(
        icon ?? Icons.sort,
        color: isSelected ? Palette.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Palette.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Palette.primary)
          : null,
      onTap: () {
        setState(() => _selectedSort = value);
        Navigator.pop(context); // Đóng modal sau khi chọn
      },
    );
  }

  // Helper function để lấy tên hiển thị của kiểu sắp xếp hiện tại
  String _getSortLabel() {
    switch (_selectedSort) {
      case SortOption.priceAsc: return "Giá tăng dần";
      case SortOption.priceDesc: return "Giá giảm dần";
      case SortOption.nameAsc: return "Tên A-Z";
      case SortOption.nameDesc: return "Tên Z-A";
      default: return "Mặc định";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhẹ hiện đại
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'app_logo_fav',
              child: Image.asset(
                'assets/images/logo_a.png',
                width: 50,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.travel_explore, color: Palette.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Bộ sưu tập",
              style: GoogleFonts.nunito(
                  color: const Color(0xFF2D3436),
                  fontWeight: FontWeight.w800,
                  fontSize: 24
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Nút xóa tất cả (Optional)
          IconButton(
            icon: const Icon(Icons.playlist_remove, color: Colors.grey),
            onPressed: () {
              // Logic xóa tất cả nếu cần
            },
            tooltip: "Xóa tất cả",
          )
        ],
      ),
      body: StreamBuilder<List<TourModel>>(
        stream: _userService.getFavoriteToursStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawTours = snapshot.data ?? [];

          if (rawTours.isEmpty) {
            return _buildEmptyState();
          }

          // Áp dụng logic sắp xếp
          final tours = _processTours(rawTours);

          return Column(
            children: [
              // 1. THANH CÔNG CỤ SẮP XẾP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: const Color(0xFFF5F7FA), // Trùng màu nền
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "${tours.length} địa điểm",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            fontSize: 15
                        )
                    ),

                    // Nút Sắp xếp chuyên nghiệp
                    InkWell(
                      onTap: () => _showSortModal(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort_rounded, size: 18, color: Palette.primary),
                            const SizedBox(width: 6),
                            Text(
                              _getSortLabel(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Palette.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. DANH SÁCH TOUR
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: tours.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return _buildFavoriteCard(context, tour);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget: Thẻ Tour Yêu thích (Card)
  Widget _buildFavoriteCard(BuildContext context, TourModel tour) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh Thumbnail
            Hero(
              tag: 'fav_img_${tour.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: tour.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),

            // Thông tin chi tiết
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tên Tour
                    Text(
                      tour.title, // Hoặc tour.name tùy getter trong model
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Rating & Duration
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        Text(" ${tour.rate}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                        Text(" ${tour.duration}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Giá tiền
                    Text(
                      "${NumberFormat('#,###').format(tour.price)} đ",
                      style: const TextStyle(color: Palette.primary, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            // Nút Bỏ thích
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () {
                  _userService.toggleFavorite(tour.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã xóa '${tour.title}' khỏi danh sách"),
                      behavior: SnackBarBehavior.floating,
                      width: 280, // SnackBar nhỏ gọn
                      backgroundColor: Colors.grey[800],
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Màn hình trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded, size: 50, color: Colors.redAccent),
          ),
          const SizedBox(height: 20),
          Text(
            "Chưa có chuyến đi nào!",
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thả tim các địa điểm bạn yêu thích\nđể lưu vào đây nhé.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }
}