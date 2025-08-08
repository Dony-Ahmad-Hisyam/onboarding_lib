# onboarding_lib

Perpustakaan Flutter untuk membuat onboarding interaktif (tap dan drag & drop) dengan overlay highlight dan tooltip cerdas, tanpa ketergantungan eksternal.

Fitur Utama

- Highlight langsung terlihat di langkah pertama
- Tooltip cerdas: menghindari area highlight, koridor drag, dan node sumber/tujuan
- Drag & drop generik (payload apa pun)
- API ringkas: tapStep, dragStep, ob, withOnboarding
- Best way sederhana: GlobalKey + Draggable/DragTarget (tanpa wrapper)
- Alternatif opsional: ObDraggable/ObDragTarget dan binding via ID (tapStepById/dragStepById)
- Kustomisasi penuh: warna overlay, padding target, gaya tooltip, dll.

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
final GlobalKey btnKey = GlobalKey();

ElevatedButton(
  key: btnKey,
  onPressed: () {},
  child: const Text('Mulai'),
)
```

2. Untuk drag & drop, pakai Draggable/DragTarget biasa dengan GlobalKey

- Sumber (Draggable):

```dart
final GlobalKey srcKey = GlobalKey();

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
final GlobalKey dstKey = GlobalKey();

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
  tapStep(
    id: 'welcome',
    targetKey: btnKey,
    title: 'Mulai',
    description: 'Ketuk tombol ini untuk memulai.',
  ),
  dragStep(
    id: 'drag_4_to_10',
    sourceKey: srcKey,
    destinationKey: dstKey,
    title: 'Seret Angka',
    description: 'Seret angka dari sumber ke lingkaran tujuan.',
    // default drag: position = TooltipPosition.top,
    // anchor = DragTooltipAnchor.destination
  ),
];
```

4. Buat controller dengan ob(...)

```dart
final controller = ob(
  steps: steps,
  overlayColor: Colors.black,
  overlayOpacity: 0.7,
  targetPadding: 8,
  tooltip: const TooltipConfig(
    backgroundColor: Color(0xFF6750A4),
    textColor: Colors.white,
    maxWidth: 320,
    padding: EdgeInsets.all(16),
  ),
  onComplete: () {
    // selesai onboarding
  },
);
```

5. Bungkus root dengan withOnboarding(...)

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Contoh')),
  body: ...,
).withOnboarding(controller);
```

6. Mulai onboarding (setelah layout siap)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  controller.start();
});
```

7. Multi-drag seperti contoh (Math Game)

- Seret “4” → lingkaran “10”
- Seret “2” → lingkaran “7”
- Seret “3” → lingkaran kosong

Buat tiga GlobalKey untuk sumber (4, 2, 3) dan tiga GlobalKey untuk tujuan (10, 7, empty), lalu tambahkan tiga dragStep sesuai pasangannya. Lihat `example/lib/match_game_demo.dart` untuk implementasi lengkap satu file.

Kustomisasi

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (default drag: destination)
- OnboardingConfig.tooltipConfig: atur warna, teks, maxWidth, padding, margin, borderRadius, dsb.
- targetPadding: jarak highlight dari target

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
  tapStepById(id: 'welcome', targetId: 'btn_start', title: 'Mulai', description: 'Tap untuk mulai'),
  dragStepById(id: 'drag_4_to_10', sourceId: 'src_4', destinationId: 'dst_10', title: 'Seret', description: 'Seret ke tujuan'),
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
final GlobalKey btnKey = GlobalKey();
ElevatedButton(key: btnKey, onPressed: () {}, child: const Text('Start'));
```

2. For drag & drop, use plain Draggable/DragTarget with GlobalKeys

- Source (Draggable):

```dart
final GlobalKey sourceKey = GlobalKey();

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
final GlobalKey destKey = GlobalKey();

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
  tapStep(
    id: 'welcome',
    targetKey: btnKey,
    title: 'Start',
    description: 'Tap this button to get started.',
  ),
  dragStep(
    id: 'drag_4_to_10',
    sourceKey: sourceKey,
    destinationKey: destKey,
    title: 'Drag Number',
    description: 'Drag the number from source to the destination circle.',
  ),
];
```

4. Create the controller

```dart
final controller = ob(
  steps: steps,
  overlayColor: Colors.black,
  overlayOpacity: 0.7,
  targetPadding: 8,
  tooltip: const TooltipConfig(
    backgroundColor: Color(0xFF6750A4),
    textColor: Colors.white,
    maxWidth: 320,
    padding: EdgeInsets.all(16),
  ),
);
```

5. Wrap your root

```dart
return Scaffold(...).withOnboarding(controller);
```

6. Start after the first frame

```dart
WidgetsBinding.instance.addPostFrameCallback((_) => controller.start());
```

7. Multi-drag (as in the sample app)

- Drag “4” → circle “10”
- Drag “2” → circle “7”
- Drag “3” → empty circle

Create GlobalKeys for each source/destination pair and add one dragStep per pair. See `example/lib/match_game_demo.dart` for a single-file implementation.

Customization

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (drag defaults to destination)
- TooltipConfig: colors, text, maxWidth, padding, margin, borderRadius, styles
- targetPadding adjusts highlight padding

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
  tapStepById(id: 'welcome', targetId: 'btn_start', title: 'Start', description: 'Tap to start'),
  dragStepById(id: 'drag_4_to_10', sourceId: 'src_4', destinationId: 'dst_10', title: 'Drag', description: 'Drag from source to destination'),
];
```

License

MIT
