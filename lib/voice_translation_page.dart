import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'system_menu.dart';
import 'text_translation_page.dart';
import 'lessons_page.dart';
import 'games_page.dart';

class VoiceTranslationPage extends StatefulWidget {
  final String selectedGender;
  final String selectedSkinColor;

  const VoiceTranslationPage({
    super.key,
    required this.selectedGender,
    required this.selectedSkinColor,
  });

  @override
  State<VoiceTranslationPage> createState() => _VoiceTranslationPageState();
}

class _VoiceTranslationPageState extends State<VoiceTranslationPage> {
  static const String _genderKey = 'character_gender';
  static const String _skinKey = 'character_skin';

  static const String baseUrl =
      'https://swisse.ly/isharatna_laravel_project/public/index.php/api';

  static const Duration _requestTimeout = Duration(seconds: 25);

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechReady = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isCharacterLoading = true;
  bool _isAutoTranslating = false;

  String fixedGender = 'male';
  String fixedSkinColor = 'white';

  String _recognizedText = '';
  String? _resultMessage;
  String? _resultMediaPath;
  Uint8List? _resultImageBytes;
  String? _speechStatusMessage;

  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadFixedCharacter();
    _initSpeech();
  }

  Future<void> _loadFixedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getString(_genderKey);
    final savedSkin = prefs.getString(_skinKey);

    if (!mounted) return;

    setState(() {
      fixedGender = savedGender ?? widget.selectedGender;
      fixedSkinColor = savedSkin ?? widget.selectedSkinColor;
      _isCharacterLoading = false;
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

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) async {
          debugPrint('SPEECH STATUS: $status');

          if (!mounted) return;

          setState(() {
            if (status == 'listening') {
              _speechStatusMessage = 'يتم الآن الاستماع إلى الصوت';
            } else if (status == 'done') {
              _speechStatusMessage = 'تم انتهاء التسجيل، جارٍ تحليل العبارة';
            } else if (status == 'notListening') {
              _speechStatusMessage = 'خدمة التعرف على الصوت جاهزة';
            }
          });

          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }

            if (!_isAutoTranslating &&
                _recognizedText.trim().isNotEmpty &&
                !_isLoading) {
              _isAutoTranslating = true;
              await _translateRecognizedText();
              _isAutoTranslating = false;
            }
          }
        },
        onError: (error) {
          debugPrint('SPEECH ERROR: $error');

          if (!mounted) return;

          setState(() {
            _isListening = false;
            _speechStatusMessage = 'تعذر التعرف على الصوت: ${error.errorMsg}';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ في التعرف على الصوت: ${error.errorMsg}'),
            ),
          );
        },
        debugLogging: true,
      );

      if (!mounted) return;

      setState(() {
        _speechReady = available;
        _speechStatusMessage = available
            ? 'خدمة التعرف على الصوت جاهزة'
            : 'خدمة التعرف على الصوت غير متاحة على هذا الجهاز';
      });
    } catch (e) {
      debugPrint('INIT SPEECH ERROR: $e');

      if (!mounted) return;

      setState(() {
        _speechReady = false;
        _speechStatusMessage = 'تعذر تهيئة خدمة التعرف على الصوت';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تهيئة التعرف على الصوت')),
      );
    }
  }

  Future<void> _startListening() async {
    if (_isCharacterLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جارٍ تحميل الشخصية المعتمدة')),
      );
      return;
    }

    if (!_speechReady || _isListening) {
      if (!_speechReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة التعرف على الصوت غير جاهزة')),
        );
      }
      return;
    }

    setState(() {
      _recognizedText = '';
      _resultMessage = null;
      _resultMediaPath = null;
      _resultImageBytes = null;
      _isListening = true;
      _speechStatusMessage = 'ابدأ التحدث الآن';
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _recognizedText = result.recognizedWords.trim();
          });
        },
        localeId: 'ar-SA',
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('START LISTEN ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isListening = false;
        _speechStatusMessage = 'فشل بدء التسجيل الصوتي';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل بدء التسجيل الصوتي')),
      );
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _speechStatusMessage = 'تم إيقاف التسجيل، جارٍ تحليل العبارة والبحث عنها';
    });

    if (_recognizedText.trim().isNotEmpty) {
      await _translateRecognizedText();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم التقاط عبارة واضحة، حاول مرة أخرى')),
      );
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

    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.contains('/public/index.php/public/storage/')) {
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

      return 'https://swisse.ly/isharatna_laravel_project/storage/app/public/$normalizedPath';
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

      debugPrint('VOICE IMAGE DOWNLOAD STATUS: ${response.statusCode}');
      debugPrint('VOICE IMAGE DOWNLOAD URL: $url');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }

      return null;
    } on TimeoutException {
      debugPrint('VOICE IMAGE DOWNLOAD TIMEOUT: $url');
      return null;
    } catch (e) {
      debugPrint('VOICE IMAGE DOWNLOAD ERROR: $e');
      return null;
    }
  }

  Future<void> _translateRecognizedText() async {
    final text = _recognizedText.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد عبارة لتحليلها والبحث عنها')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = 'جارٍ تحليل العبارة الصوتية والبحث عنها';
      _resultMediaPath = null;
      _resultImageBytes = null;
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

      debugPrint('VOICE RECOGNIZED TEXT: $text');
      debugPrint('VOICE TRANSLATE STATUS: ${response.statusCode}');
      debugPrint('VOICE TRANSLATE BODY: ${response.body}');
      debugPrint('VOICE FIXED GENDER: $fixedGender');
      debugPrint('VOICE FIXED SKIN: $fixedSkinColor');

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          data['status']?.toString() == 'success') {
        final phrase = data['data'] is Map
            ? Map<String, dynamic>.from(data['data'] as Map)
            : null;

        final finalUrl = _buildFinalImageUrl(phrase);

        debugPrint('VOICE IMAGE_URL_FROM_API: ${phrase?['image_url']}');
        debugPrint('VOICE IMAGE_PATH_FROM_API: ${phrase?['image_path']}');
        debugPrint('VOICE FINAL_IMAGE_URL: $finalUrl');

        Uint8List? downloadedBytes;
        if (finalUrl != null && finalUrl.isNotEmpty) {
          downloadedBytes = await _downloadImageBytes(finalUrl);
        }

        setState(() {
          _resultMediaPath = finalUrl;
          _resultImageBytes = downloadedBytes;

          if (downloadedBytes != null && downloadedBytes.isNotEmpty) {
            _resultMessage =
                'تم التقاط العبارة الصوتية وتحليلها ثم عرض الصورة المطابقة بنجاح';
          } else if (finalUrl != null && finalUrl.isNotEmpty) {
            _resultMessage = 'تم العثور على العبارة لكن تعذر تحميل الصورة من الرابط';
          } else {
            _resultMessage =
                'تم العثور على العبارة لكن لا يوجد رابط صورة صالح في الاستجابة';
          }
        });
      } else {
        setState(() {
          _resultMediaPath = null;
          _resultImageBytes = null;
          _resultMessage = data['message']?.toString() ??
              'لم يتم العثور على صورة مطابقة بعد تحليل العبارة';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_resultMessage!)),
        );
      }
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _resultMediaPath = null;
        _resultImageBytes = null;
        _resultMessage = 'انتهت مهلة الاتصال بالخادم أثناء تحليل العبارة';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتهت مهلة الاتصال بالخادم')),
      );
    } catch (e) {
      debugPrint('VOICE TRANSLATE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _resultMediaPath = null;
        _resultImageBytes = null;
        _resultMessage = 'تعذر الاتصال بالخادم';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الاتصال بالخادم')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPage(int index) {
    if (index == currentIndex) return;

    late final Widget page;

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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
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
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withOpacity(0.30),
                Colors.white.withOpacity(0.16),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget _glowCircle(double size, Color color) {
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
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_resultImageBytes != null && _resultImageBytes!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 290),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
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
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.memory(
                  _resultImageBytes!,
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _resultMessage ?? 'تم العثور على العبارة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xff475569),
            ),
          ),
        ],
      );
    }

    if (_resultMediaPath != null && _resultMediaPath!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 290),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
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
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  _resultMediaPath!,
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 260,
                      height: 260,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildBrokenPreview(_resultMediaPath);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _resultMessage ?? 'تم العثور على العبارة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xff475569),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 290),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
      child: Center(
        child: Image.asset(
          _characterImagePath,
          width: 230,
          height: 230,
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
    );
  }

  @override
  void dispose() {
    _speech.stop();
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [primary, secondary],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'الترجمة الصوتية',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: ink,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const Text(
                                    'الشخصية المعتمدة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: ink,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: [primary, secondary],
                                      ),
                                    ),
                                    child: Text(
                                      _previewLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'المعاينة',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: ink,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              _buildResultPreview(),
                              const SizedBox(height: 22),
                              Center(
                                child: GestureDetector(
                                  onTap: _speechReady
                                      ? (_isListening
                                          ? _stopListening
                                          : _startListening)
                                      : _initSpeech,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: _isListening
                                            ? const [
                                                Color(0xffef4444),
                                                Color(0xfff97316),
                                              ]
                                            : const [primary, secondary],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isListening
                                                  ? const Color(0xffef4444)
                                                  : primary)
                                              .withOpacity(0.30),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      !_speechReady
                                          ? Icons.refresh_rounded
                                          : _isListening
                                              ? Icons.stop_rounded
                                              : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: Text(
                                  !_speechReady
                                      ? 'اضغط لإعادة تهيئة خدمة الصوت'
                                      : _isListening
                                          ? 'يتم الآن الاستماع، اضغط للإيقاف ثم تحليل العبارة'
                                          : 'اضغط لبدء التسجيل الصوتي',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff64748b),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_speechStatusMessage != null)
                                Center(
                                  child: Text(
                                    _speechStatusMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff64748b),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'النص الملتقط',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.white.withOpacity(0.24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.40),
                                  ),
                                ),
                                child: Text(
                                  _recognizedText.isEmpty
                                      ? 'سيتحول الكلام الملتقط إلى عبارة هنا قبل تنفيذ البحث'
                                      : _recognizedText,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _recognizedText.isEmpty
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color:
                                        _recognizedText.isEmpty ? muted : ink,
                                    height: 1.8,
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
            if (index == currentIndex) return;
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