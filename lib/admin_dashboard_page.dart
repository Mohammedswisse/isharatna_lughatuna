import 'package:flutter/material.dart';
import 'admin_phrases_page.dart';
import 'admin_lessons_page.dart';
import 'admin_profile_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;

  const AdminDashboardPage({
    super.key,
    required this.adminId,
    required this.adminName,
    this.phrasesCount = 0,
    this.lessonsCount = 0,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int currentIndex = 0;

  void _onNavTap(int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      setState(() {
        currentIndex = 0;
      });
      return;
    }

    late Widget page;

    switch (index) {
      case 1:
        page = AdminPhrasesPage(
          adminId: widget.adminId,
          adminName: widget.adminName,
          phrasesCount: widget.phrasesCount,
          lessonsCount: widget.lessonsCount,
        );
        break;

      case 2:
        page = AdminLessonsPage(
          adminId: widget.adminId,
          adminName: widget.adminName,
          phrasesCount: widget.phrasesCount,
          lessonsCount: widget.lessonsCount,
        );
        break;

      case 3:
        page = AdminProfilePage(
          adminId: widget.adminId,
          adminName: widget.adminName,
          phrasesCount: widget.phrasesCount,
          lessonsCount: widget.lessonsCount,
        );
        break;

      default:
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

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const secondary = Color(0xff7c3aed);
    const accent = Color(0xff06b6d4);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const danger = Color(0xffdc2626);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Almarai',
                bodyColor: dark,
                displayColor: dark,
              ),
        ),
        child: Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xffeef2ff),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffeef2ff),
                      Color(0xfff8fafc),
                      Color(0xffede9fe),
                      Color(0xffecfeff),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
              Positioned(
                top: -90,
                right: -50,
                child: _blurCircle(
                  size: 240,
                  color: primary.withOpacity(0.14),
                ),
              ),
              Positioned(
                top: 220,
                left: -70,
                child: _blurCircle(
                  size: 190,
                  color: accent.withOpacity(0.12),
                ),
              ),
              Positioned(
                bottom: 150,
                right: -50,
                child: _blurCircle(
                  size: 210,
                  color: secondary.withOpacity(0.12),
                ),
              ),
              Positioned(
                bottom: 260,
                left: 30,
                child: _blurCircle(
                  size: 110,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.96),
                              Colors.white.withOpacity(0.86),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.95),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
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
                                          color: primary.withOpacity(0.30),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.front_hand_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'إشارتنا، لغتنا',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                            color: primary,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'لوحة تحكم الإدارة',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 25,
                                            fontWeight: FontWeight.w800,
                                            color: dark,
                                            height: 1.15,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'مرحباً ${widget.adminName}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: muted,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'المعرف: ${widget.adminId}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'Almarai',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xfffff1f2),
                                      Color(0xffffe4e6),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xfffecdd3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: danger.withOpacity(0.12),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: danger,
                                      size: 22,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'خروج',
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        color: danger,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.95),
                              secondary.withOpacity(0.92),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.26),
                              blurRadius: 28,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                ),
                              ),
                              child: const Icon(
                                Icons.dashboard_customize_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'إدارة التطبيق',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'تحكم كامل في العبارات والدروس والملف الشخصي',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      color: Color(0xffe0e7ff),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _PremiumStatCard(
                              title: 'عدد العبارات',
                              value: '${widget.phrasesCount}',
                              icon: Icons.translate_rounded,
                              color1: const Color(0xff4f46e5),
                              color2: const Color(0xff6366f1),
                              glowColor: const Color(0xff4f46e5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _PremiumStatCard(
                              title: 'عدد الدروس',
                              value: '${widget.lessonsCount}',
                              icon: Icons.ondemand_video_rounded,
                              color1: const Color(0xff7c3aed),
                              color2: const Color(0xff8b5cf6),
                              glowColor: const Color(0xff7c3aed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: _HomeSection(
                          adminId: widget.adminId,
                          adminName: widget.adminName,
                          phrasesCount: widget.phrasesCount,
                          lessonsCount: widget.lessonsCount,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _LuxuryBottomBar(
            currentIndex: currentIndex,
            onTap: _onNavTap,
          ),
        ),
      ),
    );
  }

  Widget _blurCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;
  final Color glowColor;

  const _PremiumStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.97),
            Colors.white.withOpacity(0.89),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: dark,
                    height: 1.0,
                  ),
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [color1, color2],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                color: muted,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
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

class _HomeSection extends StatelessWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;

  const _HomeSection({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.phrasesCount,
    required this.lessonsCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('home-section-content'),
      physics: const BouncingScrollPhysics(),
      children: [
        const _ActionCard(
          title: 'إدارة العبارات',
          subtitle: 'إضافة وتعديل ومراجعة العبارات المرتبطة بالصور والإشارات',
          icon: Icons.translate_rounded,
          c1: Color(0xff4f46e5),
          c2: Color(0xff6366f1),
        ),
        const SizedBox(height: 16),
        const _ActionCard(
          title: 'إدارة الدروس',
          subtitle: 'تنظيم الدروس التعليمية وعرض المحتوى بشكل مرتب وجذاب',
          icon: Icons.ondemand_video_rounded,
          c1: Color(0xff7c3aed),
          c2: Color(0xff8b5cf6),
        ),
        const SizedBox(height: 16),
        const _ActionCard(
          title: 'الملف الشخصي',
          subtitle: 'متابعة معلومات الحساب والتحكم في إعدادات الإدارة',
          icon: Icons.person_rounded,
          c1: Color(0xff0891b2),
          c2: Color(0xff06b6d4),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.97),
                Colors.white.withOpacity(0.90),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: Colors.white,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff4f46e5).withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'ملخص سريع',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0f172a),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'المعرف: $adminId',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff64748b),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'المدير: $adminName',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff64748b),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'إجمالي العبارات: $phrasesCount',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff64748b),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'إجمالي الدروس: $lessonsCount',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff64748b),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color c1;
  final Color c2;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.c1,
    required this.c2,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.97),
            Colors.white.withOpacity(0.90),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: dark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12.5,
                    height: 1.6,
                    color: muted,
                    fontWeight: FontWeight.w600,
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