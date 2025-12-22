import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../config/palette.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      // Reset animation để tạo hiệu ứng chuyển đổi mượt mà
      _animationController.reset();
      _animationController.forward();
    });
  }

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
      // --- LOGIC ĐĂNG KÝ (Giả lập gửi OTP) ---
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mã OTP xác thực là: 123456"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
        );

        Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
          name: _nameController.text.trim(),
        )));
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
      if (isLogin && error != null) {
        _showError(error);
      }
    }
  }

  void _forgotPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError("Vui lòng nhập Email hợp lệ để lấy lại mật khẩu!");
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang gửi link reset...")));
    String? error = await _authService.sendPasswordResetEmail(_emailController.text.trim());
    if (error == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi link reset pass vào email!"), backgroundColor: Colors.green));
    } else {
      _showError(error);
    }
  }

  void _googleSignIn() async {
    setState(() => isLoading = true);
    String? error = await _authService.signInWithGoogle();
    setState(() => isLoading = false);
    if (error != null) _showError(error);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. BACKGROUND DECORATION
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Palette.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Palette.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 2. MAIN CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- LOGO SECTION ---
                      // Bạn có thể thay Icon bằng Image.asset('assets/images/logo.png')
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/logo_a.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),


                      const SizedBox(height: 10),

                      // Tiêu đề chào mừng
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              isLogin ? "Xin chào trở lại!" : "Tạo tài khoản mới",
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLogin
                                  ? "Đăng nhập để tiếp tục hành trình khám phá"
                                  : "Đăng ký để bắt đầu những chuyến đi tuyệt vời",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- FORM INPUT ---
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                label: "Họ và tên",
                                icon: Icons.person_outline,
                                isName: true,
                              ),
                              const SizedBox(height: 16),
                            ],

                            _buildTextField(
                              controller: _emailController,
                              label: "Email",
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              controller: _passController,
                              label: "Mật khẩu",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            if (isLogin)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _forgotPassword,
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: GoogleFonts.nunito(
                                      color: Palette.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Nút Action Chính (Login/Register)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Palette.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 5,
                                  shadowColor: Palette.primary.withOpacity(0.4),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                )
                                    : Text(
                                  isLogin ? "ĐĂNG NHẬP" : "TIẾP TỤC",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- SOCIAL LOGIN ---
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Hoặc tiếp tục với",
                              style: GoogleFonts.nunito(color: Colors.grey[500], fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata, // Thay bằng asset icon Google nếu có
                            color: Colors.red,
                            onTap: _googleSignIn,
                            size: 40,
                          ),

                        ],
                      ),

                      const Spacer(),

                      // --- FOOTER TOGGLE ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin ? "Chưa có tài khoản? " : "Đã có tài khoản? ",
                            style: GoogleFonts.nunito(color: Colors.grey[600]),
                          ),
                          GestureDetector(
                            onTap: _toggleMode,
                            child: Text(
                              isLogin ? "Đăng ký ngay" : "Đăng nhập",
                              style: GoogleFonts.nunito(
                                color: Palette.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isName = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Palette.primary.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Palette.primary, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Vui lòng nhập $label";
          if (!isLogin && isName && value.length < 3) return "Tên quá ngắn";
          if (!isLogin && isPassword && value.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
          return null;
        },
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onTap, double size = 30}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
