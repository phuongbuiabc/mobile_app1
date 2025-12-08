import 'package:flutter/material.dart';
import '../../../config/palette.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về ứng dụng'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ví dụ: Thêm logo ứng dụng
              // Image.asset('assets/images/app_logo.png', height: 120),
              const SizedBox(height: 20),
              const Text(
                'Booking App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Palette.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Phiên bản 1.0.0',
                style: TextStyle(fontSize: 16, color: Palette.textSub),
              ),
              const SizedBox(height: 30),
              const Text(
                'Đây là ứng dụng đặt tour du lịch, một sản phẩm đồ án được phát triển với Flutter và Firebase. Ứng dụng cho phép người dùng khám phá, so sánh và đặt các tour du lịch một cách dễ dàng và tiện lợi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Palette.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
