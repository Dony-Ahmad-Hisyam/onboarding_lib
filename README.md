# onboarding_lib

Perpustakaan Flutter untuk membuat onboarding interaktif (tap dan drag & drop) dengan overlay highlight dan tooltip cerdas, tanpa ketergantungan eksternal.

Fitur Utama

- Highlight langsung terlihat di langkah pertama
- Tooltip cerdas: menghindari area highlight, koridor drag, dan node sumber/tujuan
- Drag & drop generik (payload apa pun)
- UI default sederhana: deskripsi statis di atas (header), tombol Skip/Next di bawah (aktif otomatis)
- Deskripsi-first: title opsional, description wajib; header menampilkan "<step>. <description>"
- API ringkas: tapStep, dragStep, ob, withOnboarding
- Satu baris saja jika mau: showOnboarding(context: ..., steps: [...]) tanpa bungkus/Controller
- Nol pemanggilan di layar: OnboardingAutoStart(steps: [...]) auto-jalan saat key siap
- Satu overlay aktif saja: library mencegah overlay ganda secara otomatis
- Siap untuk aplikasi besar: init sekali di root + registrasi langkah per fitur dengan auto-start per-route
- Best way sederhana: GlobalKey + Draggable/DragTarget (tanpa wrapper)
- Alternatif opsional: ObDraggable/ObDragTarget dan binding via ID (tapStepById/dragStepById)
- Kustomisasi penuh: warna overlay, padding target, gaya tooltip, dll.
- Koridor drag berbentuk kapsul halus dengan border dan tint
- Tanpa halo/arrow pada koridor; fokus bersih pada kapsul saja
- Navigasi: langkah pertama menampilkan Skip (kiri), langkah berikutnya Back; tombol kanan Next berubah jadi Finish di langkah terakhir. Indikator progres hanya tampil di bawah Back/Next.
- Interaksi latar belakang diblokir saat onboarding aktif (tap/drag hanya untuk langkah berjalan)

Instalasi
Tambahkan ke pubspec.yaml aplikasi Anda:

```yaml
dependencies:
  onboarding_lib:
    path: ../path/to/onboarding_lib
```

Impor

```dart
import 'package:onboarding_lib/onboarding_lib.dart';
```

Quick Start (Sederhana seperti di contoh)

Tiga langkah, tanpa wrapper/Controller:

1. Root app: inisiasi service + pasang RouteObserver

```dart
// main.dart
import 'package:get/get.dart';
import 'onboarding_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OnboardingCenter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final observer = OnbRouteObserver();
    return GetMaterialApp(
      // ... routes ...
      navigatorObservers: [observer],
    );
  }
}
```

2. Home: beri GlobalKey pada target + registrasi langkah + start sekali

```dart
class HomePage extends StatefulWidget { const HomePage({super.key}); /* ... */ }
class _HomePageState extends State<HomePage> {
  final _mathBtnKey = GlobalKey(debugLabel: 'mathBtn');
  final _positionBtnKey = GlobalKey(debugLabel: 'positionBtn');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('home', () => [
        tapStep(
          id: 'open_math_game',
          targetKey: _mathBtnKey,
          description: 'Main Math Game',
          iconPosition: IconPosition.bottomRight,
        ),
        tapStep(
          id: 'lihat_position_demo',
          targetKey: _positionBtnKey,
          description: 'Coba Position Demo',
          iconPosition: IconPosition.bottomLeft,
        ),
      ]);
      OnboardingCenter.to.start(context, 'home', once: true);
    });
  }
  // ... build() menempelkan key ke tombol ...
}
```

3. Halaman fitur (Match): registrasi lokal + start sekali + tombol bantuan

```dart
class MatchGameDemo extends StatefulWidget { const MatchGameDemo({super.key}); /* ... */ }
class _MatchGameDemoState extends State<MatchGameDemo> {
  final _gameSelectionKey = GlobalKey(debugLabel: 'gameSelectionKey');
  final _src3Key = GlobalKey(debugLabel: 'src_3');
  final _dstEmptyKey = GlobalKey(debugLabel: 'dst_empty');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('match', () => [
        tapStep(
          id: 'select_game',
          targetKey: _gameSelectionKey,
          description: 'Choose The Mini-game',
        ),
        dragStep(
          id: 'drag_number1',
          sourceKey: _src3Key,
          destinationKey: _dstEmptyKey,
          description: 'Play, Learn and Earn Coins',
        ),
      ]);
      OnboardingCenter.to.start(context, 'match', once: true);
    });
  }

  // AppBar help icon untuk menjalankan ulang
  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
    title: const Text('Match Game'),
    actions: [
      IconButton(
        icon: const Icon(Icons.help_outline),
        tooltip: 'Bantuan',
        onPressed: () => OnboardingCenter.to.start(context, 'match', once: false),
      ),
    ],
  );
}
```

Catatan:

- Cukup pakai GlobalKey pada widget target/sumber; tidak perlu wrapper khusus.
- Library otomatis menjaga hanya satu overlay aktif; jangan mencampur withOnboarding/showOnboarding/auto-start pada layar yang sama.

Panduan Lengkap (Indonesia)

Rekomendasi paling sederhana (tanpa ID, tanpa wrapper): GlobalKey + Draggable/DragTarget + tapStep/dragStep.

1. Tandai widget yang ingin di-highlight dengan GlobalKey

```dart
final GlobalKey btnKey = GlobalKey(); // Key yang akan di-highlight

ElevatedButton(
  key: btnKey,
  onPressed: () {},
  child: const Text('Mulai'),
)
```

2. Untuk drag & drop, pakai Draggable/DragTarget biasa dengan GlobalKey

- Sumber (Draggable):

```dart
final GlobalKey srcKey = GlobalKey(); // Sumber drag

Draggable<String>(
  key: srcKey,
  data: '4',
  child: buildBlueCircle('4'),
  childWhenDragging: Opacity(opacity: 0.2, child: buildBlueCircle('4')),
  feedback: Material(color: Colors.transparent, child: buildBlueCircle('4')),
)
```

- Tujuan (DragTarget):

```dart
final GlobalKey dstKey = GlobalKey(); // Tujuan drag

DragTarget<String>(
  key: dstKey,
  onWillAccept: (d) => d == '4' && _valueOnTarget == null,
  onAccept: (d) => setState(() => _valueOnTarget = d),
  builder: (context, candidates, _) {
    final color = _valueOnTarget != null
        ? Colors.green
        : (candidates.isNotEmpty ? Colors.purple.shade700 : Colors.purple);
    return buildPurpleCircle('10', color);
  },
)
```

3. Definisikan langkah onboarding (tap/drag)

```dart
final steps = [
  // Title opsional; cukup isi description untuk tampilan header
  tapStep(
    id: 'welcome',
    targetKey: btnKey,
    description: 'Ketuk tombol ini untuk memulai.', // Teks deskriptif utama
  ),
  dragStep(
    id: 'drag_4_to_10',
    sourceKey: srcKey,
    destinationKey: dstKey,
    description: 'Seret angka dari sumber ke lingkaran tujuan.',
  // Catatan:
  // - position default drag = TooltipPosition.top
  // - anchor default drag = DragTooltipAnchor.destination (tooltip dekat tujuan)
  ),
];
```

4a. Paling sederhana: panggil sekali (tanpa bungkus)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Memulai onboarding tanpa controller/bungkus
  // Library akan membuat overlay dan membersihkan otomatis saat selesai/skip
  showOnboarding(context: context, steps: steps);
});
```

4b. Atau gunakan controller (opsional) jika perlu kontrol lebih

4c. Zero-call di layar (auto-start saat key siap)

```dart
Stack(
  children: [
  YourScreenBody(...), // UI Anda
  // Auto-start: akan menunggu semua key siap lalu memanggil overlay sekali
  OnboardingAutoStart(steps: steps),
  ],
)
```

```dart
// ob() secara default:
// - menampilkan header di atas (deskripsi-first)
// - menampilkan bottom bar Skip/Next di bawah
// - gaya header ramah anak: padding 15, margin samping kecil, font lebih besar
// Gunakan ini jika Anda ingin pegang Controller (misal, untuk Start ulang manual)
final controller = ob(
  steps: steps,
  overlayColor: Colors.black,
  overlayOpacity: 0.7,
  targetPadding: 8,
  onComplete: () {
  // selesai onboarding
  },
);
```

5. (Opsional) Bungkus root dengan withOnboarding(...) hanya jika Anda pakai controller

```dart
// Bungkus UI hanya jika Anda menggunakan controller
return Scaffold(
  appBar: AppBar(title: const Text('Contoh')),
  body: ...,
).withOnboarding(controller);
```

6. Mulai onboarding (jika pakai controller)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  controller.start(); // Mulai secara manual jika pakai controller
});
```

7. Multi-drag seperti contoh (Math Game)

- Seret “4” → lingkaran “10”
- Seret “2” → lingkaran “7”
- Seret “3” → lingkaran kosong

Buat tiga GlobalKey untuk sumber (4, 2, 3) dan tiga GlobalKey untuk tujuan (10, 7, empty), lalu tambahkan tiga dragStep sesuai pasangannya. Lihat `example/lib/match_game_demo.dart` untuk implementasi lengkap satu file.

Navigasi (Bottom Bar)

- Kiri: Step pertama = Skip, step selanjutnya = Back
- Kanan: Next, dan otomatis berubah menjadi Finish di step terakhir
- Progres (misal 2/5) hanya muncul di baris kedua tombol Back/Next; Skip/Finish tidak menampilkan progres

Kustomisasi

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (default drag: destination)
- OnboardingConfig.tooltipConfig:
  - backgroundColor, textColor, maxWidth, borderRadius, padding (untuk tooltip)
  - headerAtTop (default: true)
  - showBottomBar (default: true)
  - headerPadding (default: EdgeInsets.all(15))
  - headerOuterMargin (default: EdgeInsets.symmetric(horizontal: 12))
  - headerMinHeight (default: 68), headerHeight (opsional), headerWidth (opsional)
  - headerFontSize (untuk teks utama header)
  - headerBackgroundColor, headerTextColor (khusus header)
- targetPadding: jarak highlight dari target

Catatan Penting (Jangan Dicampur)

- Pada satu layar, jangan campur withOnboarding(...) dengan showOnboarding(...) atau OnboardingAutoStart(...).
- Library sudah menjaga hanya satu overlay aktif; memanggil beberapa API sekaligus bisa membuat layar tampak lebih gelap.

Best Practices

- Panggil controller.start() setelah frame pertama agar posisi akurat.
- Pastikan setiap target/sumber yang di-highlight punya GlobalKey stabil.
- Untuk drag, biarkan anchor tooltip di destination agar tidak menutupi koridor drag.
- Hindari rebuild yang mengganti GlobalKey saat onboarding aktif.

Untuk Aplikasi Besar (disarankan)

- Inti ide: Inisiasi sekali di root, registrasi langkah desentralisasi di tiap fitur, dan auto-start berdasarkan route yang aktif.
- Kelebihan: Developer fitur hanya menambahkan GlobalKey + steps; tidak perlu memegang controller/wrapper.

1. Root: service + RouteObserver (contoh dengan GetX)

```dart
// main.dart (ringkas)
import 'onboarding_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OnboardingCenter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final observer = OnbRouteObserver();
    return GetMaterialApp(
      // ...routes...
      navigatorObservers: [observer],
    );
  }
}
```

2. Fitur: registrasi langkah secara lokal (lazy) + opsional start sekali

```dart
// SomePage.dart
class SomePage extends StatefulWidget { /* ... */ }
class _SomePageState extends State<SomePage> {
  final _btnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('some', () => [
        tapStep(id: 'tap_btn', targetKey: _btnKey, description: 'Tap tombol ini'),
      ]);
      // Opsional: mulai sekali untuk route ini jika siap
      OnboardingCenter.to.start(context, 'some', once: true);
    });
  }
  // ...build()...
}
```

3. Help icon untuk memulai ulang onboarding secara manual

```dart
AppBar(
  title: const Text('Halaman'),
  actions: [
    IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'Bantuan',
      onPressed: () => OnboardingCenter.to.start(context, 'some', once: false),
    ),
  ],
)
```

Catatan trigger: gunakan salah satu mekanisme (observer atau auto-start widget) per route. Bila ingin keduanya, pastikan pakai once: true agar tidak dobel.

Troubleshooting

- Tooltip menutupi target/koridor: default drag menempatkan tooltip dekat destination dan menghindari area konflik; sesuaikan position bila perlu.
- Overlay tidak muncul di langkah awal: pastikan start() dipanggil setelah layout.
- Target tidak terdeteksi: pastikan GlobalKey ditempel pada widget yang dirender.

Alternatif (Opsional)

- Wrapper generik (ObDraggable/ObDragTarget)
  Jika ingin payload typed dan pembungkusan rapi, Anda bisa gunakan:

```dart
ObDraggable<String>(keyRef: srcKey, data: '4', child: buildChip('4'), feedback: ...);
ObDragTarget<String>(keyRef: dstKey, canAccept: (d) => d == '4', onAccept: ..., builder: ...);
```

- Binding berbasis ID (OnboardingKeyStore)
  Menghindari menyimpan banyak GlobalKey di State:

```dart
final keys = OnboardingKeyStore.instance;

// Tag UI
ObDraggable<String>(keyRef: keys.key('src_4'), data: '4', child: ..., feedback: ...);
ObDragTarget<String>(keyRef: keys.key('dst_10'), canAccept: ..., onAccept: ..., builder: ...);

// Langkah berbasis ID via helper
final steps = [
  tapStepById(id: 'welcome', targetId: 'btn_start', description: 'Tap untuk mulai'),
  dragStepById(id: 'drag_4_to_10', sourceId: 'src_4', destinationId: 'dst_10', description: 'Seret ke tujuan'),
  // (Opsional) tambahkan title: '...' bila ingin baris judul terpisah di tooltip
];
```

Contoh Lengkap

Lihat folder `example/` untuk contoh Math Game satu file (tanpa ID & tanpa wrapper), menggunakan:

- tapStep, dragStep, ob, withOnboarding
- Draggable/DragTarget standar dengan GlobalKey
- Multi drag (4→10, 2→7, 3→empty)

---

Complete Tutorial (English)

Quick Start (as simple as the example)

Three steps, no wrappers/controllers:

1. App root: initialize the service + add a RouteObserver

```dart
// main.dart
import 'package:get/get.dart';
import 'onboarding_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OnboardingCenter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final observer = OnbRouteObserver();
    return GetMaterialApp(
      // ... routes ...
      navigatorObservers: [observer],
    );
  }
}
```

2. Home page: attach GlobalKeys + register steps + start once

```dart
class HomePage extends StatefulWidget { const HomePage({super.key}); /* ... */ }
class _HomePageState extends State<HomePage> {
  final _mathBtnKey = GlobalKey(debugLabel: 'mathBtn');
  final _positionBtnKey = GlobalKey(debugLabel: 'positionBtn');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('home', () => [
        tapStep(
          id: 'open_math_game',
          targetKey: _mathBtnKey,
          description: 'Main Math Game',
          iconPosition: IconPosition.bottomRight,
        ),
        tapStep(
          id: 'lihat_position_demo',
          targetKey: _positionBtnKey,
          description: 'Coba Position Demo',
          iconPosition: IconPosition.bottomLeft,
        ),
      ]);
      OnboardingCenter.to.start(context, 'home', once: true);
    });
  }
}
```

3. Feature page (Match): local registration + one-time start + help icon

```dart
class MatchGameDemo extends StatefulWidget { const MatchGameDemo({super.key}); /* ... */ }
class _MatchGameDemoState extends State<MatchGameDemo> {
  final _gameSelectionKey = GlobalKey(debugLabel: 'gameSelectionKey');
  final _src3Key = GlobalKey(debugLabel: 'src_3');
  final _dstEmptyKey = GlobalKey(debugLabel: 'dst_empty');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('match', () => [
        tapStep(
          id: 'select_game',
          targetKey: _gameSelectionKey,
          description: 'Choose The Mini-game',
        ),
        dragStep(
          id: 'drag_number1',
          sourceKey: _src3Key,
          destinationKey: _dstEmptyKey,
          description: 'Play, Learn and Earn Coins',
        ),
      ]);
      OnboardingCenter.to.start(context, 'match', once: true);
    });
  }

  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
    title: const Text('Match Game'),
    actions: [
      IconButton(
        icon: const Icon(Icons.help_outline),
        tooltip: 'Help',
        onPressed: () => OnboardingCenter.to.start(context, 'match', once: false),
      ),
    ],
  );
}
```

Notes:

- Just use GlobalKeys on the target/source widgets; no special wrappers are needed.
- The library enforces a single active overlay; do not mix withOnboarding/showOnboarding/auto-start on the same screen.

The simplest recommended path (no IDs, no wrappers): GlobalKey + Draggable/DragTarget + tapStep/dragStep.

1. Attach a GlobalKey to widgets to highlight

```dart
final GlobalKey btnKey = GlobalKey(); // Key to highlight
ElevatedButton(key: btnKey, onPressed: () {}, child: const Text('Start'));
```

2. For drag & drop, use plain Draggable/DragTarget with GlobalKeys

- Source (Draggable):

```dart
final GlobalKey sourceKey = GlobalKey(); // Drag source

Draggable<String>(
  key: sourceKey,
  data: '4',
  child: buildBlueCircle('4'),
  childWhenDragging: Opacity(opacity: 0.2, child: buildBlueCircle('4')),
  feedback: Material(color: Colors.transparent, child: buildBlueCircle('4')),
)
```

- Destination (DragTarget):

```dart
final GlobalKey destKey = GlobalKey(); // Drag destination

DragTarget<String>(
  key: destKey,
  onWillAccept: (d) => d == '4' && _valueOnTarget == null,
  onAccept: (d) => setState(() => _valueOnTarget = d),
  builder: (context, candidates, _) {
    final color = _valueOnTarget != null
        ? Colors.green
        : (candidates.isNotEmpty ? Colors.purple.shade700 : Colors.purple);
    return buildPurpleCircle('10', color);
  },
)
```

3. Define onboarding steps

```dart
final steps = [
  // Title is optional; header uses description-first by default
  tapStep(
    id: 'welcome',
    targetKey: btnKey,
    description: 'Tap this button to get started.', // Main descriptive text
  ),
  dragStep(
    id: 'drag_4_to_10',
    sourceKey: sourceKey,
    destinationKey: destKey,
    description: 'Drag the number from source to the destination circle.',
  ),
];
```

4a. Easiest: fire it in one line (no wrapper)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Start onboarding without a controller/wrapper.
  // The library inserts and later cleans up the overlay automatically.
  showOnboarding(context: context, steps: steps);
});
```

4b. Or, create the controller (optional) for more control

4c. Zero-call on the screen (auto-start when keys are ready)

```dart
Stack(
  children: [
  YourScreenBody(...), // Your UI
  // Auto-start: waits for all keys to be ready and fires once.
  OnboardingAutoStart(steps: steps),
  ],
)
```

```dart
final controller = ob(
  steps: steps,
  overlayColor: Colors.black,
  overlayOpacity: 0.7,
  targetPadding: 8,
  // You can override header style if desired:
  // tooltip: const TooltipConfig(
  //   headerPadding: EdgeInsets.all(15),
  //   headerOuterMargin: EdgeInsets.symmetric(horizontal: 12),
  //   headerFontSize: 18,
  //   headerBackgroundColor: Color(0xFFB5F5C9),
  //   headerTextColor: Color(0xFF0D1B2A),
  // ),
);
```

5. (Optional) Wrap your root only if you use the controller

```dart
return Scaffold(...).withOnboarding(controller);
```

6. Start after the first frame (only when using the controller)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) => controller.start());
```

7. Multi-drag (as in the sample app)

- Drag “4” → circle “10”
- Drag “2” → circle “7”
- Drag “3” → empty circle

Create GlobalKeys for each source/destination pair and add one dragStep per pair. See `example/lib/match_game_demo.dart` for a single-file implementation.

Navigation (Bottom Bar)

- Left: First step = Skip, then Back on subsequent steps
- Right: Next, and automatically switches to Finish on the last step
- Progress (e.g., 2/5) is only shown as a second line under Back/Next; Skip/Finish do not show progress

Customization

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (drag defaults to destination)
- TooltipConfig:
  - backgroundColor, textColor, maxWidth, borderRadius, padding (for tooltip)
  - headerAtTop (default: true)
  - showBottomBar (default: true)
  - headerPadding (default: EdgeInsets.all(15))
  - headerOuterMargin (default: EdgeInsets.symmetric(horizontal: 12))
  - headerMinHeight (default: 68), headerHeight (optional), headerWidth (optional)
  - headerFontSize (for header main text)
  - headerBackgroundColor, headerTextColor (header-only overrides)
- targetPadding adjusts highlight padding

Important Note (Do Not Mix)

- On a single screen, do not mix withOnboarding(...) with showOnboarding(...) or OnboardingAutoStart(...).
- The library enforces a single active overlay; mixing APIs can make the screen appear darker if doubled.

Visuals

- Drag corridor is a smooth capsule with border and tint (no halos, no arrow)
- Background interactions are blocked while onboarding is active

Best Practices

- Call controller.start() in a post-frame callback for accurate positions.
- Keep GlobalKeys stable for all highlighted widgets.
- For drag flows, prefer anchoring near the destination to avoid covering the corridor.
- Avoid rebuilding widgets that recreate GlobalKeys during onboarding.

Large Apps (recommended)

- Core idea: Initialize once at app root, register steps per feature locally, and auto-start per active route.
- Benefits: Feature devs only add GlobalKeys + steps; no controller/wrapper to manage.

1. Root: service + RouteObserver (GetX example)

```dart
// main.dart (short)
import 'onboarding_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OnboardingCenter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final observer = OnbRouteObserver();
    return GetMaterialApp(
      // ...routes...
      navigatorObservers: [observer],
    );
  }
}
```

2. Feature: local (lazy) registration + optional one-time start

```dart
class SomePage extends StatefulWidget { /* ... */ }
class _SomePageState extends State<SomePage> {
  final _btnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('some', () => [
        tapStep(id: 'tap_btn', targetKey: _btnKey, description: 'Tap this button'),
      ]);
      OnboardingCenter.to.start(context, 'some', once: true); // optional
    });
  }
}
```

3. Help icon to restart onboarding

```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () => OnboardingCenter.to.start(context, 'some', once: false),
    ),
  ],
)
```

Trigger note: pick a single trigger per route (observer or auto-start widget). If combining, set once: true to avoid duplicates.

Troubleshooting

- Tooltip overlaps highlight/drag corridor: default drag placement prefers destination and avoids conflicts; adjust position if needed.
- Overlay not visible on the first step: ensure start() is called after layout.
- Target not detected: ensure GlobalKeys are attached to rendered widgets.

Alternatives (Optional)

- Generic wrappers (ObDraggable/ObDragTarget) for a typed, wrapped API

```dart
ObDraggable<String>(keyRef: sourceKey, data: '4', child: ..., feedback: ...);
ObDragTarget<String>(keyRef: destKey, canAccept: (d) => d == '4', onAccept: ..., builder: ...);
```

- ID-based binding (OnboardingKeyStore) with tapStepById/dragStepById

```dart
final keys = OnboardingKeyStore.instance;
ObDraggable<String>(keyRef: keys.key('src_4'), data: '4', child: ..., feedback: ...);
ObDragTarget<String>(keyRef: keys.key('dst_10'), canAccept: ..., onAccept: ..., builder: ...);

final steps = [
  tapStepById(id: 'welcome', targetId: 'btn_start', description: 'Tap to start'),
  dragStepById(id: 'drag_4_to_10', sourceId: 'src_4', destinationId: 'dst_10', description: 'Drag from source to destination'),
  // (Optional) add title: '...' to show a separate title line in the tooltip
];
```

License

MIT
