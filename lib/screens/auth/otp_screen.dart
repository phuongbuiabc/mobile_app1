
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import '../../config/palette.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final EmailOTP myAuth; // Object OTP đã được cấu hình từ màn trước

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.myAuth,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  void _verifyOtp() async {
    setState(() => isLoading = true);

    // 1. Kiểm tra mã OTP
    bool valid = await widget.myAuth.verifyOTP(otp: _otpController.text);

    if (valid) {
      // 2. Nếu OTP đúng -> Gọi Firebase tạo tài khoản thật
      String? error = await _authService.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
      );

      if (error == null) {
        // Thành công -> Về màn hình chính
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã OTP không đúng!")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Mã OTP đã được gửi đến ${widget.email}", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              decoration: const InputDecoration(
                hintText: "______",
                counterText: "",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(backgroundColor: Palette.primary),
              child: isLoading ? const CircularProgressIndicator() : const Text("Xác nhận", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}