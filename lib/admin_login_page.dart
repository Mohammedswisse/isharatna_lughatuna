import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال اسم المستخدم وكلمة المرور',
            style: TextStyle(fontFamily: 'Almarai'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.adminLogin(
        username: username,
        password: password,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result['success'] == true) {
        final admin = result['admin'] ?? {};

        final int adminId = admin['id'] is int
            ? admin['id']
            : int.tryParse('${admin['id']}') ?? 0;

        final String adminUsername =
            (admin['username'] ?? username).toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardPage(
              adminId: adminId,
              adminName: adminUsername,
              phrasesCount: 0,
              lessonsCount: 0,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'فشل تسجيل الدخول',
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'حدث خطأ أثناء تسجيل الدخول',
            style: TextStyle(fontFamily: 'Almarai'),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const secondary = Color(0xff7c3aed);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffeef2ff),
                Color(0xfff8fafc),
                Color(0xffede9fe),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Container(
                  width: 430,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [primary, secondary],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.30),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'تسجيل دخول الإدارة',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أدخل بيانات المدير للانتقال إلى لوحة التحكم',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          color: muted,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: usernameController,
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'اسم المستخدم',
                          labelStyle: const TextStyle(fontFamily: 'Almarai'),
                          prefixIcon:
                              const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: Color(0xffdbe3f0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xfff8fafc),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textAlign: TextAlign.right,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          labelStyle: const TextStyle(fontFamily: 'Almarai'),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: Color(0xffdbe3f0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xfff8fafc),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _login,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login_rounded),
                          label: Text(
                            isLoading ? 'جاري التحقق...' : 'تسجيل الدخول',
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text(
                          'الرجوع',
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}