class TourModel {
  final String id;
  final String title;        // Thay cho 'name'
  final double rate;         // Thay cho 'rating' mặc định
  final String description;
  final double price;
  final List<String> images; // Thay cho 'imageUrl' đơn lẻ
  final String destination;  // Đích đến
  final List<String> itinerary; // Lịch trình (Danh sách các hoạt động/ngày)
  final bool isActive;       // Trạng thái hoạt động

  TourModel({
    required this.id,
    required this.title,
    required this.rate,
    required this.description,
    required this.price,
    required this.images,
    required this.destination,
    required this.itinerary,
    required this.isActive,
  });

  // --- GETTERS HỖ TRỢ UI CŨ (Để không phải sửa lại toàn bộ UI) ---
  // Lấy ảnh đầu tiên làm thumbnail, nếu không có thì dùng ảnh placeholder
  String get imageUrl => images.isNotEmpty ? images.first : 'https://placehold.co/600x400/png?text=No+Image';

  // Map 'title' sang 'name' cho UI cũ
  String get name => title;

  // Tự động tính thời gian dựa trên số lượng mục trong lịch trình
  String get duration => "${itinerary.length}N${itinerary.length - 1}Đ";

  // Factory chuyển đổi từ Firestore
  factory TourModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TourModel(
      id: id,
      title: data['title'] ?? 'Chưa cập nhật tên',
      rate: (data['rate'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      // Chuyển đổi mảng dynamic sang List<String>
      images: List<String>.from(data['images'] ?? []),
      destination: data['destination'] ?? 'Việt Nam',
      itinerary: List<String>.from(data['itinerary'] ?? []),
      isActive: data['is_active'] ?? true,
    );
  }

  // Chuyển đổi sang Map để lưu xuống Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rate': rate,
      'description': description,
      'price': price,
      'images': images,
      'destination': destination,
      'itinerary': itinerary,
      'is_active': isActive,
    };
  }
}