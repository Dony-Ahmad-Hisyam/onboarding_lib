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
