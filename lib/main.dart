import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
      ),
      home: const PharmacyQuizScreen(),
    );
  }
}

class PharmacyQuizScreen extends StatefulWidget {
  const PharmacyQuizScreen({super.key});

  @override
  State<PharmacyQuizScreen> createState() => _PharmacyQuizScreenState();
}

// CHANGED: Use TickerProviderStateMixin instead of SingleTickerProviderStateMixin
class _PharmacyQuizScreenState extends State<PharmacyQuizScreen> 
    with TickerProviderStateMixin {
  // Quiz state
  int currentView = 0; // 0 = Start, 1 = Quiz, 2 = Result
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isSubmitted = false;
  int score = 0;
  
  // Timer state
  Timer? _timer;
  int _timeLeft = 15; // 15 seconds per question
  bool _isTimeUp = false;
  
  // Animation controllers
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;
  bool _shouldWiggle = false;
  
  // Timer wiggle animation
  late AnimationController _timerWiggleController;
  late Animation<double> _timerWiggleAnimation;
  bool _shouldWiggleTimer = false;

  // Define consistent color scheme
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color accentBlue = Color(0xFF90CAF9);
  static const Color lightBackground = Color(0xFFF8FBFF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color errorRed = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color neutralGray = Color(0xFF757575);
  static const Color neutralLight = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderLight = Color(0xFFE0E0E0);
  
  // Gradient colors for start screen
  static const Color gradientStart = Color(0xFF1976D2);
  static const Color gradientMiddle = Color(0xFF2196F3);
  static const Color gradientEnd = Color(0xFF42A5F5);
  
  // Option button colors
  static const Color optionNormal = Color(0xFFFFFFFF);
  static const Color optionHover = Color(0xFFE3F2FD);
  static const Color optionSelected = Color(0xFFBBDEFB);
  static const Color optionCorrect = Color(0xFFE8F5E9);
  static const Color optionIncorrect = Color(0xFFFFEBEE);
  
  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'Which feature would help Truserve Pharmaceutical in Naga City the most?',
      'answers': [
        'Medicine inventory tracker with expiry date monitoring and low-stock alerts',
        'Prescription upload and order ahead system',
        'Queue number system to reduce waiting time',
        'Customer loyalty points and rewards program',
      ],
      'correctAnswer': 0,
    },
    {
      'question': 'What is the primary benefit of a mobile pharmacy app?',
      'answers': [
        'Faster checkout process',
        'Convenience and time-saving for customers',
        'Better marketing',
        'Reduced operational costs',
      ],
      'correctAnswer': 1,
    },
    {
      'question':
          'Which feature helps patients manage their medication better?',
      'answers': [
        'Medication reminder notifications',
        'Store location map',
        'Loyalty points program',
        'Social media integration',
      ],
      'correctAnswer': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize wiggle animation for wrong answers
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this, // Now using TickerProviderStateMixin
    );
    
    _wiggleAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: -0.05),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.05, end: 0.05),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.05, end: -0.05),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.05, end: 0.0),
          weight: 1,
        ),
      ],
    ).animate(_wiggleController);
    
    // Initialize timer wiggle animation
    _timerWiggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this, // Now using TickerProviderStateMixin
    );
    
    _timerWiggleAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: -0.1),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.1, end: 0.1),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.1, end: -0.1),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.1, end: 0.0),
          weight: 1,
        ),
      ],
    ).animate(_timerWiggleController);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wiggleController.dispose();
    _timerWiggleController.dispose();
    super.dispose();
  }

  void startQuiz() {
    setState(() {
      currentView = 1;
      currentQuestionIndex = 0;
      selectedAnswerIndex = null;
      isSubmitted = false;
      score = 0;
      _timeLeft = 15;
      _isTimeUp = false;
      _shouldWiggle = false;
      _shouldWiggleTimer = false;
      startTimer();
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          
          // Trigger timer wiggle when 5 seconds left
          if (_timeLeft == 5) {
            triggerTimerWiggle();
          }
        });
      } else {
        setState(() {
          _isTimeUp = true;
          if (!isSubmitted && selectedAnswerIndex == null) {
            isSubmitted = true;
          }
          timer.cancel();
        });
      }
    });
  }

  void triggerWiggle() {
    if (!_shouldWiggle) {
      setState(() {
        _shouldWiggle = true;
      });
      _wiggleController.reset();
      _wiggleController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _shouldWiggle = false;
          });
        });
      });
    }
  }
  
  void triggerTimerWiggle() {
    if (!_shouldWiggleTimer) {
      setState(() {
        _shouldWiggleTimer = true;
      });
      _timerWiggleController.reset();
      _timerWiggleController.forward().then((_) {
        // Repeat the wiggle every second for 5 seconds
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeLeft > 0 && _timeLeft <= 5) {
            _timerWiggleController.reset();
            _timerWiggleController.forward();
          } else {
            timer.cancel();
            setState(() {
              _shouldWiggleTimer = false;
            });
          }
        });
      });
    }
  }

  void selectAnswer(int index) {
    if (!isSubmitted && !_isTimeUp) {
      setState(() {
        selectedAnswerIndex = index;
      });
    }
  }

  void submitAnswer() {
    if (selectedAnswerIndex != null && !isSubmitted && !_isTimeUp) {
      setState(() {
        isSubmitted = true;
        _timer?.cancel();
        
        if (selectedAnswerIndex == questions[currentQuestionIndex]['correctAnswer']) {
          score++;
        } else {
          triggerWiggle();
        }
      });
    }
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        isSubmitted = false;
        _timeLeft = 15;
        _isTimeUp = false;
        _shouldWiggle = false;
        _shouldWiggleTimer = false;
        startTimer();
      } else {
        _timer?.cancel();
        currentView = 2;
      }
    });
  }

  void restartQuiz() {
    setState(() {
      _timer?.cancel();
      currentView = 0;
      currentQuestionIndex = 0;
      selectedAnswerIndex = null;
      isSubmitted = false;
      score = 0;
      _timeLeft = 15;
      _isTimeUp = false;
      _shouldWiggle = false;
      _shouldWiggleTimer = false;
    });
  }

  String formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: currentView == 0
          ? buildStartView()
          : currentView == 1
              ? buildQuizView()
              : buildResultView(),
    );
  }

  Widget buildStartView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientStart,
            gradientMiddle,
            gradientEnd,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 100,
                          color: primaryBlue.withOpacity(0.1),
                        ),
                        Icon(
                          Icons.local_pharmacy,
                          size: 60,
                          color: primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Pharmacy Knowledge Quiz',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Test your knowledge about pharmacy systems and technology',
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: primaryBlue.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuizView() {
    final currentQuestion = questions[currentQuestionIndex];
    final questionNumber = currentQuestionIndex + 1;
    final totalQuestions = questions.length;
    final correctAnswerIndex = currentQuestion['correctAnswer'];

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text(
          'Pharmacy Quiz',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Progress and timer section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer with wiggle animation
                    AnimatedBuilder(
                      animation: _timerWiggleAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_timerWiggleAnimation.value * 20, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _timeLeft <= 5 
                                  ? errorRed.withOpacity(0.1)
                                  : primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _timeLeft <= 5 
                                    ? errorRed.withOpacity(0.3)
                                    : primaryBlue.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: _timeLeft <= 5 ? errorRed : primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatTime(_timeLeft),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _timeLeft <= 5 ? errorRed : primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Question counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Q$questionNumber/$totalQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Progress bar
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: neutralLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.question_mark,
                                      size: 14,
                                      color: primaryBlue,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Question',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentQuestion['question'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Answer options
                    Column(
                      children: List.generate(
                        currentQuestion['answers'].length,
                        (index) {
                          final answer = currentQuestion['answers'][index];
                          bool isSelected = selectedAnswerIndex == index;
                          bool isCorrect = index == correctAnswerIndex;
                          
                          Color backgroundColor = optionNormal;
                          Color borderColor = borderLight;
                          Color textColor = textPrimary;
                          IconData? icon;
                          Color iconColor = Colors.transparent;
                          
                          // Normal state
                          if (!isSelected && !isSubmitted && !_isTimeUp) {
                            backgroundColor = optionNormal;
                          }
                          
                          // Selected but not submitted
                          if (isSelected && !isSubmitted && !_isTimeUp) {
                            backgroundColor = optionSelected;
                            borderColor = primaryBlue;
                            textColor = primaryBlue;
                          }
                          
                          // Submitted/Time up states
                          if (isSubmitted || _isTimeUp) {
                            if (isCorrect) {
                              // Correct answer
                              backgroundColor = optionCorrect;
                              borderColor = successGreen;
                              textColor = successGreen;
                              icon = Icons.check_circle;
                              iconColor = successGreen;
                            } else if (isSelected && !isCorrect) {
                              // Wrong answer selected
                              backgroundColor = optionIncorrect;
                              borderColor = errorRed;
                              textColor = errorRed;
                              icon = Icons.cancel;
                              iconColor = errorRed;
                            }
                          }
                          
                          Widget answerCard = Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected || (isSubmitted && isCorrect) 
                                        ? borderColor.withOpacity(0.1) 
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    answer,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(
                                    icon,
                                    color: iconColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          );
                          
                          // Apply wiggle animation to wrong selected answer
                          if (_shouldWiggle && isSelected && !isCorrect && isSubmitted) {
                            return AnimatedBuilder(
                              animation: _wiggleAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_wiggleAnimation.value * 100, 0),
                                  child: child,
                                );
                              },
                              child: answerCard,
                            );
                          }
                          
                          return GestureDetector(
                            onTap: (!isSubmitted && !_isTimeUp) ? () => selectAnswer(index) : null,
                            child: answerCard,
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Feedback messages
                    if (_isTimeUp && !isSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: warningLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: warningOrange,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_off,
                              color: warningOrange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Time\'s up! The correct answer is highlighted.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: warningOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if ((isSubmitted || _isTimeUp) && selectedAnswerIndex != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                              ? successLight
                              : errorLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                                ? successGreen
                                : errorRed,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                                  ? successGreen
                                  : errorRed,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                                    ? 'Correct! Well done!'
                                    : 'Incorrect. The right answer is highlighted.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: (isSubmitted && selectedAnswerIndex == correctAnswerIndex)
                                      ? successGreen
                                      : errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Submit button
                          if (!isSubmitted && selectedAnswerIndex != null && !_isTimeUp)
                            ElevatedButton(
                              onPressed: submitAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: primaryBlue.withOpacity(0.3),
                              ),
                              child: const Text(
                                'Submit Answer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          
                          // Next button
                          if (isSubmitted || _isTimeUp)
                            ElevatedButton(
                              onPressed: nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                currentQuestionIndex < questions.length - 1
                                    ? 'Next Question'
                                    : 'See Results',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResultView() {
    final percentage = (score / questions.length * 100).round();

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Result icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: percentage >= 70 
                            ? successGreen.withOpacity(0.1)
                            : percentage >= 50 
                                ? primaryBlue.withOpacity(0.1)
                                : errorRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        percentage >= 70 
                            ? Icons.emoji_events
                            : percentage >= 50 
                                ? Icons.sentiment_satisfied_alt
                                : Icons.sentiment_dissatisfied,
                        size: 60,
                        color: percentage >= 70 
                            ? successGreen
                            : percentage >= 50 
                                ? primaryBlue
                                : errorRed,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Score display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: neutralLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$score / ${questions.length}',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: percentage >= 70 
                                  ? successGreen
                                  : percentage >= 50 
                                      ? primaryBlue
                                      : errorRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Result message
                    Text(
                      percentage >= 70
                          ? 'Excellent! You know pharmacy systems well!'
                          : percentage >= 50
                              ? 'Good job! Keep learning about pharmacy systems!'
                              : 'Keep practicing to improve your knowledge!',
                      style: const TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Restart button
                    ElevatedButton(
                      onPressed: restartQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Restart Quiz',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}