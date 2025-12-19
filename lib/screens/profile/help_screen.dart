import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/palette.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Dữ liệu cho các câu hỏi thường gặp (FAQ)
  static const _faqItems = [
    {
      'question': 'Làm thế nào để đặt một tour?',
      'answer':
          'Bạn có thể tìm kiếm tour mong muốn trên trang chủ, xem chi tiết và nhấn nút "Đặt ngay". Sau đó, hãy điền đầy đủ thông tin và tiến hành thanh toán theo hướng dẫn.',
    },
    {
      'question': 'Tôi có thể hủy vé đã đặt không?',
      'answer':
          'Chính sách hủy vé phụ thuộc vào từng tour cụ thể. Vui lòng xem chi tiết trong mục "Điều khoản & Điều kiện" của tour bạn đã đặt hoặc liên hệ với chúng tôi qua hotline 1900 1234 để được hỗ trợ.',
    },
    {
      'question': 'Ứng dụng chấp nhận những phương thức thanh toán nào?',
      'answer':
          'Hiện tại, chúng tôi chấp nhận thanh toán qua chuyển khoản ngân hàng bằng mã QR (VietQR). Các phương thức thanh toán khác như thẻ tín dụng và ví điện tử sẽ sớm được cập nhật trong các phiên bản sau.',
    },
    {
      'question': 'Làm sao để biết vé của tôi đã được xác nhận?',
      'answer':
          'Sau khi thanh toán thành công, vé của bạn sẽ ở trạng thái "Chờ xác nhận". Admin sẽ kiểm tra và duyệt vé trong thời gian sớm nhất (thường trong vòng 24 giờ). Bạn có thể theo dõi trạng thái vé trong mục "Vé của tôi".',
    },
    {
      'question': 'Làm thế nào để liên hệ với hướng dẫn viên?',
      'answer':
          'Thông tin liên hệ của hướng dẫn viên (nếu có) sẽ được cung cấp trong chi tiết vé sau khi vé của bạn đã được xác nhận và gần đến ngày khởi hành.',
    },
    {
      'question': 'Tôi có thể thay đổi thông tin người đi tour không?',
      'answer':
          'Để thay đổi thông tin, vui lòng liên hệ với bộ phận chăm sóc khách hàng của chúng tôi qua email support@trivok.com kèm theo mã đặt vé của bạn.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
        backgroundColor: Palette.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          _buildContactCard(context),
          const SizedBox(height: 30),
          _buildFaqSection(),
        ],
      ),
    );
  }

  // Widget cho phần thông tin liên hệ
  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liên hệ chúng tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nếu bạn có bất kỳ thắc mắc nào cần giải đáp ngay, đừng ngần ngại liên hệ với chúng tôi.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildContactRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Hotline 24/7',
              value: '1900 1234567',
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '19001234567'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép số điện thoại')),
                );
              },
            ),
            const Divider(height: 20),
            _buildContactRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email hỗ trợ',
              value: 'support@trivok.com',
              onTap: () {
                Clipboard.setData(
                  const ClipboardData(text: 'support@trivok.com'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép email')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho một dòng thông tin liên hệ
  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Palette.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Palette.textMain,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.copy_all_outlined, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget cho phần câu hỏi thường gặp
  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 10),
          child: Text(
            'Câu hỏi thường gặp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Palette.textMain,
            ),
          ),
        ),
        ..._faqItems.map((faq) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              iconColor: Palette.primary,
              collapsedIconColor: Colors.grey[600],
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Palette.textMain,
                ),
              ),
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Text(
                    faq['answer']!,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
