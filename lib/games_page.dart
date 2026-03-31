import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'system_menu.dart';
import 'text_translation_page.dart';
import 'voice_translation_page.dart';
import 'lessons_page.dart';
import 'letters_game_page.dart';

class GamesPage extends StatefulWidget {
  final String selectedGender;
  final String selectedSkinColor;

  const GamesPage({
    super.key,
    this.selectedGender = 'male',
    this.selectedSkinColor = 'white',
  });

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  int currentIndex = 4;

  final List<Map<String, dynamic>> games = [
    {
      'title': 'لعبة الحروف',
      'subtitle': 'اختر الحرف الصحيح من بين عدة خيارات',
      'icon': Icons.abc_rounded,
      'badge': 'مناسبة للمبتدئين',
    },
    {
      'title': 'لعبة المطابقة',
      'subtitle': 'طابق الكلمة مع الإشارة أو المعنى المناسب',
      'icon': Icons.extension_rounded,
      'badge': 'تفاعلية',
    },
    {
      'title': 'لعبة الترتيب',
      'subtitle': 'رتّب الخطوات أو العناصر حسب التسلسل الصحيح',
      'icon': Icons.view_list_rounded,
      'badge': 'تنمية المهارات',
    },
    {
      'title': 'لعبة الذاكرة',
      'subtitle': 'اكشف البطاقات المتشابهة واختبر قوة ذاكرتك',
      'icon': Icons.psychology_rounded,
      'badge': 'تقوية التذكر',
    },
  ];

  void _openGame(int index) {
    late final Widget page;

    switch (index) {
      case 0:
        page = const LettersGamePage();
        break;
      case 1:
        page = const MatchingGamePage();
        break;
      case 2:
        page = const OrderingGamePage();
        break;
      case 3:
        page = const MemoryGamePage();
        break;
      default:
        page = const LettersGamePage();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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
        page = GamesPage(
          selectedGender: widget.selectedGender,
          selectedSkinColor: widget.selectedSkinColor,
        );
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
            'الألعاب',
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
              top: -90,
              right: -40,
              child: _glowCircle(220, primary.withOpacity(0.11)),
            ),
            Positioned(
              bottom: -100,
              left: -30,
              child: _glowCircle(200, secondary.withOpacity(0.10)),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                    child: _glassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [primary, secondary],
                              ),
                            ),
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'قسم الألعاب التعليمية',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: dark,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'اختر اللعبة المناسبة وابدأ التفاعل والتدريب بطريقة ممتعة',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12.8,
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
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
                      itemCount: games.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return _glassCard(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () => _openGame(index),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      colors: [
                                        primary.withOpacity(0.16),
                                        secondary.withOpacity(0.14),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: -12,
                                        left: -10,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.18),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Icon(
                                          game['icon'] as IconData,
                                          size: 52,
                                          color: const Color(0xff6d28d9),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.90),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            game['badge'] as String,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xff7c3aed),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  game['title'] as String,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: dark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    game['subtitle'] as String,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12.3,
                                      fontWeight: FontWeight.w600,
                                      color: muted,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openGame(index),
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'ابدأ اللعبة',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 13,
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
                        );
                      },
                    ),
                  ),
                ],
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

class MatchingGamePage extends StatefulWidget {
  const MatchingGamePage({super.key});

  @override
  State<MatchingGamePage> createState() => _MatchingGamePageState();
}

class _MatchingGamePageState extends State<MatchingGamePage> {
  final List<Map<String, String>> pairs = [
    {'word': 'سلام', 'match': 'تحية'},
    {'word': 'كتاب', 'match': 'قراءة'},
    {'word': 'مدرسة', 'match': 'تعليم'},
  ];

  int current = 0;
  int score = 0;
  bool answered = false;
  String? selected;

  void _pick(String value) {
    if (answered) return;

    final correct = pairs[current]['match'];
    setState(() {
      selected = value;
      answered = true;
      if (value == correct) score++;
    });
  }

  void _next() {
    if (current < pairs.length - 1) {
      setState(() {
        current++;
        answered = false;
        selected = null;
      });
    } else {
      _showDone();
    }
  }

  void _showDone() {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('أحسنت'),
          content: Text('درجتك $score من ${pairs.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  current = 0;
                  score = 0;
                  answered = false;
                  selected = null;
                });
              },
              child: const Text('إعادة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pair = pairs[current];
    final options = ['تحية', 'قراءة', 'تعليم'];

    return _GameScaffold(
      title: 'لعبة المطابقة',
      subtitle: 'اختر المعنى المناسب',
      child: Column(
        children: [
          _QuestionCard(
            title: 'طابق الكلمة مع المعنى الصحيح',
            bigText: pair['word']!,
          ),
          const SizedBox(height: 18),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _pick(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected == option
                        ? (option == pair['match']
                            ? Colors.green
                            : Colors.red)
                        : Colors.white,
                    foregroundColor:
                        selected == option ? Colors.white : const Color(0xff7c3aed),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: answered ? _next : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                current == pairs.length - 1 ? 'عرض النتيجة' : 'التالي',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderingGamePage extends StatefulWidget {
  const OrderingGamePage({super.key});

  @override
  State<OrderingGamePage> createState() => _OrderingGamePageState();
}

class _OrderingGamePageState extends State<OrderingGamePage> {
  final List<String> correctOrder = ['استماع', 'فهم', 'إجابة'];
  late List<String> shuffled;

  @override
  void initState() {
    super.initState();
    shuffled = List<String>.from(correctOrder)..shuffle();
  }

  void _checkOrder() {
    final success = _listEquals(shuffled, correctOrder);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'الترتيب صحيح' : 'الترتيب غير صحيح، حاول مرة أخرى'),
      ),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      title: 'لعبة الترتيب',
      subtitle: 'رتّب العناصر بالسحب والإفلات',
      child: Column(
        children: [
          const _QuestionCard(
            title: 'رتّب الخطوات بالتسلسل الصحيح',
            bigText: 'اسحب البطاقات',
          ),
          const SizedBox(height: 18),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = shuffled.removeAt(oldIndex);
                shuffled.insert(newIndex, item);
              });
            },
            children: [
              for (int i = 0; i < shuffled.length; i++)
                Container(
                  key: ValueKey(shuffled[i]),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    title: Text(
                      shuffled[i],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    leading: const Icon(Icons.drag_handle_rounded),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _checkOrder,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('تحقق من الترتيب'),
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  late List<_MemoryCard> cards;
  int? firstIndex;
  bool waiting = false;

  @override
  void initState() {
    super.initState();
    _setupCards();
  }

  void _setupCards() {
    final values = ['أ', 'ب', 'ت', 'ث'];
    cards = [...values, ...values]
        .map((e) => _MemoryCard(value: e))
        .toList()
      ..shuffle(Random());
  }

  void _tapCard(int index) {
    if (waiting || cards[index].isMatched || cards[index].isOpen) return;

    setState(() {
      cards[index].isOpen = true;
    });

    if (firstIndex == null) {
      firstIndex = index;
      return;
    }

    final secondIndex = index;
    final first = firstIndex!;

    if (cards[first].value == cards[secondIndex].value) {
      setState(() {
        cards[first].isMatched = true;
        cards[secondIndex].isMatched = true;
      });
      firstIndex = null;

      if (cards.every((e) => e.isMatched)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('ممتاز'),
                content: const Text('أنهيت لعبة الذاكرة بنجاح'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        firstIndex = null;
                        _setupCards();
                      });
                    },
                    child: const Text('إعادة'),
                  ),
                ],
              ),
            ),
          );
        });
      }
    } else {
      waiting = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          cards[first].isOpen = false;
          cards[secondIndex].isOpen = false;
          waiting = false;
          firstIndex = null;
        });
      });
      return;
    }

    firstIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return _GameScaffold(
      title: 'لعبة الذاكرة',
      subtitle: 'اكشف البطاقات المتشابهة',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final card = cards[index];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _tapCard(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: card.isOpen || card.isMatched
                      ? [const Color(0xff7c3aed), const Color(0xff0ea5e9)]
                      : [Colors.white, Colors.white],
                ),
              ),
              child: Center(
                child: Text(
                  card.isOpen || card.isMatched ? card.value : '?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: card.isOpen || card.isMatched
                        ? Colors.white
                        : const Color(0xff7c3aed),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MemoryCard {
  final String value;
  bool isOpen;
  bool isMatched;

  _MemoryCard({
    required this.value,
    this.isOpen = false,
    this.isMatched = false,
  });
}

class _GameScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _GameScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);
    const primary = Color(0xff7c3aed);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffeef3fb),
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: dark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.86),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
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
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.90),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String title;
  final String bigText;

  const _QuestionCard({
    required this.title,
    required this.bigText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xff7c3aed).withOpacity(0.12),
            const Color(0xff0ea5e9).withOpacity(0.10),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bigText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xff0f172a),
            ),
          ),
        ],
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