import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'admin_dashboard_page.dart';
import 'admin_phrases_page.dart';
import 'admin_lessons_page.dart';
import 'admin_profile_page.dart';

class AdminAddPhrasePage extends StatefulWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;
  final Map<String, dynamic>? phrase;

  const AdminAddPhrasePage({
    super.key,
    required this.adminId,
    required this.adminName,
    this.phrasesCount = 0,
    this.lessonsCount = 0,
    this.phrase,
  });

  @override
  State<AdminAddPhrasePage> createState() => _AdminAddPhrasePageState();
}

class _AdminAddPhrasePageState extends State<AdminAddPhrasePage> {
  late TextEditingController textController;
  late TextEditingController typeController;

  String selectedGender = 'male';
  String selectedSkinColor = 'white';

  bool isLoading = false;
  String? selectedGifPath;
  String? selectedGifName;
  String? existingImagePath;
  String? lastErrorMessage;

  int currentIndex = 1;

  bool get isEditMode => widget.phrase != null;

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(
      text: widget.phrase?['text']?.toString() ?? '',
    );
    typeController = TextEditingController(
      text: widget.phrase?['type']?.toString() ?? '',
    );

    selectedGender = widget.phrase?['gender']?.toString() ?? 'male';
    selectedSkinColor = widget.phrase?['skin_color']?.toString() ?? 'white';
    existingImagePath = widget.phrase?['image_path']?.toString();
  }

  @override
  void dispose() {
    textController.dispose();
    typeController.dispose();
    super.dispose();
  }

  Future<void> _pickGif() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.path == null || file.path!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر قراءة مسار الملف المختار',
              style: TextStyle(fontFamily: 'Almarai'),
            ),
          ),
        );
        return;
      }

      setState(() {
        selectedGifPath = file.path!;
        selectedGifName = file.name;
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

  Future<void> _savePhrase() async {
    FocusScope.of(context).unfocus();

    final text = textController.text.trim();
    final type = typeController.text.trim();

    if (text.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال النص والنوع',
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

    Map<String, dynamic> result;

    if (isEditMode) {
      result = await ApiService.updatePhrase(
        id: widget.phrase!['id'],
        text: text,
        type: type,
        gender: selectedGender,
        skinColor: selectedSkinColor,
        imageFilePath: selectedGifPath,
      );
      debugPrint('UPDATE PHRASE RESULT: $result');
    } else {
      result = await ApiService.addPhrase(
        text: text,
        type: type,
        gender: selectedGender,
        skinColor: selectedSkinColor,
        imageFilePath: selectedGifPath,
      );
      debugPrint('ADD PHRASE RESULT: $result');
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    final bool success = result['success'] == true;
    final String message = result['message']?.toString() ??
        (isEditMode ? 'تعذر تعديل العبارة' : 'تعذر إضافة العبارة');

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
      Navigator.pop(context, true);
    }
  }

  void _onNavTap(int index) {
    if (index == currentIndex) return;

    Widget page;

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
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xff0f172a),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
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
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: const TextStyle(
              fontFamily: 'Almarai',
              color: Color(0xff94a3b8),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.82),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xff4f46e5),
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required List<Map<String, String>> items,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xff0f172a),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: items.map((item) {
            final bool isSelected = currentValue == item['value'];

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: item == items.last ? 0 : 10,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onChanged(item['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.80),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xffe2e8f0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item['label']!,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff334155),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileCard() {
    final bool hasNewFile =
        selectedGifPath != null && selectedGifPath!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.82),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'ملف الصورة المتحركة',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xff0f172a),
            ),
          ),
          const SizedBox(height: 12),
          if (hasNewFile)
            Text(
              'الملف المختار: $selectedGifName',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xff334155),
              ),
            )
          else if (existingImagePath != null && existingImagePath!.isNotEmpty)
            Text(
              'الملف الحالي: $existingImagePath',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xff334155),
              ),
            )
          else
            const Text(
              'لم يتم اختيار أي ملف بعد',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xff64748b),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickGif,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text(
                'اختيار ملف GIF',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff4f46e5),
                side: const BorderSide(color: Color(0xffc7d2fe)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _savePhrase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 17),
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
                : Text(
                    isEditMode ? 'حفظ التعديلات' : 'إضافة العبارة',
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.92),
        border: Border.all(color: Colors.white, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4f46e5).withOpacity(0.10),
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
                Text(
                  isEditMode ? 'تعديل العبارة' : 'إضافة عبارة جديدة',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff0f172a),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'أدخل بيانات العبارة وارفع الملف ثم احفظ',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff64748b),
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xff4f46e5), Color(0xff7c3aed)],
              ),
            ),
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.88),
        border: Border.all(color: Colors.white, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextField(
            controller: textController,
            label: 'نص العبارة',
            hint: 'مثال: مرحبا',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: typeController,
            label: 'نوع العبارة',
            hint: 'مثال: عبارات ترحيب',
          ),
          const SizedBox(height: 18),
          _buildSelectorCard(
            title: 'الجنس',
            currentValue: selectedGender,
            onChanged: (value) {
              setState(() => selectedGender = value);
            },
            items: const [
              {'label': 'ذكر', 'value': 'male'},
              {'label': 'أنثى', 'value': 'female'},
            ],
          ),
          const SizedBox(height: 18),
          _buildSelectorCard(
            title: 'لون البشرة',
            currentValue: selectedSkinColor,
            onChanged: (value) {
              setState(() => selectedSkinColor = value);
            },
            items: const [
              {'label': 'أبيض', 'value': 'white'},
              {'label': 'أسمر', 'value': 'dark'},
            ],
          ),
          const SizedBox(height: 18),
          _buildFileCard(),
          _buildErrorCard(),
          const SizedBox(height: 22),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return _AdminBottomBar(
      currentIndex: currentIndex,
      onTap: _onNavTap,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 18),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const muted = Color(0xff94a3b8);

    final items = const [
      ('الرئيسية', Icons.dashboard_rounded),
      ('العبارات', Icons.chat_bubble_rounded),
      ('الدروس', Icons.menu_book_rounded),
      ('الملف الشخصي', Icons.person_rounded),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 102,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.92),
              Colors.white.withOpacity(0.78),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Row(
            textDirection: TextDirection.rtl,
            children: List.generate(items.length, (index) {
              final isActive = currentIndex == index;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: isActive ? 46 : 40,
                          height: isActive ? 46 : 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xff4f46e5),
                                      Color(0xff7c3aed),
                                    ],
                                  )
                                : null,
                            color: isActive
                                ? null
                                : Colors.white.withOpacity(0.4),
                          ),
                          child: Icon(
                            items[index].$2,
                            color: isActive ? Colors.white : muted,
                            size: isActive ? 22 : 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          items[index].$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 10.5,
                            fontWeight:
                                isActive ? FontWeight.w800 : FontWeight.w700,
                            color: isActive ? primary : muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}