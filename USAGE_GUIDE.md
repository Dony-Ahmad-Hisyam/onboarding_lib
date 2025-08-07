# Panduan Penggunaan Onboarding Library

## Instalasi

1. Tambahkan dependency di `pubspec.yaml`:

```yaml
dependencies:
  onboarding_logger:
    path: ../path/to/onboarding_lib
```

2. Import library:

```dart
import 'package:onboarding_logger/onboarding_logger.dart';
```

## Penggunaan Dasar

### 1. Metode Simple (Recommended)

Cara paling mudah menggunakan library ini:

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();

  void _startTutorial() {
    showSimpleTutorial(
      context: context,
      tutorialId: 'my_tutorial',
      tutorialName: 'Tutorial Aplikasi Saya',
      stepTitles: [
        'Langkah Pertama',
        'Langkah Kedua',
      ],
      stepDescriptions: [
        'Tap tombol ini untuk memulai',
        'Tap tombol ini untuk melanjutkan',
      ],
      targetKeys: [_button1Key, _button2Key],
      actionTypes: ['tap', 'tap'],
      page: _buildMyPage(),
      onCompleted: () {
        // Tutorial selesai
      },
    );
  }

  Widget _buildMyPage() {
    return Column(
      children: [
        ElevatedButton(
          key: _button1Key,
          onPressed: () {},
          child: Text('Button 1'),
        ),
        ElevatedButton(
          key: _button2Key,
          onPressed: () {},
          child: Text('Button 2'),
        ),
      ],
    );
  }
}
```

### 2. Metode Advanced

Untuk kontrol yang lebih detail:

```dart
void _startAdvancedTutorial() {
  // Buat targets dari widget keys
  final target1 = TutorialUtils.createTargetFromKey(
    id: 'button_1',
    key: _button1Key,
    description: 'Tap untuk memulai',
    actionType: 'tap',
  );

  // Buat konfigurasi tutorial
  final config = TutorialConfig(
    id: 'advanced_tutorial',
    name: 'Tutorial Lanjutan',
    steps: [
      TutorialStep(
        id: 'step_1',
        stepNumber: 1,
        title: 'Selamat Datang',
        description: 'Ini adalah langkah pertama',
        targets: [target1!],
        hasHandAnimation: true,
      ),
    ],
  );

  // Tampilkan tutorial
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
}
```

## Tips Penggunaan

### 1. GlobalKey untuk Target Elements

Pastikan setiap widget yang akan dijadikan target memiliki GlobalKey:

```dart
final GlobalKey _targetKey = GlobalKey();

Widget build(BuildContext context) {
  return ElevatedButton(
    key: _targetKey, // Penting!
    onPressed: () {},
    child: Text('Target Button'),
  );
}
```

### 2. Timing untuk Memulai Tutorial

Gunakan `WidgetsBinding.instance.addPostFrameCallback` untuk memastikan widget sudah ter-render:

```dart
void _startTutorial() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Start tutorial here
  });
}
```

### 3. Action Types

Library mendukung berbagai jenis aksi:

- `'tap'` - untuk tombol atau elemen yang di-tap
- `'drag'` - untuk elemen yang di-drag
- `'swipe'` - untuk elemen yang di-swipe
- `'pinch'` - untuk gesture pinch

### 4. Customization

Anda bisa mengcustomize warna dan style melalui `OnboardingColors` dan `OnboardingStyles`:

```dart
// Customize di kode Anda
const Color myCustomColor = Color(0xFF123456);
```

## Error Handling

### Target Tidak Ditemukan

Jika target tidak ditemukan (widget belum ter-render), fungsi akan return null:

```dart
final target = TutorialUtils.createTargetFromKey(...);
if (target == null) {
  // Widget belum siap, coba lagi nanti
  return;
}
```

### Debugging

Aktifkan logging untuk debugging:

```dart
OnboardingLogger.setLoggingEnabled(true);
OnboardingLogger.info('Tutorial dimulai');
```

## Best Practices

1. **Gunakan metode Simple** untuk kasus umum
2. **Beri GlobalKey pada semua target** sebelum memulai tutorial
3. **Test di berbagai ukuran layar** untuk memastikan posisi target benar
4. **Berikan feedback yang jelas** melalui onCompleted dan onSkipped callbacks
5. **Gunakan action types yang sesuai** dengan interaksi yang diharapkan

## Contoh Lengkap

Lihat folder `/example` untuk implementasi lengkap dengan berbagai skenario penggunaan.
