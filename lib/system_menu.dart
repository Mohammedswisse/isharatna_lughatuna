import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'text_translation_page.dart';
import 'voice_translation_page.dart';
import 'lessons_page.dart';
import 'games_page.dart';

class SystemMenuPage extends StatefulWidget {
  const SystemMenuPage({super.key});

  @override
  State<SystemMenuPage> createState() => _SystemMenuPageState();
}

class _SystemMenuPageState extends State<SystemMenuPage> {
  static const String _genderKey = 'character_gender';
  static const String _skinKey = 'character_skin';

  String selectedGender = 'male';
  String selectedSkinColor = 'white';

  String savedGender = 'male';
  String savedSkinColor = 'white';

  bool isSaving = false;
  bool isSaved = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedCharacter();
  }

  Future<void> _loadSavedCharacter() async {
    final prefs = await SharedPreferences.getInstance();

    final gender = prefs.getString(_genderKey) ?? 'male';
    final skin = prefs.getString(_skinKey) ?? 'white';

    if (!mounted) return;

    setState(() {
      savedGender = gender;
      savedSkinColor = skin;
      selectedGender = gender;
      selectedSkinColor = skin;
      isSaved = true;
    });
  }

  Future<void> _saveCharacter() async {
    setState(() {
      isSaving = true;
      isSaved = false;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_genderKey, selectedGender);
    await prefs.setString(_skinKey, selectedSkinColor);

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      savedGender = selectedGender;
      savedSkinColor = selectedSkinColor;
      isSaving = false;
      isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم تثبيت الشخصية بنجاح',
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff0f172a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  bool get _hasUnsavedChanges {
    return selectedGender != savedGender ||
        selectedSkinColor != savedSkinColor;
  }

  String get _previewLabel {
    final genderText = selectedGender == 'female' ? 'أنثى' : 'ذكر';
    final skinText = selectedSkinColor == 'dark' ? 'أسمر' : 'أبيض';
    return '$genderText • $skinText';
  }

  String get _characterImagePath {
    return 'assets/images/characters/${selectedGender}_${selectedSkinColor}.png';
  }

  Future<Map<String, String>> _getFixedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'gender': prefs.getString(_genderKey) ?? 'male',
      'skin': prefs.getString(_skinKey) ?? 'white',
    };
  }

  Future<void> _goToPage(int index) async {
    if (index == 0) return;

    if (_hasUnsavedChanges || !isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يرجى تثبيت الشخصية أولاً قبل الانتقال',
            textDirection: TextDirection.rtl,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff7c3aed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
      return;
    }

    final fixedCharacter = await _getFixedCharacter();
    final fixedGender = fixedCharacter['gender'] ?? 'male';
    final fixedSkin = fixedCharacter['skin'] ?? 'white';

    Widget page;

    switch (index) {
      case 1:
        page = TextTranslationPage(
          selectedGender: fixedGender,
          selectedSkinColor: fixedSkin,
        );
        break;
      case 2:
        page = VoiceTranslationPage(
          selectedGender: fixedGender,
          selectedSkinColor: fixedSkin,
        );
        break;
      case 3:
        page = const LessonsPage();
        break;
      case 4:
        page = const GamesPage();
        break;
      default:
        return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildTopBar() {
    const ink = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const accent1 = Color(0xff7c3aed);
    const accent2 = Color(0xff0ea5e9);

    return _glassCard(
      radius: 30,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [accent1, accent2],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent1.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.front_hand_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إشارتنا، لغتنا',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    const ink = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const accent1 = Color(0xff7c3aed);
    const accent2 = Color(0xff0ea5e9);

    return _glassCard(
      radius: 32,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [accent1, accent2],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent1.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'المعاينة الحالية',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    const SizedBox(height: 5),
                    Text(
                      _previewLabel,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.52),
                  Colors.white.withOpacity(0.24),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  left: -24,
                  child: _softBubble(
                    100,
                    const Color(0xff7c3aed).withOpacity(0.10),
                  ),
                ),
                Positioned(
                  bottom: -18,
                  right: -18,
                  child: _softBubble(
                    90,
                    const Color(0xff0ea5e9).withOpacity(0.10),
                  ),
                ),
                Center(
                  child: Image.asset(
                    _characterImagePath,
                    width: 245,
                    height: 245,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'لم يتم العثور على صورة الشخصية المحددة',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff475569),
                            height: 1.7,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    const ink = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const accent1 = Color(0xff7c3aed);
    const accent2 = Color(0xff0ea5e9);
    const ok1 = Color(0xff16a34a);
    const ok2 = Color(0xff22c55e);

    return _glassCard(
      radius: 32,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'تثبيت الشخصية',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختر النوع ولون البشرة ثم احفظ الشخصية ليتم اعتمادها في صفحات الترجمة',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          _dropdownField(
            label: 'النوع',
            icon: Icons.person_rounded,
            value: selectedGender,
            items: const {
              'male': 'ذكر',
              'female': 'أنثى',
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedGender = value;
                  isSaved = !_hasUnsavedChanges;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'لون البشرة',
            icon: Icons.palette_outlined,
            value: selectedSkinColor,
            items: const {
              'white': 'أبيض',
              'dark': 'أسمر',
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedSkinColor = value;
                  isSaved = !_hasUnsavedChanges;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveCharacter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: isSaved && !_hasUnsavedChanges
                        ? const [ok1, ok2]
                        : const [accent1, accent2],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSaved && !_hasUnsavedChanges
                              ? ok1
                              : accent1)
                          .withOpacity(0.26),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    isSaving
                        ? 'جارٍ التثبيت'
                        : isSaved && !_hasUnsavedChanges
                            ? 'تم تثبيت الشخصية'
                            : 'تثبيت الشخصية الآن',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _hasUnsavedChanges
                  ? const Color(0xfffef3c7).withOpacity(0.85)
                  : const Color(0xffdcfce7).withOpacity(0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hasUnsavedChanges
                    ? const Color(0xfff59e0b).withOpacity(0.30)
                    : const Color(0xff22c55e).withOpacity(0.30),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _hasUnsavedChanges
                      ? Icons.info_outline_rounded
                      : Icons.verified_rounded,
                  size: 20,
                  color: _hasUnsavedChanges
                      ? const Color(0xffb45309)
                      : const Color(0xff15803d),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasUnsavedChanges
                        ? 'يوجد تعديل غير محفوظ، اضغط على زر التثبيت لاعتماد التغييرات'
                        : 'تم اعتماد الشخصية الحالية، وستُستخدم تلقائياً داخل صفحات الترجمة',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      color: _hasUnsavedChanges
                          ? const Color(0xff92400e)
                          : const Color(0xff166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const ink = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              label,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 18,
              color: muted,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            alignment: AlignmentDirectional.centerEnd,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.35),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.50),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: Color(0xff7c3aed),
                  width: 1.3,
                ),
              ),
            ),
            items: items.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  e.value,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double radius = 28,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.34),
                Colors.white.withOpacity(0.18),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _softBubble(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xfff8fbff);
    const bgBottom = Color(0xffeef4fb);
    const accent1 = Color(0xff7c3aed);
    const accent2 = Color(0xff0ea5e9);
    const accent3 = Color(0xff22c55e);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgBottom,
        extendBody: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgTop, bgBottom],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -90,
              right: -70,
              child: _glowCircle(270, accent1.withOpacity(0.16)),
            ),
            Positioned(
              top: 110,
              left: -90,
              child: _glowCircle(230, accent2.withOpacity(0.13)),
            ),
            Positioned(
              bottom: -120,
              left: 20,
              child: _glowCircle(290, accent3.withOpacity(0.10)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 126),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        _buildPreviewPanel(),
                        const SizedBox(height: 18),
                        _buildControlPanel(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _LuxuryBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) async {
            if (index == currentIndex) return;
            await _goToPage(index);
            if (!mounted) return;
            setState(() => currentIndex = 0);
          },
        ),
      ),
    );
  }
}

class _LuxuryBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LuxuryBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff7c3aed);
    const secondary = Color(0xff0ea5e9);
    const muted = Color(0xff94a3b8);
    const activeText = Color(0xff4c1d95);

    final items = const [
      ('الرئيسية', Icons.home_rounded),
      ('ترجمة نصية', Icons.text_snippet_rounded),
      ('ترجمة صوتية', Icons.mic_rounded),
      ('دروس', Icons.menu_book_rounded),
      ('ألعاب', Icons.sports_esports_rounded),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 106,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.90),
              Colors.white.withOpacity(0.74),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.65),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.13),
              blurRadius: 24,
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
                          curve: Curves.easeOut,
                          width: isActive ? 48 : 42,
                          height: isActive ? 48 : 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [primary, secondary],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  )
                                : null,
                            color: isActive
                                ? null
                                : Colors.white.withOpacity(0.55),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: primary.withOpacity(0.24),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            items[index].$2,
                            color: isActive ? Colors.white : muted,
                            size: isActive ? 22 : 20,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          items[index].$1,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 10.4,
                            fontWeight:
                                isActive ? FontWeight.w900 : FontWeight.w700,
                            color: isActive ? activeText : muted,
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

class _BottomNavItemData {
  final String label;
  final IconData icon;

  const _BottomNavItemData(this.label, this.icon);
}