import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/palette.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;

  // Controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final AuthService _authService = AuthService();
  final EmailOTP _emailOTP = EmailOTP();

  // 1. Hàm xử lý logic CHÍNH (Đăng nhập hoặc Gửi OTP)
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    String? error;

    if (isLogin) {
      // --- LOGIC ĐĂNG NHẬP ---
      error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
    } else {
      // --- LOGIC ĐĂNG KÝ (GỬI OTP) ---

      // Cấu hình OTP
      _emailOTP.setConfig(
          appEmail: "support@trivok.com",
          appName: "Trivok Travel",
          userEmail: _emailController.text.trim(),
          otpLength: 6,
          otpType: OTPType.digitsOnly
      );

      // Gửi OTP
      bool result = await _emailOTP.sendOTP();

      if (result) {
        // Gửi thành công -> Chuyển sang màn hình nhập OTP
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP đã gửi! Kiểm tra mail nhé.")));
        Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
          name: _nameController.text.trim(),
          myAuth: _emailOTP,
        )));
      } else {
        error = "Lỗi gửi OTP. Kiểm tra lại email!";
      }
    }

    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  // 2. Hàm Quên mật khẩu
  void _forgotPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập Email hợp lệ trước!")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang gửi link reset...")));
    String? error = await _authService.sendPasswordResetEmail(_emailController.text.trim());

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi link reset pass vào email!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  // 3. Hàm Login Google
  void _googleSignIn() async {
    setState(() => isLoading = true);
    String? error = await _authService.signInWithGoogle();
    setState(() => isLoading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.travel_explore, size: 80, color: Palette.primary),
                const SizedBox(height: 20),
                Text(isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold, color: Palette.primary)),
                Text(isLogin ? "Chào mừng trở lại!" : "Tạo tài khoản mới", style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),

                // Ô nhập liệu Tên (chỉ hiện khi Đăng ký)
                if (!isLogin) ...[
                  _buildTextField(_nameController, "Họ và tên", Icons.person, isName: true),
                  const SizedBox(height: 16),
                ],
                // Ô Email và Mật khẩu
                _buildTextField(_emailController, "Email", Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_passController, "Mật khẩu", Icons.lock, isPassword: true),

                // Nút Quên mật khẩu (Chỉ hiện khi Đăng nhập)
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text("Quên mật khẩu?", style: TextStyle(color: Palette.textSub)),
                    ),
                  ),

                const SizedBox(height: 10),

                // Nút Login/Register Chính
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? "ĐĂNG NHẬP" : "TIẾP TỤC", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.all(8), child: Text("HOẶC")), Expanded(child: Divider())]),
                const SizedBox(height: 20),

                // Nút Google Sign In
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _googleSignIn,
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text("Đăng nhập bằng Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),
                // Nút chuyển đổi Login/Register
                TextButton(
                  onPressed: () {
                    // Xóa dữ liệu cũ khi chuyển mode
                    _emailController.clear();
                    _passController.clear();
                    _nameController.clear();
                    setState(() => isLogin = !isLogin);
                  },
                  child: Text(
                    isLogin ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập",
                    style: const TextStyle(color: Palette.accent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con để vẽ ô nhập liệu
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isName = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Palette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Palette.background,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Vui lòng nhập thông tin";
        if (!isLogin && isName && value.length < 3) return "Tên phải có ít nhất 3 ký tự";
        if (!isLogin && isPassword && value.length < 6) return "Mật khẩu phải có ít nhất 6 ký tự";
        return null;
      },
    );
  }
}