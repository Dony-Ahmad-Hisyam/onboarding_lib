# Simple Onboarding Library

Library Flutter sederhana untuk membuat onboarding interaktif dengan animasi touch dan navigasi yang mudah digunakan.

## Fitur

- ✅ Animasi touch yang sederhana dan menarik
- ✅ Navigasi guided - user harus mengikuti langkah demi langkah
- ✅ Highlight area target yang responsif
- ✅ Tombol skip untuk melewati tutorial
- ✅ Progress indicator untuk menunjukkan posisi step
- ✅ Mudah diintegrasikan ke aplikasi yang sudah ada

## Cara Penggunaan

### 1. Import library

```dart
import 'package:onboarding_lib/onboarding_lib.dart';
```

### 2. Buat controller

```dart
final OnboardingController _controller = OnboardingController();
```

### 3. Buat GlobalKey untuk setiap widget target

```dart
final GlobalKey _menuKey = GlobalKey();
final GlobalKey _searchKey = GlobalKey();
final GlobalKey _profileKey = GlobalKey();
final GlobalKey _fabKey = GlobalKey();
```

### 4. Buat steps untuk onboarding

```dart
void _startOnboarding() {
  final steps = [
    OnboardingStepBuilder.create(
      targetKey: _menuKey,
      title: "Menu",
      description: "Tap here to open the main menu",
    ),
    OnboardingStepBuilder.create(
      targetKey: _searchKey,
      title: "Search",
      description: "Use this to search for items",
    ),
    OnboardingStepBuilder.create(
      targetKey: _profileKey,
      title: "Profile",
      description: "View your profile information here",
    ),
    OnboardingStepBuilder.create(
      targetKey: _fabKey,
      title: "Add New",
      description: "Tap to add new content",
    ),
  ];

  _controller.start(steps);
}
```

### 5. Wrap widget dengan OnboardingShowcase

```dart
@override
Widget build(BuildContext context) {
  return OnboardingShowcase(
    controller: _controller,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        leading: IconButton(
          key: _menuKey, // Assign key to target widget
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu tap
          },
        ),
        actions: [
          IconButton(
            key: _searchKey, // Assign key to target widget
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search tap
            },
          ),
        ],
      ),
      body: YourAppContent(),
      floatingActionButton: FloatingActionButton(
        key: _fabKey, // Assign key to target widget
        onPressed: () {
          // Handle FAB tap
        },
        child: const Icon(Icons.add),
      ),
    ),
  );
}
```

### 6. Start onboarding setelah widget ready

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startOnboarding();
  });
}
```

## Cara Kerja

1. **User harus mengikuti arahan** - tidak ada tombol next/previous
2. **Tap pada area highlight** untuk melanjutkan ke step berikutnya
3. **Area tap diperbesar** untuk memudahkan interaksi
4. **Tombol skip** tersedia jika user ingin melewati tutorial
5. **Onboarding selesai** otomatis setelah step terakhir

## Contoh Lengkap

Lihat file `example/lib/main.dart` untuk contoh implementasi lengkap.

## Konfigurasi

Anda dapat mengkustomisasi tampilan dengan `OnboardingConfig`:

```dart
OnboardingShowcase(
  controller: _controller,
  config: OnboardingConfig(
    handAnimationDuration: Duration(milliseconds: 800),
    // tambahan konfigurasi lainnya
  ),
  child: YourWidget(),
)
```

## Tips

- Pastikan setiap widget target memiliki `GlobalKey` yang unik
- Mulai onboarding setelah widget tree sudah ready dengan `addPostFrameCallback`
- Gunakan deskripsi yang jelas dan singkat untuk setiap step
- Test pada berbagai ukuran layar untuk memastikan area tap responsif
