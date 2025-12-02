import 'package:flutter/material.dart';
import '../../config/palette.dart';

class PaymentQRScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String content;

  // Thông tin tài khoản của BẠN (Sinh viên) - Thay số tài khoản thật vào đây
  final String bankId = "MB"; // Ngân hàng MBBank (hoặc VCB, TCB, ACB...)
  final String accountNo = "0000123456789";
  final String accountName = "NGUYEN VAN A";

  const PaymentQRScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo link ảnh VietQR (API Công khai)
    // Cấu trúc: https://img.vietqr.io/image/<BANK>-<ACC>-<TEMPLATE>.png?amount=<AMT>&addInfo=<MSG>
    final String qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-compact.png?amount=${amount.toInt()}&addInfo=${Uri.encodeComponent(content)}&accountName=${Uri.encodeComponent(accountName)}";

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán"), backgroundColor: Palette.primary, foregroundColor: Colors.white),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 50, color: Palette.primary),
              const SizedBox(height: 10),
              const Text("Quét mã để thanh toán", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Đơn hàng sẽ được duyệt tự động sau khi chuyển khoản.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              // Ảnh QR Code
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loading) {
                      if (loading == null) return child;
                      return const SizedBox(width: 300, height: 300, child: Center(child: CircularProgressIndicator()));
                    },
                    errorBuilder: (ctx, err, stack) => const SizedBox(width: 300, height: 300, child: Center(child: Text("Lỗi tạo mã QR"))),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text("Số tiền: ${amount.toStringAsFixed(0)} đ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.accent)),
              const SizedBox(height: 10),
              SelectableText("Nội dung: $content", style: const TextStyle(fontSize: 16)), // Cho phép copy

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Trong thực tế, ở đây sẽ có Webhook lắng nghe biến động số dư
                    // Ở đồ án, ta giả lập xác nhận và quay về trang chủ
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xác nhận! Vui lòng chờ Admin duyệt vé.")));
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("TÔI ĐÃ CHUYỂN KHOẢN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}