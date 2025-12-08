import 'package:flutter/material.dart';
import '../../config/palette.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(title: const Text('Điều khoản dịch vụ')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSection(
            '1. Chấp nhận Điều khoản',
            'Bằng việc truy cập và sử dụng ứng dụng đặt tour Trivok, bạn đồng ý tuân thủ và bị ràng buộc bởi các điều khoản và điều kiện được nêu dưới đây. Nếu bạn không đồng ý, vui lòng không sử dụng ứng dụng.',
          ),
          _buildSection(
            '2. Quy trình Đặt vé và Thanh toán',
            'Người dùng có trách nhiệm cung cấp thông tin cá nhân chính xác và đầy đủ khi thực hiện đặt vé. Việc thanh toán phải được hoàn tất theo các phương thức được chấp nhận trên ứng dụng để xác nhận đặt chỗ. Chúng tôi không chịu trách nhiệm cho bất kỳ sai sót hoặc chậm trễ nào phát sinh do người dùng cung cấp thông tin không chính xác.',
          ),
          _buildSection(
            '3. Chính sách Hủy vé và Hoàn tiền',
            'Chính sách hủy vé và hoàn tiền có thể khác nhau tùy thuộc vào từng nhà cung cấp tour và được ghi rõ trong chi tiết của mỗi tour. Người dùng cần đọc kỹ các điều kiện này trước khi hoàn tất đặt vé. Phí hủy tour (nếu có) sẽ được áp dụng theo chính sách đã nêu.',
          ),
          _buildSection(
            '4. Trách nhiệm của Người dùng',
            'Bạn đồng ý không sử dụng ứng dụng cho các mục đích bất hợp pháp, lừa đảo hoặc gây hại cho người khác. Bạn có trách nhiệm bảo mật thông tin tài khoản và mật khẩu của mình. Mọi hoạt động diễn ra từ tài khoản của bạn sẽ được coi là do bạn thực hiện.',
          ),
          _buildSection(
            '5. Giới hạn Trách nhiệm',
            'Trivok hoạt động như một nền tảng trung gian, kết nối người dùng với các đơn vị tổ chức tour du lịch. Chúng tôi không chịu trách nhiệm trực tiếp cho bất kỳ sự cố, tai nạn, mất mát tài sản, hoặc tổn thất nào xảy ra trong quá trình diễn ra tour. Mọi khiếu nại liên quan đến chất lượng dịch vụ tour cần được giải quyết trực tiếp với nhà cung cấp.',
          ),
          _buildSection(
            '6. Thay đổi Điều khoản',
            'Chúng tôi có quyền sửa đổi hoặc cập nhật các điều khoản dịch vụ này vào bất kỳ lúc nào mà không cần thông báo trước. Phiên bản mới nhất sẽ luôn có sẵn trên ứng dụng. Việc bạn tiếp tục sử dụng ứng dụng sau khi có thay đổi đồng nghĩa với việc bạn chấp nhận các điều khoản mới.',
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
