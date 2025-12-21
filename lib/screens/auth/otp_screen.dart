import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../config/palette.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Constants
  static const int _otpLength = 6; // Đổi thành 6 số cho giống logic "123456"
  static const int _timerDuration = 60;

  // Controllers & Focus Nodes
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  // State variables
  int _secondsRemaining = _timerDuration;
  bool _enableResend = false;
  Timer? _timer;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize controllers and focus nodes for each digit
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = _timerDuration;
      _enableResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _enableResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resendCode() async {
    // Giả lập gửi lại mã
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã gửi lại mã OTP (Vẫn là 123456 nhé!)")),
    );
    _startTimer();
  }

  void _verifyOtp() async {
    // Combine text from all controllers
    String otp = _controllers.map((e) => e.text).join();

    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 số")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- LOGIC CHECK OTP GIẢ LẬP ---
    // (Vì bạn đang dùng giả lập OTP 123456 ở màn Login)
    await Future.delayed(const Duration(seconds: 1)); // Giả vờ check server

    if (otp == "123456") {
      // OTP đúng -> Gọi API Đăng ký thật
      String? error = await _authService.signUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (error == null) {
          // Đăng ký thành công -> Về màn hình chính (hoặc màn login để đăng nhập lại)
          // Ở đây mình pop hết về root để AuthGate tự xử lý trạng thái đăng nhập
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đăng ký thất bại: $error"), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // OTP sai
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã OTP không đúng!"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onFieldChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field: hide keyboard
        _focusNodes[index].unfocus();
        // Tự động submit khi nhập đủ
        _verifyOtp();
      }
    } else {
      // Move to previous field if empty (Backspace logic)
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Palette.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, size: 50, color: Palette.primary),
              ),
              const SizedBox(height: 24),
              Text(
                "Xác thực OTP",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Palette.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Chúng tôi đã gửi mã xác thực đến email\n${widget.email}",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _otpLength,
                      (index) => _buildOtpDigitField(context, index),
                ),
              ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "XÁC NHẬN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa nhận được mã? ", style: GoogleFonts.nunito(color: Colors.grey[600])),
                  if (_enableResend)
                    GestureDetector(
                      onTap: _resendCode,
                      child: Text(
                        "Gửi lại",
                        style: GoogleFonts.nunito(color: Palette.accent, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Text(
                      "Gửi lại sau ${_secondsRemaining}s",
                      style: GoogleFonts.nunito(color: Palette.primary, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigitField(BuildContext context, int index) {
    return SizedBox(
      height: 50,
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        onChanged: (value) => _onFieldChanged(value, index),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Palette.primary, width: 2),
          ),
          filled: true,
          fillColor: Palette.background,
        ),
      ),
    );
  }
}