import 'package:flutter/material.dart';
import 'models/phrase_model.dart';
import 'services/api_service.dart';
import 'admin_add_phrase_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_lessons_page.dart';
import 'admin_profile_page.dart';

class AdminPhrasesPage extends StatefulWidget {
  final int adminId;
  final String adminName;
  final int phrasesCount;
  final int lessonsCount;

  const AdminPhrasesPage({
    super.key,
    required this.adminId,
    required this.adminName,
    this.phrasesCount = 0,
    this.lessonsCount = 0,
  });

  @override
  State<AdminPhrasesPage> createState() => _AdminPhrasesPageState();
}

class _AdminPhrasesPageState extends State<AdminPhrasesPage> {
  late Future<List<PhraseModel>> _phrasesFuture;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  void _loadPhrases() {
    setState(() {
      _phrasesFuture = ApiService.getPhrases();
    });
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
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  Future<void> _deletePhrase(int id) async {
    final result = await ApiService.deletePhrase(id);

    if (!mounted) return;

    final bool success = result['success'] == true;
    final String message = result['message']?.toString() ??
        (success ? 'تم حذف العبارة بنجاح' : 'تعذر حذف العبارة');

    if (success) {
      _loadPhrases();
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
  }

  Future<void> _openAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAddPhrasePage(
          adminId: widget.adminId,
          adminName: widget.adminName,
          phrasesCount: widget.phrasesCount,
          lessonsCount: widget.lessonsCount,
        ),
      ),
    );

    if (result == true) {
      _loadPhrases();
    }
  }

  Future<void> _openEditPage(PhraseModel phrase) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminAddPhrasePage(
          adminId: widget.adminId,
          adminName: widget.adminName,
          phrasesCount: widget.phrasesCount,
          lessonsCount: widget.lessonsCount,
          phrase: {
            'id': phrase.id,
            'text': phrase.text,
            'gender': phrase.gender,
            'skin_color': phrase.skinColor,
            'type': phrase.type,
            'image_path': phrase.imagePath,
          },
        ),
      ),
    );

    if (result == true) {
      _loadPhrases();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff4f46e5);
    const secondary = Color(0xff7c3aed);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const danger = Color(0xffdc2626);
    const successColor = Color(0xff16a34a);

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
          backgroundColor: const Color(0xffeef2ff),
          extendBody: true,
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
                top: -80,
                right: -40,
                child: _blurCircle(
                  size: 220,
                  color: primary.withOpacity(0.12),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -50,
                child: _blurCircle(
                  size: 180,
                  color: secondary.withOpacity(0.10),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 108),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
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
                              width: 1.3,
                            ),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'إدارة العبارات',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: dark,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'عرض العبارات المضافة وتعديلها أو حذفها بسهولة',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: muted,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'المدير: ${widget.adminName} | المعرف: ${widget.adminId}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    colors: [primary, secondary],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.translate_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.white.withOpacity(0.88),
                                  border: Border.all(color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FutureBuilder<List<PhraseModel>>(
                                  future: _phrasesFuture,
                                  builder: (context, snapshot) {
                                    final count = snapshot.data?.length ?? 0;

                                    return Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: primary.withOpacity(0.10),
                                          ),
                                          child: const Icon(
                                            Icons.sort_by_alpha_rounded,
                                            color: primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'عدد العبارات',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontFamily: 'Almarai',
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: muted,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$count',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontFamily: 'Almarai',
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w800,
                                                  color: dark,
                                                  height: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: _openAddPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [primary, secondary],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.24),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'إضافة',
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: FutureBuilder<List<PhraseModel>>(
                          future: _phrasesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'حدث خطأ أثناء تحميل العبارات',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: danger,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final phrases = snapshot.data ?? [];

                            if (phrases.isEmpty) {
                              return Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 22),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: Colors.white.withOpacity(0.90),
                                    border: Border.all(color: Colors.white),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
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
                                          Icons.translate_rounded,
                                          size: 34,
                                          color: primary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'لا توجد عبارات مضافة حتى الآن',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: dark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'ابدأ الآن بإضافة أول عبارة لتظهر هنا على هيئة بطاقات',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: muted,
                                          height: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ElevatedButton.icon(
                                        onPressed: _openAddPage,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add_rounded),
                                        label: const Text(
                                          'إضافة عبارة',
                                          style: TextStyle(
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                _loadPhrases();
                                await _phrasesFuture;
                              },
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 4, 18, 24),
                                itemCount: phrases.length,
                                itemBuilder: (context, index) {
                                  final phrase = phrases[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(26),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.97),
                                          Colors.white.withOpacity(0.91),
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
                                          color: primary.withOpacity(0.08),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 54,
                                              height: 54,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                gradient: const LinearGradient(
                                                  colors: [primary, secondary],
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.translate_rounded,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    phrase.text.isEmpty
                                                        ? 'بدون نص'
                                                        : phrase.text,
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontFamily: 'Almarai',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: dark,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    alignment:
                                                        WrapAlignment.end,
                                                    children: [
                                                      _InfoChip(
                                                        label:
                                                            'الجنس: ${phrase.gender}',
                                                        color: primary,
                                                      ),
                                                      _InfoChip(
                                                        label:
                                                            'اللون: ${phrase.skinColor}',
                                                        color: successColor,
                                                      ),
                                                      _InfoChip(
                                                        label:
                                                            'النوع: ${phrase.type ?? ''}',
                                                        color: secondary,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((phrase.imagePath ?? '').isNotEmpty) ...[
                                          const SizedBox(height: 14),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: const Color(0xfff8fafc),
                                              border: Border.all(
                                                color: const Color(0xffe2e8f0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.folder_open_rounded,
                                                  color: muted,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    phrase.imagePath ?? '',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontFamily: 'Almarai',
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: muted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _openEditPage(phrase),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: primary,
                                                  side: BorderSide(
                                                    color: primary
                                                        .withOpacity(0.25),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 13,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.edit_rounded,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'تعديل',
                                                  style: TextStyle(
                                                    fontFamily: 'Almarai',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _showDeleteDialog(
                                                  id: phrase.id,
                                                  text: phrase.text,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: danger
                                                      .withOpacity(0.10),
                                                  foregroundColor: danger,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 13,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.delete_rounded,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  'حذف',
                                                  style: TextStyle(
                                                    fontFamily: 'Almarai',
                                                    fontWeight: FontWeight.w800,
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

  Future<void> _showDeleteDialog({
    required int id,
    required String text,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'هل تريد حذف العبارة:\n"$text" ؟',
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deletePhrase(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffdc2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.10),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
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
        height: 116,
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