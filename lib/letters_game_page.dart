import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LettersGamePage extends StatefulWidget {
  const LettersGamePage({super.key});

  @override
  State<LettersGamePage> createState() => _LettersGamePageState();
}

class _LettersGamePageState extends State<LettersGamePage> {
  final Random _random = Random();

  final List<Map<String, String>> _allLetters = [
    {'letter': 'ا', 'asset': 'assets/sign_letters/alef.png'},
    {'letter': 'ب', 'asset': 'assets/sign_letters/baa.png'},
    {'letter': 'ت', 'asset': 'assets/sign_letters/taa.png'},
    {'letter': 'ث', 'asset': 'assets/sign_letters/thaa.png'},
    {'letter': 'ج', 'asset': 'assets/sign_letters/jeem.png'},
    {'letter': 'ح', 'asset': 'assets/sign_letters/haa.png'},
    {'letter': 'خ', 'asset': 'assets/sign_letters/khaa.png'},
    {'letter': 'د', 'asset': 'assets/sign_letters/dal.png'},
    {'letter': 'ذ', 'asset': 'assets/sign_letters/dhal.png'},
    {'letter': 'ر', 'asset': 'assets/sign_letters/raa.png'},
    {'letter': 'ز', 'asset': 'assets/sign_letters/zay.png'},
    {'letter': 'س', 'asset': 'assets/sign_letters/seen.png'},
    {'letter': 'ش', 'asset': 'assets/sign_letters/sheen.png'},
    {'letter': 'ص', 'asset': 'assets/sign_letters/sad.png'},
    {'letter': 'ض', 'asset': 'assets/sign_letters/dad.png'},
    {'letter': 'ط', 'asset': 'assets/sign_letters/tah.png'},
    {'letter': 'ظ', 'asset': 'assets/sign_letters/zah.png'},
    {'letter': 'ع', 'asset': 'assets/sign_letters/ain.png'},
    {'letter': 'غ', 'asset': 'assets/sign_letters/ghain.png'},
    {'letter': 'ف', 'asset': 'assets/sign_letters/fa.png'},
    {'letter': 'ق', 'asset': 'assets/sign_letters/qaf.png'},
    {'letter': 'ك', 'asset': 'assets/sign_letters/kaf.png'},
    {'letter': 'ل', 'asset': 'assets/sign_letters/lam.png'},
    {'letter': 'م', 'asset': 'assets/sign_letters/meem.png'},
    {'letter': 'ن', 'asset': 'assets/sign_letters/noon.png'},
    {'letter': 'ه', 'asset': 'assets/sign_letters/haa2.png'},
    {'letter': 'و', 'asset': 'assets/sign_letters/waw.png'},
    {'letter': 'ي', 'asset': 'assets/sign_letters/yaa.png'},
  ];

  late List<Map<String, String>> _shuffledQuestions;
  int currentQuestion = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;
  late List<String> currentOptions;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _shuffledQuestions = List<Map<String, String>>.from(_allLetters)
      ..shuffle(_random);

    currentQuestion = 0;
    score = 0;
    answered = false;
    selectedAnswer = null;
    currentOptions = _buildOptionsForCurrentQuestion();
    setState(() {});
  }

  List<String> _buildOptionsForCurrentQuestion() {
    final correctLetter = _shuffledQuestions[currentQuestion]['letter']!;
    final allLettersOnly =
        _allLetters.map((item) => item['letter']!).where((l) => l != correctLetter).toList()
          ..shuffle(_random);

    final options = <String>[
      correctLetter,
      ...allLettersOnly.take(2),
    ]..shuffle(_random);

    return options;
  }

  void _answer(String value) {
    if (answered) return;

    final correct = _shuffledQuestions[currentQuestion]['letter']!;

    setState(() {
      selectedAnswer = value;
      answered = true;
      if (value == correct) {
        score++;
      }
    });
  }

  void _next() {
    if (currentQuestion < _shuffledQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        answered = false;
        selectedAnswer = null;
        currentOptions = _buildOptionsForCurrentQuestion();
      });
    } else {
      _showResultDialog();
    }
  }

  void _resetGame() {
    setState(() {
      _startGame();
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'النتيجة النهائية',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'أحرزت $score من ${_shuffledQuestions.length}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text(
                'إعادة اللعبة',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _optionBackground(String option, String correct) {
    if (!answered) return Colors.white;
    if (option == correct) return const Color(0xff16a34a);
    if (selectedAnswer == option && option != correct) {
      return const Color(0xffdc2626);
    }
    return Colors.white;
  }

  Color _optionTextColor(String option, String correct) {
    if (!answered) return const Color(0xff6d28d9);
    if (option == correct) return Colors.white;
    if (selectedAnswer == option && option != correct) {
      return Colors.white;
    }
    return const Color(0xff6d28d9);
  }

  @override
  Widget build(BuildContext context) {
    final question = _shuffledQuestions[currentQuestion];
    final correct = question['letter']!;
    final progress = (currentQuestion + 1) / _shuffledQuestions.length;

    const primary = Color(0xff7c3aed);
    const secondary = Color(0xff0ea5e9);
    const dark = Color(0xff0f172a);
    const muted = Color(0xff64748b);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffeef3fb),
        appBar: AppBar(
          title: const Text(
            'لعبة الحروف',
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
              child: _glowCircle(220, primary.withOpacity(0.10)),
            ),
            Positioned(
              bottom: -100,
              left: -30,
              child: _glowCircle(200, secondary.withOpacity(0.10)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  children: [
                    _glassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'اختر الحرف الصحيح حسب صورة الإشارة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: dark,
                            ),
                          ),

                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'النقاط: $score',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${currentQuestion + 1} / ${_shuffledQuestions.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: const Color(0xffe5e7eb),
                                    valueColor:
                                        const AlwaysStoppedAnimation(primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _glassCard(
                      child: Column(
                        children: [
                          const Text(
                            'إشارة الحرف',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                colors: [
                                  primary.withOpacity(0.14),
                                  secondary.withOpacity(0.10),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Image.asset(
                                        question['asset']!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) {
                                          return Center(
                                            child: Text(
                                              question['letter']!,
                                              style: const TextStyle(
                                                fontSize: 64,
                                                fontWeight: FontWeight.w900,
                                                color: primary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'اختر الحرف المطابق للإشارة',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.08,
                      ),
                      itemBuilder: (context, index) {
                        final option = currentOptions[index];
                        return ElevatedButton(
                          onPressed: () => _answer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _optionBackground(option, correct),
                            foregroundColor:
                                _optionTextColor(option, correct),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: primary.withOpacity(0.18),
                              ),
                            ),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (answered)
                      _glassCard(
                        child: Row(
                          children: [
                            Icon(
                              selectedAnswer == correct
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              color: selectedAnswer == correct
                                  ? const Color(0xff16a34a)
                                  : const Color(0xffdc2626),
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedAnswer == correct
                                    ? 'إجابة صحيحة، أحسنت'
                                    : 'إجابة غير صحيحة، الحرف الصحيح هو: $correct',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: dark,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetGame,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text(
                              'إعادة',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(
                                color: primary.withOpacity(0.22),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: answered ? _next : null,
                            icon: Icon(
                              currentQuestion == _shuffledQuestions.length - 1
                                  ? Icons.emoji_events_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                            label: Text(
                              currentQuestion == _shuffledQuestions.length - 1
                                  ? 'عرض النتيجة'
                                  : 'السؤال التالي',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              disabledForegroundColor: Colors.grey.shade600,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
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
          width: double.infinity,
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