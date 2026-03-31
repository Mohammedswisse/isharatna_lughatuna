import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_dashboard_page.dart';
import 'admin_phrases_page.dart';
import 'admin_lessons_page.dart';

class AdminProfilePage extends StatefulWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;

  const AdminProfilePage({
    super.key,
    required this.adminId,
    required this.adminName,
    this.phrasesCount = 0,
    this.lessonsCount = 0,
  });

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
static const String baseUrl =
    'http://swisse.ly/isharatna_laravel_project/public/index.php/api';
  bool isLoading = true;
  bool isSaving = false;
  bool isEditMode = false;

  int? adminId;
  String currentUsername = '';
  String createdAt = '';
  String updatedAt = '';
  int currentIndex = 3;

  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    adminId = widget.adminId;
    usernameController = TextEditingController(text: widget.adminName);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _loadAdminProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/${widget.adminId}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final admin = data['admin'];

        setState(() {
          adminId = admin['id'];
          currentUsername = (admin['username'] ?? '').toString();
          createdAt = (admin['created_at'] ?? '').toString();
          updatedAt = (admin['updated_at'] ?? '').toString();

          usernameController.text = currentUsername;
        });
      } else {
        _showSnackBar(data['message'] ?? 'تعذر تحميل البيانات');
      }
    } catch (e) {
      _showSnackBar('فشل الاتصال بالخادم');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startEdit() {
    setState(() {
      isEditMode = true;
      passwordController.clear();
      confirmPasswordController.clear();
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditMode = false;
      usernameController.text = currentUsername;
      passwordController.clear();
      confirmPasswordController.clear();
    });
  }

  Future<void> _saveProfile() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirmation = confirmPasswordController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('اسم المستخدم مطلوب');
      return;
    }

    if (password.isNotEmpty && password.length < 4) {
      _showSnackBar('كلمة المرور يجب ألا تقل عن 4 أحرف');
      return;
    }

    if (password.isNotEmpty && password != passwordConfirmation) {
      _showSnackBar('تأكيد كلمة المرور غير مطابق');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final body = <String, String>{
        'username': username,
      };

      if (password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/${widget.adminId}/update-profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final admin = data['admin'];

        setState(() {
          currentUsername = (admin['username'] ?? username).toString();
          updatedAt = (admin['updated_at'] ?? '').toString();
          usernameController.text = currentUsername;
          passwordController.clear();
          confirmPasswordController.clear();
          isEditMode = false;
        });

        _showSnackBar(data['message'] ?? 'تم تحديث البيانات بنجاح');
      } else {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            _showSnackBar(firstError.first.toString());
          } else {
            _showSnackBar(data['message'] ?? 'فشل تحديث البيانات');
          }
        } else {
          _showSnackBar(data['message'] ?? 'فشل تحديث البيانات');
        }
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الاتصال بالخادم');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _onNavTap(int index) {
    if (index == currentIndex) return;

    Widget page;

    if (index == 0) {
      page = AdminDashboardPage(
        adminId: widget.adminId,
        adminName: currentUsername.isEmpty ? widget.adminName : currentUsername,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else if (index == 1) {
      page = AdminPhrasesPage(
        adminId: widget.adminId,
        adminName: currentUsername.isEmpty ? widget.adminName : currentUsername,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else if (index == 2) {
      page = AdminLessonsPage(
        adminId: widget.adminId,
        adminName: currentUsername.isEmpty ? widget.adminName : currentUsername,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else {
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.right,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) return 'غير متوفر';
    try {
      final dt = DateTime.parse(value).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const secondary = Color(0xff7c3aed);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const info = Color(0xff0891b2);
    const danger = Color(0xffdc2626);
    const success = Color(0xff16a34a);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfff6f8fc),
        extendBody: true,
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAdminProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 118),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [primary, secondary],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.20),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currentUsername,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ملف المدير',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(0.90),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      'رقم المدير: ${adminId ?? widget.adminId}',
                                      style: const TextStyle(
                                        fontFamily: 'Almarai',
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'عدد العبارات',
                              value: '${widget.phrasesCount}',
                              icon: Icons.translate_rounded,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'عدد الدروس',
                              value: '${widget.lessonsCount}',
                              icon: Icons.menu_book_rounded,
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isEditMode) ...[
                        _InfoCard(
                          title: 'اسم المستخدم',
                          value: currentUsername,
                          icon: Icons.person_rounded,
                          color: info,
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'تاريخ الإنشاء',
                          value: _formatDate(createdAt),
                          icon: Icons.event_available_rounded,
                          color: success,
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'آخر تحديث',
                          value: _formatDate(updatedAt),
                          icon: Icons.update_rounded,
                          color: primary,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                title: 'تعديل البيانات',
                                subtitle: 'تحديث اسم المستخدم أو كلمة المرور',
                                icon: Icons.edit_rounded,
                                color1: primary,
                                color2: secondary,
                                onTap: _startEdit,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionCard(
                                title: 'تحديث من الخادم',
                                subtitle: 'إعادة تحميل البيانات',
                                icon: Icons.refresh_rounded,
                                color1: const Color(0xff0891b2),
                                color2: const Color(0xff06b6d4),
                                onTap: _loadAdminProfile,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _EditField(
                          controller: usernameController,
                          label: 'اسم المستخدم',
                          icon: Icons.person_rounded,
                        ),
                        const SizedBox(height: 12),
                        _EditField(
                          controller: passwordController,
                          label: 'كلمة المرور الجديدة',
                          icon: Icons.lock_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        _EditField(
                          controller: confirmPasswordController,
                          label: 'تأكيد كلمة المرور',
                          icon: Icons.lock_reset_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : _saveProfile,
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',
                                  style: const TextStyle(
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : _cancelEdit,
                                icon: const Icon(Icons.close_rounded),
                                label: const Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: danger.withOpacity(0.10),
                                  foregroundColor: danger,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: _LuxuryBottomBar(
          currentIndex: currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Almarai'),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xffdbe3f0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.20),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xffeef2ff),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LuxuryBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 112,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.98),
              Colors.white.withOpacity(0.92),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: Colors.white,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4f46e5).withOpacity(0.12),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LuxuryNavItem(
              label: 'الرئيسية',
              icon: Icons.home_rounded,
              active: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _LuxuryNavItem(
              label: 'العبارات',
              icon: Icons.translate_rounded,
              active: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _LuxuryNavItem(
              label: 'الدروس',
              icon: Icons.video_library_rounded,
              active: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _LuxuryNavItem(
              label: 'ملفي',
              icon: Icons.person_rounded,
              active: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _LuxuryNavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const secondary = Color(0xff7c3aed);
    const muted = Color(0xff94a3b8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: active
              ? const LinearGradient(
                  colors: [
                    Color(0xffeef2ff),
                    Color(0xfff5f3ff),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
          border: active
              ? Border.all(
                  color: const Color(0xffc7d2fe),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: active ? 50 : 40,
              height: active ? 50 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active
                    ? const LinearGradient(
                        colors: [primary, secondary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                color: active ? null : const Color(0xfff1f5f9),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.24),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : muted,
                size: active ? 24 : 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                color: active ? primary : muted,
                fontSize: 11.5,
                height: 1.15,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}