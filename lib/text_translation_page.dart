import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'system_menu.dart';
import 'voice_translation_page.dart';
import 'lessons_page.dart';
import 'games_page.dart';

class TextTranslationPage extends StatefulWidget {
  final String selectedGender;
  final String selectedSkinColor;

  const TextTranslationPage({
    super.key,
    required this.selectedGender,
    required this.selectedSkinColor,
  });

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  static const String _genderKey = 'character_gender';
  static const String _skinKey = 'character_skin';

  static const String baseUrl =
      'https://swisse.ly/isharatna_laravel_project/public/index.php/api';

  static const String storageBaseUrl =
      'https://swisse.ly/isharatna_laravel_project/storage/app/public/phrases';

  static const Duration _requestTimeout = Duration(seconds: 25);

  final TextEditingController textController = TextEditingController();

  bool isLoading = false;
  bool isCharacterLoading = true;

  String fixedGender = 'male';
  String fixedSkinColor = 'white';

  String? resultMediaPath;
  String? resultMessage;
  Uint8List? resultImageBytes;

  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadFixedCharacter();
  }

  Future<void> _loadFixedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getString(_genderKey);
    final savedSkin = prefs.getString(_skinKey);

    if (!mounted) return;

    setState(() {
      fixedGender = savedGender ?? widget.selectedGender;
      fixedSkinColor = savedSkin ?? widget.selectedSkinColor;
      isCharacterLoading = false;
    });
  }

  String get _characterImagePath {
    return 'assets/images/characters/${fixedGender}_${fixedSkinColor}.png';
  }

  String get _previewLabel {
    final genderText = fixedGender == 'female' ? 'أنثى' : 'ذكر';
    final skinText = fixedSkinColor == 'dark' ? 'أسمر' : 'أبيض';
    return '$genderText • $skinText';
  }

  Map<String, dynamic> _safeDecodeMap(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {'message': decoded.toString()};
    } catch (_) {
      return {'message': body};
    }
  }

  String _forceHttps(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }

  String? _buildFinalImageUrl(Map<String, dynamic>? phrase) {
    if (phrase == null) return null;

    final imageUrl = phrase['image_url']?.toString().trim();
    final imagePath = phrase['image_path']?.toString().trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return _forceHttps(imageUrl);
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      String normalizedPath = imagePath;

      if (normalizedPath.startsWith('/')) {
        normalizedPath = normalizedPath.substring(1);
      }

      if (normalizedPath.startsWith('storage/')) {
        normalizedPath = normalizedPath.substring(8);
      }

      return '$storageBaseUrl/$normalizedPath';
    }

    return null;
  }

  Future<Uint8List?> _downloadImageBytes(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: const {'Accept': '*/*'},
          )
          .timeout(_requestTimeout);

      debugPrint('IMAGE DOWNLOAD STATUS: ${response.statusCode}');
      debugPrint('IMAGE DOWNLOAD URL: $url');
      debugPrint('IMAGE CONTENT TYPE: ${response.headers['content-type']}');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }

      return null;
    } on TimeoutException {
      debugPrint('IMAGE DOWNLOAD TIMEOUT: $url');
      return null;
    } catch (e, s) {
      debugPrint('IMAGE DOWNLOAD ERROR: $e');
      debugPrint('IMAGE DOWNLOAD STACK: $s');
      return null;
    }
  }

  Future<void> _translateText() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      setState(() {
        resultMediaPath = null;
        resultImageBytes = null;
        resultMessage = 'الرجاء إدخال العبارة أولاً';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال العبارة أولاً')),
      );
      return;
    }

    if (isCharacterLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جارٍ تحميل الشخصية المثبتة')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      resultMediaPath = null;
      resultImageBytes = null;
      resultMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/translate'),
            headers: const {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'text': text,
              'gender': fixedGender,
              'skin_color': fixedSkinColor,
            }),
          )
          .timeout(_requestTimeout);

      debugPrint('TRANSLATE STATUS: ${response.statusCode}');
      debugPrint('TRANSLATE BODY: ${response.body}');
      debugPrint('FIXED GENDER: $fixedGender');
      debugPrint('FIXED SKIN: $fixedSkinColor');

      final data = _safeDecodeMap(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          data['status']?.toString() == 'success') {
        final phrase = data['data'] is Map
            ? Map<String, dynamic>.from(data['data'] as Map)
            : null;

        final finalUrl = _buildFinalImageUrl(phrase);

        debugPrint('IMAGE_URL_FROM_API: ${phrase?['image_url']}');
        debugPrint('IMAGE_PATH_FROM_API: ${phrase?['image_path']}');
        debugPrint('SERVER_STORAGE_PATH: ${phrase?['server_storage_path']}');
        debugPrint('FINAL_IMAGE_URL: $finalUrl');

        Uint8List? downloadedBytes;
        if (finalUrl != null && finalUrl.isNotEmpty) {
          downloadedBytes = await _downloadImageBytes(finalUrl);
        }

        setState(() {
          resultMediaPath = finalUrl;
          resultImageBytes = downloadedBytes;

          if (downloadedBytes != null && downloadedBytes.isNotEmpty) {
            resultMessage =
                data['message']?.toString() ?? 'تم العثور على العبارة';
          } else if (finalUrl != null && finalUrl.isNotEmpty) {
            resultMessage = 'تم العثور على العبارة لكن تعذر تحميل الصورة';
          } else {
            resultMessage = 'تم العثور على العبارة لكن لا يوجد ملف صورة مرتبط بها';
          }
        });

        return;
      }

      final failureMessage =
          data['message']?.toString().trim().isNotEmpty == true
              ? data['message'].toString().trim()
              : 'لم يتم العثور على صورة مطابقة';

      setState(() {
        resultMediaPath = null;
        resultImageBytes = null;
        resultMessage = failureMessage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureMessage)),
      );
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        resultMediaPath = null;
        resultImageBytes = null;
        resultMessage = 'انتهت مهلة الاتصال بالخادم';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتهت مهلة الاتصال بالخادم')),
      );
    } catch (e, s) {
      debugPrint('TRANSLATE ERROR: $e');
      debugPrint('TRANSLATE STACK: $s');

      if (!mounted) return;

      setState(() {
        resultMediaPath = null;
        resultImageBytes = null;
        resultMessage = 'تعذر الاتصال بالخادم';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الاتصال بالخادم')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const SystemMenuPage();
        break;
      case 1:
        page = TextTranslationPage(
          selectedGender: fixedGender,
          selectedSkinColor: fixedSkinColor,
        );
        break;
      case 2:
        page = VoiceTranslationPage(
          selectedGender: fixedGender,
          selectedSkinColor: fixedSkinColor,
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.34),
                Colors.white.withOpacity(0.16),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.48),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xff7c3aed), Color(0xff0ea5e9)],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xff0f172a),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrokenPreview(String? url) {
    return Container(
      width: 260,
      height: 260,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Color(0xff64748b),
          ),
          const SizedBox(height: 10),
          const Text(
            'تم العثور على الرابط لكن تعذر عرض الصورة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xff475569),
            ),
          ),
          if (url != null && url.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              url,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xff64748b),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultPreview() {
    if (isLoading) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 320),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.42),
              Colors.white.withOpacity(0.18),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.50),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (resultImageBytes != null && resultImageBytes!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.18),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.52),
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.memory(
                  resultImageBytes!,
                  width: 270,
                  height: 270,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.30),
            ),
            child: Text(
              resultMessage ?? 'تم العثور على العبارة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xff475569),
              ),
            ),
          ),
        ],
      );
    }

    if (resultMediaPath != null && resultMediaPath!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.45),
                  Colors.white.withOpacity(0.18),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.52),
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  resultMediaPath!,
                  width: 270,
                  height: 270,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 270,
                      height: 270,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildBrokenPreview(resultMediaPath);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.30),
            ),
            child: Text(
              resultMessage ?? 'تم العثور على العبارة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xff475569),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 320),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.45),
                Colors.white.withOpacity(0.18),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.52),
            ),
          ),
          child: Center(
            child: Image.asset(
              _characterImagePath,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لم يتم العثور على صورة الشخصية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff475569),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.30),
          ),
          child: Text(
            resultMessage ?? 'ستظهر هنا الصورة المطابقة للعبارة حسب الشخصية المثبتة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff64748b),
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff7c3aed);
    const secondary = Color(0xff0ea5e9);
    const bgTop = Color(0xfff8fbff);
    const bgBottom = Color(0xffeef3fb);
    const ink = Color(0xff0f172a);
    const muted = Color(0xff64748b);

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
              right: -60,
              child: _glowCircle(240, primary.withOpacity(0.14)),
            ),
            Positioned(
              top: 120,
              left: -70,
              child: _glowCircle(210, secondary.withOpacity(0.12)),
            ),
            Positioned(
              bottom: -110,
              left: 20,
              child: _glowCircle(
                260,
                const Color(0xff22c55e).withOpacity(0.08),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 125),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _glassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [primary, secondary],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'الترجمة النصية',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: ink,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'حوّل العبارة المكتوبة إلى المعاينة المناسبة حسب الشخصية المثبتة',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: muted,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _glassCard(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.26),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    _characterImagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      color: muted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.white.withOpacity(0.28),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'الشخصية الحالية',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: muted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _previewLabel,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _glassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _sectionTitle(
                                'المعاينة',
                                Icons.image_search_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildResultPreview(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _glassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _sectionTitle(
                                'إدخال العبارة',
                                Icons.edit_note_rounded,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'اكتب العبارة التي تريد ترجمتها، ثم اضغط على زر الترجمة لعرض الصورة المطابقة',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: muted,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: textController,
                                maxLines: 4,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ink,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'اكتب هنا العبارة',
                                  hintTextDirection: TextDirection.rtl,
                                  alignLabelWithHint: true,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.28),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 18,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      start: 10,
                                      end: 6,
                                    ),
                                    child: Icon(
                                      Icons.short_text_rounded,
                                      color: muted,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                    borderSide: BorderSide(
                                      color: primary,
                                      width: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _translateText,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
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
                                      gradient: const LinearGradient(
                                        colors: [primary, secondary],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(0.22),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isLoading
                                            ? 'جارٍ البحث عن الترجمة'
                                            : 'ترجمة العبارة',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
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
            ),
          ],
        ),
        bottomNavigationBar: _LuxuryBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) {
            _navigateToPage(index);
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
        height: 108,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.84),
              Colors.white.withOpacity(0.68),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.14),
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
                                    colors: [primary, secondary],
                                  )
                                : null,
                            color: isActive
                                ? null
                                : Colors.white.withOpacity(0.40),
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
                            fontSize: 10.4,
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

class _BottomNavItemData {
  final String label;
  final IconData icon;

  const _BottomNavItemData(this.label, this.icon);
}