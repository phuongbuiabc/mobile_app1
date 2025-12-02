class TourModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description; // Dùng cho tính năng So sánh
  final String duration;    // Dùng cho tính năng So sánh

  TourModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.duration,
  });

  // Factory constructor để chuyển đổi dữ liệu từ Firestore (JSON) sang Object
  factory TourModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TourModel(
      id: id,
      name: data['name'] ?? 'Chưa cập nhật tên',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['image'] ?? 'https://placehold.co/600x400/006491/FFFFFF?text=Tour', // Placeholder
      description: data['description'] ?? 'Không có mô tả chi tiết.',
      duration: data['duration'] ?? 'Chưa rõ',
    );
  }
}