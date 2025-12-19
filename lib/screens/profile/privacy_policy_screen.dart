import 'package:flutter/material.dart';
import '../../config/palette.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(title: const Text('Chính sách bảo mật')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSection(
            '1. Mục đích thu thập thông tin',
            'Chúng tôi thu thập thông tin cá nhân của bạn (bao gồm họ tên, email, số điện thoại) nhằm mục đích xác nhận đặt vé, liên lạc để hỗ trợ, và gửi các thông tin về khuyến mãi, tour mới (nếu bạn đồng ý).',
          ),
          _buildSection(
            '2. Phạm vi sử dụng thông tin',
            'Thông tin cá nhân của bạn chỉ được sử dụng trong nội bộ ứng dụng Trivok để phục vụ các mục đích đã nêu. Chúng tôi cam kết không bán, trao đổi hoặc chia sẻ thông tin của bạn cho bất kỳ bên thứ ba nào khác vì mục đích thương mại.',
          ),
          _buildSection(
            '3. Chia sẻ thông tin',
            'Chúng tôi có thể chia sẻ thông tin cần thiết (như họ tên, số điện thoại) cho các đối tác tổ chức tour mà bạn đã đặt để đảm bảo chuyến đi của bạn được phục vụ tốt nhất. Các đối tác này cũng bị ràng buộc bởi các quy định bảo mật tương đương.',
          ),
          _buildSection(
            '4. Bảo mật dữ liệu',
            'Chúng tôi áp dụng các biện pháp kỹ thuật và an ninh để bảo vệ thông tin cá nhân của bạn khỏi bị truy cập, sử dụng hoặc tiết lộ trái phép. Dữ liệu được lưu trữ trên hệ thống máy chủ an toàn của Firebase.',
          ),
          _buildSection(
            '5. Quyền của người dùng',
            'Bạn có quyền truy cập, chỉnh sửa hoặc yêu cầu xóa thông tin cá nhân của mình khỏi hệ thống của chúng tôi. Vui lòng liên hệ qua email support@trivok.com để được hỗ trợ.',
          ),
          _buildSection(
            '6. Thay đổi chính sách',
            'Chính sách bảo mật này có thể được cập nhật theo thời gian. Mọi thay đổi sẽ được đăng tải trên ứng dụng và có hiệu lực ngay lập tức. Việc bạn tiếp tục sử dụng dịch vụ đồng nghĩa với việc chấp nhận các thay đổi đó.',
          ),
          const SizedBox(height: 20),
          Text(
            'Cập nhật lần cuối: 08/12/2025',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Palette.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Palette.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
