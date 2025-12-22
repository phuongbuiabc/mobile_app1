import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/palette.dart';
import '../../../services/user_service.dart';
import '../../../providers/tour_provider.dart';
import '../../../widgets/comparison_bar.dart';
import '../../../models/tour_model.dart';
import '../../../widgets/reel_item.dart'; // Import Widget đã tách
import 'tour_detail_screen.dart';

class HomeTab extends StatefulWidget {
  // Callback để thông báo cho ClientHomeScreen biết khi chế độ thay đổi (để đổi màu BottomBar)
  final Function(bool isReelMode) onModeChanged;

  const HomeTab({super.key, required this.onModeChanged});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  bool _isReelMode = true;
  String _searchKeyword = "";

  late AnimationController _animController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    // Báo trạng thái ban đầu cho parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onModeChanged(_isReelMode);
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Cập nhật màu theo đúng yêu cầu của bạn (Đỏ - Xanh đặc biệt)
    _color1 = ColorTween(
      begin: const Color(0xFF029DCD),
      end: const Color(0xFFA80404),
    ).animate(_animController);

    _color2 = ColorTween(
      begin: const Color(0xFF087B94),
      end: const Color(0xFFA90303),
    ).animate(_animController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isReelMode = !_isReelMode;
    });
    // Gọi callback khi switch mode
    widget.onModeChanged(_isReelMode);
  }

  List<TourModel> _filterTours(List<TourModel> tours) {
    if (_searchKeyword.isEmpty) return tours;
    return tours
        .where(
          (t) => t.title.toLowerCase().contains(_searchKeyword.toLowerCase()),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = _isReelMode ? Colors.black : Palette.background;
    Color textColor = _isReelMode ? Colors.white : Palette.textMain;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: bgColor,
          extendBodyBehindAppBar: _isReelMode,
          body: Stack(
            children: [
              if (_isReelMode)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_color1.value!, _color2.value!],
                    ),
                  ),
                ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      'assets/images/logo_a.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Đi khắp mọi miền",
                                    style: GoogleFonts.nunito(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  _isReelMode
                                      ? Icons.grid_view
                                      : Icons.view_stream,
                                  color: _isReelMode
                                      ? Colors.white
                                      : Palette.primary,
                                ),
                                onPressed: _toggleMode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isReelMode
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isReelMode
                                    ? Colors.white30
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: _isReelMode
                                  ? []
                                  : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: textColor),
                              onChanged: (value) =>
                                  setState(() => _searchKeyword = value),
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm địa điểm...",
                                hintStyle: TextStyle(
                                  color: _isReelMode
                                      ? Colors.white60
                                      : Colors.grey,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: _isReelMode
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                                suffixIcon: _searchKeyword.isNotEmpty
                                    ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: _isReelMode
                                        ? Colors.white70
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchKeyword = "");
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Consumer<TourProvider>(
                        builder: (context, tourProvider, child) {
                          if (tourProvider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: _isReelMode
                                    ? Colors.white
                                    : Palette.primary,
                              ),
                            );
                          }

                          final filteredTours = _filterTours(
                            tourProvider.tours,
                          );

                          if (filteredTours.isEmpty) {
                            return Center(
                              child: Text(
                                _searchKeyword.isNotEmpty
                                    ? "Không tìm thấy '$_searchKeyword'"
                                    : "Chưa có địa điểm nào!",
                                style: TextStyle(color: textColor),
                              ),
                            );
                          }

                          return _isReelMode
                              ? _buildReelView(filteredTours)
                              : _buildGridView(filteredTours);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: const ComparisonBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReelView(List<TourModel> tours) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: tours.length,
      itemBuilder: (context, index) {
        // Sử dụng Widget đã tách ReelItem
        return ReelItem(
          tour: tours[index],
          onLike: () {
            _userService.toggleFavorite(tours[index].id);
          },
          onShare: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã sao chép liên kết!")),
          ),
          onDetail: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TourDetailScreen(tour: tours[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<TourModel> tours) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: tour.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(
                            " ${tour.rate}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${tour.price.toStringAsFixed(0)} đ",
                        style: const TextStyle(
                          color: Palette.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
}