# 💊 Pharmacy Quiz App

A beautiful, interactive Flutter quiz application designed to test knowledge about pharmacy systems and technology. Features a modern UI with smooth animations, timed questions, and instant feedback.

## ✨ Features

- **🎯 Interactive Quiz Interface** - Clean, modern design with intuitive navigation
- **⏱️ Timer System** - 15-second countdown for each question with visual warnings
- **🎨 Smooth Animations** - Wiggle effects for incorrect answers and timer alerts
- **📊 Progress Tracking** - Visual progress bar and question counter
- **💯 Instant Feedback** - Color-coded responses showing correct and incorrect answers
- **📈 Results Summary** - Detailed score breakdown with performance feedback
- **🔄 Restart Functionality** - Easy quiz restart to try again

## 🎮 How It Works

1. **Start Screen** - Welcome screen with quiz introduction
2. **Quiz Questions** - Answer multiple-choice questions within the time limit
3. **Timed Challenges** - 15 seconds per question with a countdown timer
4. **Visual Feedback** - Immediate feedback on answer selection
5. **Results Screen** - Final score with percentage and performance message

## 🎨 UI Highlights

- **Color-Coded Feedback**
  - 🟢 Green - Correct answers
  - 🔴 Red - Incorrect answers
  - 🟡 Orange - Time warnings
  - 🔵 Blue - Selected options

- **Smart Animations**
  - Wiggle animation when selecting wrong answers
  - Timer shake when 5 seconds remain
  - Smooth transitions between screens

- **Responsive Design**
  - Works on all screen sizes
  - Scrollable content for smaller devices
  - Clean, professional layout

## 📋 Requirements

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An Android/iOS emulator or physical device

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pharmacy-quiz-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Main application entry point
    ├── MyApp                 # Root widget with theme configuration
    ├── PharmacyQuizScreen    # Main quiz screen (StatefulWidget)
    └── _PharmacyQuizScreenState
        ├── Quiz Logic        # Question handling, scoring, navigation
        ├── Timer Logic       # Countdown timer and time management
        ├── Animations        # Wiggle and shake animations
        └── UI Components     # Start, Quiz, and Result views
```

## 🎯 Quiz Configuration

### Adding/Modifying Questions

Questions are stored in the `questions` list. Each question follows this structure:

```dart
{
  'question': 'Your question text here?',
  'answers': [
    'Option A',
    'Option B',
    'Option C',
    'Option D',
  ],
  'correctAnswer': 0, // Index of correct answer (0-3)
}
```

### Timer Settings

Modify the timer duration in `_PharmacyQuizScreenState`:

```dart
int _timeLeft = 15; // Change to desired seconds per question
```

### Warning Threshold

Adjust when the timer warning appears:

```dart
if (_timeLeft == 5) { // Change threshold here
  triggerTimerWiggle();
}
```

## 🎨 Customization

### Color Scheme

All colors are defined as constants at the top of `_PharmacyQuizScreenState`:

```dart
static const Color primaryBlue = Color(0xFF2196F3);
static const Color successGreen = Color(0xFF4CAF50);
static const Color errorRed = Color(0xFFF44336);
// ... and more
```

### Animation Duration

Modify animation timings:

```dart
// Wiggle animation
_wiggleController = AnimationController(
  duration: const Duration(milliseconds: 200), // Change here
  vsync: this,
);

// Timer wiggle
_timerWiggleController = AnimationController(
  duration: const Duration(milliseconds: 300), // Change here
  vsync: this,
);
```

### Scoring Thresholds

Adjust performance messages in `buildResultView()`:

```dart
percentage >= 70  // Excellent
percentage >= 50  // Good
// Below 50     // Keep practicing
```

## 🔧 Technical Details

### State Management

- Uses `StatefulWidget` with `TickerProviderStateMixin` for animations
- Local state management for quiz flow
- Timer managed with `Timer.periodic`

### Animations

- **Wiggle Animation** - Horizontal shake for incorrect answers
- **Timer Wiggle** - Warning animation when time is running low
- **TweenSequence** - Smooth multi-step animations

### Key Features Implementation

- **Progress Tracking** - `LinearProgressIndicator` with calculated value
- **Time Management** - Periodic timer with state updates
- **Answer Validation** - Immediate comparison with correct answer index
- **Navigation** - State-based view switching (Start → Quiz → Results)

## 📱 Screens

### 1. Start Screen
- Welcome message
- App branding with pharmacy icon
- Start quiz button
- Gradient background

### 2. Quiz Screen
- Question counter (Q1/3)
- Countdown timer with color warnings
- Progress bar
- Question card
- Multiple choice options (A, B, C, D)
- Submit/Next buttons
- Feedback messages

### 3. Results Screen
- Performance icon (trophy/smiley/sad)
- Score display (X/Y format)
- Percentage score
- Performance message
- Restart button

## 🐛 Troubleshooting

**Timer not working?**
- Ensure `Timer` is imported: `import 'dart:async';`
- Check that timer is started in `startQuiz()`

**Animations not smooth?**
- Verify `TickerProviderStateMixin` is used
- Check animation controller initialization in `initState()`

**Build errors?**
- Run `flutter clean` then `flutter pub get`
- Update Flutter: `flutter upgrade`

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👨‍💻 Developer

Created for Truserve Pharmaceutical in Naga City

## 📞 Support

For questions or issues, please open an issue in the repository.

---

**Made with ❤️ using Flutter**