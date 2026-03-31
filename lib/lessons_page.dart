import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'services/api_service.dart';
import 'config/api_config.dart';
import 'system_menu.dart';
import 'text_translation_page.dart';
import 'voice_translation_page.dart';
import 'games_page.dart';

class LessonsPage extends StatefulWidget {
  final String selectedGender;
  final String selectedSkinColor;

  const LessonsPage({
    super.key,
    this.selectedGender = 'male',
    this.selectedSkinColor = 'white',
  });

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  late Future<List<Map<String, dynamic>>> _lessonsFuture;
  int currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() {
    setState(() {
      _lessonsFuture = ApiService.getLessons();
    });
  }

  String _titleOf(Map<String, dynamic> lesson) {
    return (lesson['title'] ?? '').toString().trim();
  }

  String _contentOf(Map<String, dynamic> lesson) {
    return (lesson['content'] ?? '').toString().trim();
  }

  String _forceHttps(String value) {
    final text = value.trim();
    if (text.startsWith('http://')) {
      return text.replaceFirst('http://', 'https://');
    }
    return text;
  }

  String _publicStorageBase() {
    var base = ApiConfig.baseUrl.trim();

    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    base = base.replaceFirst('/index.php/api', '');
    base = base.replaceFirst('/api', '');

    return '$base/storage';
  }

  String _videoUrlOf(Map<String, dynamic> lesson) {
    final streamUrl = (lesson['stream_url'] ?? '').toString().trim();
    final videoUrl = (lesson['video_url'] ?? '').toString().trim();
    final videoPath = (lesson['video_path'] ?? '').toString().trim();

    if (streamUrl.isNotEmpty) {
      return _forceHttps(streamUrl);
    }

    if (videoUrl.isNotEmpty) {
      return _forceHttps(videoUrl);
    }

    if (videoPath.isNotEmpty) {
      String normalizedPath = videoPath;

      if (normalizedPath.startsWith('/')) {
        normalizedPath = normalizedPath.substring(1);
      }

      if (normalizedPath.startsWith('storage/')) {
        normalizedPath = normalizedPath.substring(8);
      }

      return '${_publicStorageBase()}/$normalizedPath';
    }

    return '';
  }

  String _shortText(String value, {int maxLength = 140}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  bool _isPlayableVideoUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('https://') || url.startsWith('http://');
  }

  Future<void> _openVideo({
    required String title,
    required String videoUrl,
  }) async {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رابط فيديو لهذا الدرس'),
        ),
      );
      return;
    }

    if (!_isPlayableVideoUrl(videoUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('رابط الفيديو غير صالح:\n$videoUrl'),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonVideoPlayerPage(
          title: title.isEmpty ? 'مشاهدة الدرس' : title,
          videoUrl: videoUrl,
        ),
      ),
    );
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
          selectedGender: widget.selectedGender,
          selectedSkinColor: widget.selectedSkinColor,
        );
        break;
      case 2:
        page = VoiceTranslationPage(
          selectedGender: widget.selectedGender,
          selectedSkinColor: widget.selectedSkinColor,
        );
        break;
      case 3:
        page = LessonsPage(
          selectedGender: widget.selectedGender,
          selectedSkinColor: widget.selectedSkinColor,
        );
        break;
      case 4:
        page = const GamesPage();
        break;
      default:
        page = const SystemMenuPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff7c3aed);
    const secondary = Color(0xff0ea5e9);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffeef3fb),
        extendBody: true,
        appBar: AppBar(
          title: const Text(
            'الدروس',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: dark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff8fbff), Color(0xffeef3fb)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -40,
              child: _glowCircle(
                220,
                primary.withOpacity(0.10),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -30,
              child: _glowCircle(
                200,
                secondary.withOpacity(0.09),
              ),
            ),
            SafeArea(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _lessonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 44,
                              color: Color(0xffdc2626),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'حدث خطأ أثناء تحميل الدروس\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xffdc2626),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadLessons,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final lessons = snapshot.data ?? [];

                  if (lessons.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 22),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white.withOpacity(0.90),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withOpacity(0.10),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                size: 34,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد دروس متاحة حاليًا',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: dark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'سيتم عرض الدروس المضافة من لوحة التحكم هنا مباشرةً',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: muted,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadLessons();
                      await _lessonsFuture;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final title = _titleOf(lesson);
                        final content = _contentOf(lesson);
                        final videoUrl = _videoUrlOf(lesson);
                        final hasVideo = videoUrl.isNotEmpty;

                        return _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [primary, secondary],
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.ondemand_video_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          title.isEmpty
                                              ? 'درس بدون عنوان'
                                              : title,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: dark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          content.isEmpty
                                              ? 'لا يوجد وصف لهذا الدرس'
                                              : _shortText(content),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: muted,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (hasVideo)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xfff8fafc),
                                    border: Border.all(
                                      color: const Color(0xffe2e8f0),
                                    ),
                                  ),
                                  child: Text(
                                    videoUrl,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                              ),
                                              title: Text(
                                                title.isEmpty
                                                    ? 'تفاصيل الدرس'
                                                    : title,
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Text(
                                                  content.isEmpty
                                                      ? 'لا يوجد محتوى لهذا الدرس'
                                                      : content,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    height: 1.8,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.info_outline_rounded,
                                      ),
                                      label: const Text(
                                        'تفاصيل',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primary,
                                        side: BorderSide(
                                          color: primary.withOpacity(0.22),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: hasVideo
                                          ? () => _openVideo(
                                                title: title,
                                                videoUrl: videoUrl,
                                              )
                                          : () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'لا يوجد فيديو متاح لهذا الدرس',
                                                  ),
                                                ),
                                              );
                                            },
                                      icon: Icon(
                                        hasVideo
                                            ? Icons.play_circle_fill_rounded
                                            : Icons.block_rounded,
                                      ),
                                      label: Text(
                                        hasVideo ? 'مشاهدة' : 'غير متاح',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            hasVideo ? primary : Colors.grey,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _LuxuryBottomNavBar(
          currentIndex: currentIndex,
          onTap: _navigateToPage,
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

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.30),
                Colors.white.withOpacity(0.15),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.42)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
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
      ('الدروس', Icons.menu_book_rounded),
      ('الألعاب', Icons.sports_esports_rounded),
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

class LessonVideoPlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const LessonVideoPlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<LessonVideoPlayerPage> createState() => _LessonVideoPlayerPageState();
}

class _LessonVideoPlayerPageState extends State<LessonVideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isReady) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _isReady && _controller.value.isPlaying;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff0f172a),
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio:
                            _isReady ? _controller.value.aspectRatio : (16 / 9),
                        child: _errorMessage != null
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'تعذر تحميل الفيديو',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableText(
                                      widget.videoUrl,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SelectableText(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : !_isReady
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isReady
                          ? () {
                              _controller.seekTo(Duration.zero);
                              _controller.play();
                              setState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text(
                        'إعادة',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isReady ? _togglePlayPause : null,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                      ),
                      label: Text(
                        isPlaying ? 'إيقاف' : 'تشغيل',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7c3aed),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}