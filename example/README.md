# Contoh Penggunaan Onboarding Library

Contoh ini menunjukkan cara menggunakan onboarding library yang sederhana dan mudah diimplementasikan.

## Cara Menjalankan

```bash
cd example
flutter pub get
flutter run
```

## Struktur Example

- `main.dart` - Halaman utama dengan pilihan demo
- `simple_tutorial_demo.dart` - Contoh implementasi sederhana
- `tutorial_demo.dart` - Contoh implementasi advanced

## Implementasi Sederhana

### 1. Import library

```dart
import 'package:onboarding_logger/onboarding_logger.dart';
```

### 2. Buat GlobalKey untuk target elements

```dart
final GlobalKey _buttonKey1 = GlobalKey();
final GlobalKey _buttonKey2 = GlobalKey();
```

### 3. Assign keys ke widgets

```dart
ElevatedButton(
  key: _buttonKey1, // Penting!
  onPressed: () {},
  child: Text('Button 1'),
)
```

### 4. Mulai tutorial dengan helper function

```dart
void _startTutorial() {
  showSimpleTutorial(
    context: context,
    tutorialId: 'my_tutorial',
    tutorialName: 'Tutorial Saya',
    stepTitles: ['Step 1', 'Step 2'],
    stepDescriptions: ['Tap button ini', 'Tap button itu'],
    targetKeys: [_buttonKey1, _buttonKey2],
    page: _buildMyPage(),
    onCompleted: () {
      // Tutorial selesai
    },
  );
}
```

## Implementasi Advanced

### Untuk kontrol lebih detail, gunakan OnboardingView langsung:

```dart
final config = TutorialConfig(
  id: 'advanced_tutorial',
  name: 'Advanced Tutorial',
  steps: [
    TutorialStep(
      id: 'step_1',
      stepNumber: 1,
      title: 'Welcome',
      description: 'This is the first step',
      targets: [target1],
      hasHandAnimation: true,
    ),
  ],
);

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => OnboardingView(
      tutorialConfig: config,
      pages: [MyPageWidget()],
      onTutorialCompleted: () {
        Navigator.of(context).pop();
      },
    ),
  ),
);
```

## Fitur

- ✅ **Simple API**: Mudah digunakan tanpa dependency eksternal
- ✅ **Dynamic Targets**: Buat target dari widget yang ada
- ✅ **Hand Animations**: Animasi tangan yang menunjukkan aksi
- ✅ **Progress Tracking**: Indikator progress tutorial
- ✅ **Customizable**: UI yang dapat disesuaikan
- ✅ **No State Management**: Tidak menggunakan GetX atau state management lainnya
- ✅ **Logging**: Built-in logging untuk debugging
- ✅ **Multiple Action Types**: Support tap, drag, swipe, dll

## Tips

1. Pastikan widget sudah ter-render sebelum membuat target
2. Gunakan `WidgetsBinding.instance.addPostFrameCallback` jika perlu
3. Test di berbagai ukuran layar
4. Aktifkan logging untuk debugging: `OnboardingLogger.setLoggingEnabled(true)`
