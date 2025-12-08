import 'dart:async'; // Import Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore để check trạng thái Like
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth để lấy userId
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
import '../profile/about_us_screen.dart';
import '../profile/account_screen.dart';
import '../profile/help_screen.dart';
import '../profile/settings_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen>
    with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  bool _isReelMode = true;
  int _currentIndex = 0;
  String _searchKeyword = "";

  late AnimationController _animController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _color1 = ColorTween(
      begin: const Color(0xFF006491),
      end: const Color(0xFF1CB5E0),
    ).animate(_animController);
    _color2 = ColorTween(
      begin: const Color(0xFF1CB5E0),
      end: const Color(0xFF000046),
    ).animate(_animController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TourProvider>(context, listen: false).fetchTours();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
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
    final List<Widget> _screens = [
      _buildHomeTab(),
      const FavoritesScreen(),
      const BookingHistoryScreen(),
      _buildProfileTab(),
    ];

    bool isDarkTheme = _currentIndex == 0 && _isReelMode;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.85),
              border: Border(
                top: BorderSide(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: isDarkTheme ? Colors.white : Palette.primary,
              unselectedItemColor: isDarkTheme ? Colors.white54 : Colors.grey,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: "Trang chủ",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: "Yêu thích",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number),
                  label: "Vé của tôi",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Cá nhân",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
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
                                  Icon(
                                    Icons.travel_explore,
                                    color: _isReelMode
                                        ? Colors.white
                                        : Palette.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Trivok",
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
                                onPressed: () =>
                                    setState(() => _isReelMode = !_isReelMode),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 45,
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
        // Sử dụng Widget riêng để quản lý state cho từng item (slide ảnh)
        return ReelItem(
          tour: tours[index],
          onLike: () {
            _userService.toggleFavorite(tours[index].id);
            // Thông báo sẽ được xử lý visual trong ReelItem
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

  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Trường hợp hiếm gặp vì đã có AuthGate, nhưng để an toàn
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Vui lòng đăng nhập để xem thông tin"),
            ElevatedButton(
              onPressed: () => AuthService().signOut(),
              child: const Text("Tới trang đăng nhập"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Palette.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Không thể tải dữ liệu người dùng."),
            );
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final displayName =
              userData['fullName'] ?? user.displayName ?? "Khách hàng";
          final avatarUrl = userData['avatar'] ?? user.photoURL;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Palette.primary.withOpacity(0.2),
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'K',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Palette.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "Xin chào, $displayName!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Thành viên hạng Vàng",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _buildProfileItem(
                  Icons.account_circle_outlined,
                  "Tài khoản",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                ),
                _buildProfileItem(
                  Icons.settings,
                  "Cài đặt",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _buildProfileItem(
                  Icons.help_outline,
                  "Trợ giúp & Hỗ trợ",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                ),
                _buildProfileItem(
                  Icons.info_outline,
                  "Về ứng dụng Trivok",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => AuthService().signOut(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Đăng xuất",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET REEL ITEM RIÊNG BIỆT ĐỂ QUẢN LÝ SLIDE ẢNH & HIỆU ỨNG TIM ---
class ReelItem extends StatefulWidget {
  final TourModel tour;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onDetail;

  const ReelItem({
    super.key,
    required this.tour,
    required this.onLike,
    required this.onShare,
    required this.onDetail,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem>
    with SingleTickerProviderStateMixin {
  late PageController _imagePageController;
  Timer? _timer;
  int _activePage = 0;

  // Animation cho Tim bay
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnimation;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();

    // Animation Controller cho tim bay
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimController, curve: Curves.elasticOut),
    );

    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Sau khi hiện tim xong, chờ xíu rồi ẩn đi
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _heartAnimController.reverse(); // Thu nhỏ lại
            setState(() {
              _showHeartAnimation = false;
            });
          }
        });
      }
    });

    if (widget.tour.images.length > 1) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_imagePageController.hasClients) {
        int nextPage = _activePage + 1;
        if (nextPage >= widget.tour.images.length) {
          nextPage = 0;
        }
        _imagePageController.animateToPage(
          nextPage,
          duration: const Duration(
            milliseconds: 800,
          ), // Thời gian lướt mượt hơn
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  // Hàm xử lý Double Tap
  void _handleDoubleTap() {
    // 1. Kích hoạt logic Like
    widget.onLike();

    // 2. Kích hoạt hiệu ứng Tim bay
    setState(() {
      _showHeartAnimation = true;
    });
    _heartAnimController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _imagePageController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  // Helper để tạo mũi tên kính mờ
  Widget _buildGlassArrow(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị Dots Indicator
  Widget _buildDotsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.tour.images.length, (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _activePage == index ? Colors.white : Colors.white54,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // BẮT SỰ KIỆN DOUBLE TAP Ở ĐÂY
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        children: [
          // 1. CAROUSEL ẢNH (PageView Ngang)
          Positioned.fill(
            child: PageView.builder(
              controller: _imagePageController,
              itemCount: widget.tour.images.isNotEmpty
                  ? widget.tour.images.length
                  : 1,
              onPageChanged: (page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemBuilder: (context, index) {
                String imgUrl = widget.tour.images.isNotEmpty
                    ? widget.tour.images[index]
                    : 'https://placehold.co/600x400/000000/FFFFFF?text=No+Image';

                return CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[900]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // 2. LỚP PHỦ ĐEN MỜ
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. HIỆU ỨNG TIM BAY (DOUBLE TAP HEART)
          if (_showHeartAnimation)
            Center(
              child: ScaleTransition(
                scale: _heartScaleAnimation,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100, // Tim to giữa màn hình
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),

          // 4. INDICATORs VÀ ARROWs
          if (widget.tour.images.length > 1)
            Positioned.fill(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Navigation Arrows (Trái/Phải)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassArrow(Icons.arrow_back_ios, () {
                          int prevPage = _activePage == 0
                              ? widget.tour.images.length - 1
                              : _activePage - 1;
                          _imagePageController.animateToPage(
                            prevPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }),
                        _buildGlassArrow(Icons.arrow_forward_ios, () {
                          int nextPage =
                              _activePage == widget.tour.images.length - 1
                              ? 0
                              : _activePage + 1;
                          _imagePageController.animateToPage(
                            nextPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }),
                      ],
                    ),
                  ),

                  // Dots Indicator (Tâm trên)
                  Positioned(top: 80, child: _buildDotsIndicator()),
                ],
              ),
            ),

          // 5. THÔNG TIN TOUR
          Positioned(
            bottom: 100,
            left: 20,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Trending 🔥",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tên Tour
                Text(
                  widget.tour.title,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      "${widget.tour.rate}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "(1.2k đánh giá)",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Giá tiền
                Text(
                  "${widget.tour.price.toStringAsFixed(0)} đ",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),
                // Nút Chi tiết
                ElevatedButton.icon(
                  onPressed: widget.onDetail,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text("Chi tiết"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. CỘT BÊN PHẢI (SIDE ACTIONS)
          Positioned(
            bottom: 100,
            right: 15,
            child: Column(
              children: [
                // NÚT THÍCH VỚI STREAM (Tự đổi màu đỏ)
                _buildFavoriteButton(),
                const SizedBox(height: 20),
                _buildSideAction(
                  Icons.share,
                  "Chia sẻ",
                  Colors.white,
                  widget.onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Nút Thích thông minh (Lắng nghe Stream để đổi màu)
  Widget _buildFavoriteButton() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Nếu chưa đăng nhập thì hiện tim trắng tĩnh
    if (userId == null) {
      return _buildSideAction(
        Icons.favorite,
        "Thích",
        Colors.white,
        widget.onLike,
      );
    }

    // Lắng nghe realtime từ Firebase để biết tour này có được like không
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isLiked = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favorites = List<dynamic>.from(data['favorites'] ?? []);
          isLiked = favorites.contains(widget.tour.id);
        }

        return _buildSideAction(
          Icons.favorite,
          "Thích",
          isLiked ? Colors.redAccent : Colors.white, // Đổi màu nếu đã thích
          widget.onLike,
        );
      },
    );
  }

  Widget _buildSideAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30), // Màu icon động
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
