import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart'; // Thư viện mới đã fix lỗi

class PanoramaViewScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const PanoramaViewScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Để ảnh tràn lên thanh trạng thái
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Trong suốt
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PanoramaViewer(
          zoom: 1.0,
          animSpeed: 0.5, // Tự động xoay nhẹ
          child: Image.network(imageUrl), // Load ảnh 360 từ mạng
          // Lưu ý: Ảnh 360 phải là dạng Equirectangular (tỷ lệ 2:1)
        ),
      ),
    );
  }
}