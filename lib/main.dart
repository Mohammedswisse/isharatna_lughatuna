import 'dart:async';
import 'package:flutter/material.dart';
import 'admin_login_page.dart';
import 'system_menu.dart';

void main() {
  runApp(const IsharatnaApp());
}

class IsharatnaApp extends StatelessWidget {
  const IsharatnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'إشارتنا، لغتنا',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Almarai',
          scaffoldBackgroundColor: const Color(0xfff4f7fb),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff4f46e5),
            brightness: Brightness.light,
          ),
        ),
        home: const SplashLoadingPage(),
      ),
    );
  }
}

class SplashLoadingPage extends StatefulWidget {
  const SplashLoadingPage({super.key});

  @override
  State<SplashLoadingPage> createState() => _SplashLoadingPageState();
}

class _SplashLoadingPageState extends State<SplashLoadingPage>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    const totalDuration = Duration(seconds: 3);
    const stepDuration = Duration(milliseconds: 60);
    const totalSteps = 3000 ~/ 60;

    int currentStep = 0;

    _timer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          progress = currentStep / totalSteps;
        });
      }

      if (currentStep >= totalSteps) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: const LandingPage(),
              ),
            ),
          );
        });
      }
    });

    Future.delayed(totalDuration);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffeef2ff),
                  Color(0xfff8fafc),
                  Color(0xffe0e7ff),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff6366f1).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff8b5cf6).withOpacity(0.10),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff4f46e5),
                              Color(0xff7c3aed),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff4f46e5).withOpacity(0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sign_language_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'إشارتنا، لغتنا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff0f172a),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'جاري تجهيز النظام وتهيئة تجربة ترجمة احترافية لك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: Color(0xff64748b),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: const Color(0xffe2e8f0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xff4f46e5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff4f46e5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffeef2ff),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'يرجى الانتظار قليلاً...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff4338ca),
                          ),
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
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int currentIndex = 1;

  void onTapNav(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminLoginPage(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SystemMenuPage(),
        ),
      );
      return;
    }

    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم فتح صفحة المعلومات',
            style: TextStyle(fontFamily: 'Almarai'),
            textAlign: TextAlign.right,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffeef2ff),
                    Color(0xfff8fafc),
                    Color(0xffe0e7ff),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff6366f1).withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff8b5cf6).withOpacity(0.10),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 140,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff4f46e5),
                                      Color(0xff7c3aed),
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff4f46e5)
                                          .withOpacity(0.28),
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sign_language_rounded,
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff0f172a),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'نظام ذكي لترجمة الليبية إلى لغة الإشارة',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff64748b),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Colors.white.withOpacity(0.72),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.9),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff4f46e5),
                                          Color(0xff7c3aed),
                                        ],
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff4f46e5)
                                              .withOpacity(0.35),
                                          blurRadius: 28,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.gesture_rounded,
                                      size: 46,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'ابدأ رحلتك مع الترجمة الذكية',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xff0f172a),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'بوابتك الحديثة إلى ترجمة لغة الإشارة الليبية، لتمنحك تواصلاً أسهل وأكثر قرباً مع فئات الصم، عبر تجربة تجمع السهولة والمرونة والخدمات المتكاملة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff64748b),
                                    height: 1.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Expanded(
                                      child: _infoMiniCard(
                                        icon: Icons.translate_rounded,
                                        title: 'ترجمة فورية',
                                        subtitle: 'نصوص وعبارات',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _infoMiniCard(
                                        icon: Icons.admin_panel_settings_rounded,
                                        title: 'إدارة ذكية',
                                        subtitle: 'تحكم كامل',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _ModernBottomBar(
          currentIndex: currentIndex,
          onTap: onTapNav,
        ),
      ),
    );
  }

  Widget _infoMiniCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xfff8fafc),
        border: Border.all(
          color: const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xffeef2ff),
            ),
            child: Icon(
              icon,
              color: const Color(0xff4f46e5),
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xff0f172a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff64748b),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ModernBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 86,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _NavItem(
                        label: 'معلومات',
                        icon: Icons.info_outline_rounded,
                        active: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                    ),
                    const SizedBox(width: 72),
                    Expanded(
                      child: _NavItem(
                        label: 'الإدارة',
                        icon: Icons.admin_panel_settings_outlined,
                        active: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -8,
              child: GestureDetector(
                onTap: () => onTap(1),
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff4f46e5),
                        Color(0xff7c3aed),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff4f46e5).withOpacity(0.38),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ابدأ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xff4f46e5);
    final Color inactiveColor = const Color(0xff94a3b8);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}