import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/palette.dart';
import '../models/tour_model.dart';

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