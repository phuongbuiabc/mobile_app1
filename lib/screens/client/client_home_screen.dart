import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/palette.dart';
import '../../providers/tour_provider.dart';
import 'booking_history_screen.dart';
import 'favorites_screen.dart';
import 'home_tab.dart'; // Import HomeTab
import 'profile_screen.dart'; // Import ProfileTab

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  bool _isReelMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TourProvider>(context, listen: false).fetchTours();
    });
  }

  // Hàm callback để cập nhật trạng thái UI từ HomeTab
  void _onHomeModeChanged(bool isReelMode) {
    if (_isReelMode != isReelMode) {
      setState(() {
        _isReelMode = isReelMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeTab(onModeChanged: _onHomeModeChanged), // Truyền callback vào HomeTab
      const FavoritesScreen(),
      const BookingHistoryScreen(),
      const ProfileTab(),
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
}