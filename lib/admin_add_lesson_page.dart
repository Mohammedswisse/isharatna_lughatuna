import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard_page.dart';
import 'admin_lessons_page.dart';
import 'admin_phrases_page.dart';
import 'admin_profile_page.dart';
import 'services/api_service.dart';

class AdminAddLessonPage extends StatefulWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;

  const AdminAddLessonPage({
    super.key,
    required this.adminId,
    required this.adminName,
    this.phrasesCount = 0,
    this.lessonsCount = 0,
  });

  @override
  State<AdminAddLessonPage> createState() => _AdminAddLessonPageState();
}

class _AdminAddLessonPageState extends State<AdminAddLessonPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String? selectedVideoPath;
  String? selectedVideoName;
  String? lastErrorMessage;

  bool isLoading = false;
  int currentIndex = 2;

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.path == null || file.path!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر قراءة ملف الفيديو',
              style: TextStyle(fontFamily: 'Almarai'),
            ),
          ),
        );
        return;
      }

      setState(() {
        selectedVideoPath = file.path!;
        selectedVideoName = file.name;
        lastErrorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح مدير الملفات: $e',
            style: const TextStyle(fontFamily: 'Almarai'),
          ),
        ),
      );
    }
  }

  Future<void> _saveLesson() async {
    FocusScope.of(context).unfocus();

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال عنوان الدرس ومحتواه',
            style: TextStyle(fontFamily: 'Almarai'),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      lastErrorMessage = null;
    });

    final result = await ApiService.addLesson(
      title: title,
      content: content,
      videoFilePath: selectedVideoPath,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    final bool success = result['success'] == true;
    final String message =
        result['message']?.toString() ?? 'تعذر حفظ الدرس';

    if (!success) {
      setState(() {
        lastErrorMessage = message;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminLessonsPage(
            adminId: widget.adminId,
            adminName: widget.adminName,
            phrasesCount: widget.phrasesCount,
            lessonsCount: widget.lessonsCount + 1,
          ),
        ),
      );
    }
  }

  void _onNavTap(int index) {
    if (index == currentIndex) return;

    late Widget page;

    if (index == 0) {
      page = AdminDashboardPage(
        adminId: widget.adminId,
        adminName: widget.adminName,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else if (index == 1) {
      page = AdminPhrasesPage(
        adminId: widget.adminId,
        adminName: widget.adminName,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else if (index == 2) {
      page = AdminLessonsPage(
        adminId: widget.adminId,
        adminName: widget.adminName,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    } else {
      page = AdminProfilePage(
        adminId: widget.adminId,
        adminName: widget.adminName,
        phrasesCount: widget.phrasesCount,
        lessonsCount: widget.lessonsCount,
      );
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Almarai',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xff0f172a),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xff0f172a),
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    const primary = Color(0xff4f46e5);

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Almarai',
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xffdbe3f0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    );
  }

  Widget _buildErrorCard() {
    if (lastErrorMessage == null || lastErrorMessage!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xfffff1f2),
        border: Border.all(color: const Color(0xfffecdd3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'تفاصيل الخطأ',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xffbe123c),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lastErrorMessage!,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff9f1239),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: const Color(0xffeef2ff),
        extendBody: true,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 122),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.92),
                      border: Border.all(color: Colors.white, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'إضافة درس جديد',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: dark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'أضف عنوان الدرس، المحتوى، ثم اختر ملف الفيديو لرفعه وربطه بالدرس',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: muted,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffeef2ff),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'المدير: ${widget.adminName}',
                                      style: const TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff5f3ff),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'المعرف: ${widget.adminId}',
                                      style: const TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [primary, secondary],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: const Icon(
                            Icons.ondemand_video_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white, width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSectionTitle('بيانات الدرس'),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: titleController,
                          label: 'عنوان الدرس',
                          icon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: contentController,
                          label: 'محتوى الدرس',
                          icon: Icons.menu_book_rounded,
                          maxLines: 6,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.96),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xffdbe3f0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: const Color(0xffeef2ff),
                                    ),
                                    child: const Icon(
                                      Icons.video_library_rounded,
                                      color: primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'ملف الفيديو',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: dark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (selectedVideoName != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff8fafc),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xffe2e8f0),
                                    ),
                                  ),
                                  child: Text(
                                    'الملف المختار:\n$selectedVideoName',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 12.5,
                                      color: dark,
                                      fontWeight: FontWeight.w700,
                                      height: 1.6,
                                    ),
                                  ),
                                )
                              else
                                const Text(
                                  'لم يتم اختيار فيديو بعد',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 12.5,
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _pickVideo,
                                  icon: const Icon(Icons.upload_file_rounded),
                                  label: const Text(
                                    'اختيار ملف فيديو',
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primary,
                                    side: const BorderSide(
                                      color: Color(0xffc7d2fe),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildErrorCard(),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _saveLesson,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [primary, secondary],
                                ),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'إضافة الدرس',
                                            style: TextStyle(
                                              fontFamily: 'Almarai',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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