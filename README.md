# onboarding_lib

Perpustakaan Flutter untuk membuat onboarding interaktif (tap dan drag & drop) dengan overlay highlight dan tooltip cerdas, tanpa ketergantungan eksternal.

Fitur Utama

- Highlight langsung terlihat dari langkah pertama
- Tooltip cerdas: menghindari area highlight, koridor drag, dan node sumber/tujuan
- Drag & drop generik (payload tipe apa pun)
- API ringkas: tapStep, dragStep, ob, withOnboarding
- Wrapper generik: ObDraggable<T>, ObDragTarget<T>
- Opsi binding via ID: OnboardingKeyStore + tapStepById/dragStepById (opsional)
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

Rekomendasi “best way” (tanpa ID): gunakan GlobalKey + ObDraggable/ObDragTarget dan langkah tapStep/dragStep.

1. Tandai widget target dengan GlobalKey

```dart
final GlobalKey btnKey = GlobalKey();

ElevatedButton(
  key: btnKey,
  onPressed: () {},
  child: const Text('Mulai'),
)
```

2. Untuk drag & drop, bungkus sumber dan tujuan

- Sumber (draggable):

```dart
final GlobalKey srcKey = GlobalKey();

ObDraggable<String>(
  keyRef: srcKey,
  data: 'apel',
  child: buildChip('Apel'),
  childWhenDragging: Opacity(opacity: 0.2, child: buildChip('Apel')),
  feedback: Material(color: Colors.transparent, child: buildChip('Apel')),
)
```

- Tujuan (drag target):

```dart
final GlobalKey dstKey = GlobalKey();

ObDragTarget<String>(
  keyRef: dstKey,
  canAccept: (d) => d == 'apel',
  onAccept: (d) => setState(() => _picked = d),
  builder: (context, candidates, _) => buildDropSlot(_picked, candidates),
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
    id: 'drag_apel',
    sourceKey: srcKey,
    destinationKey: dstKey,
    title: 'Seret Item',
    description: 'Seret item dari sumber ke tujuan.',
    // default drag: position = TooltipPosition.top,
    // anchor = DragTooltipAnchor.destination (tooltip prefer dekat tujuan)
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

7. Contoh drag multi (seperti di example):

- Seret “4” ke lingkaran “10”
- Seret “2” ke lingkaran “7”
- Seret “3” ke lingkaran kosong

Gunakan tiga GlobalKey untuk sumber (4, 2, 3) dan tiga GlobalKey untuk tujuan (10, 7, empty), lalu definisikan tiga dragStep sesuai pasangan.

Kustomisasi Tooltip & Overlay

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (drag default: destination)
- OnboardingConfig.tooltipConfig: atur warna, teks, maxWidth, padding, margin, borderRadius, dll.
- targetPadding: atur jarak padding highlight dari target

Best Practices

- Panggil controller.start() setelah frame pertama (post-frame) untuk akurasi posisi.
- Gunakan GlobalKey yang stabil pada setiap target/sumber.
- Untuk drag, biarkan anchor tooltip di destination agar jalur drag tidak tertutup.
- Hindari rebuild yang mengganti GlobalKey saat onboarding aktif.

Troubleshooting

- Tooltip menutupi target/koridor drag: default dragStep sudah mengarahkan tooltip ke dekat tujuan dan engine menghindari area konflik. Sesuaikan position bila diperlukan.
- Overlay tidak muncul di langkah awal: pastikan start() dipanggil setelah layout siap.
- Target tidak terdeteksi: cek GlobalKey terpasang pada widget yang dirender.

Opsi: Binding Berbasis ID (Indonesia)

Jika ingin tanpa menyimpan banyak GlobalKey, gunakan OnboardingKeyStore dan helper tapStepById/dragStepById.

- Tandai widget dengan key dari store:

```dart
final keys = OnboardingKeyStore.instance;

ObDraggable<String>(keyRef: keys.key('src_apel'), data: 'apel', child: ..., feedback: ...);
ObDragTarget<String>(keyRef: keys.key('dst_keranjang'), canAccept: ..., onAccept: ..., builder: ...);
```

- Definisikan langkah dengan helper berbasis ID:

```dart
final steps = [
  tapStepById(
    id: 'welcome',
    targetId: 'btn_mulai',
    title: 'Mulai',
    description: 'Ketuk untuk memulai.',
  ),
  dragStepById(
    id: 'drag_apel',
    sourceId: 'src_apel',
    destinationId: 'dst_keranjang',
    title: 'Seret Item',
    description: 'Seret dari sumber ke tujuan.',
  ),
];
```

Contoh Lengkap

Lihat folder `example/` untuk contoh Math Game:

- Menggunakan tapStep, dragStep, ob, withOnboarding
- Wrapper ObDraggable/ObDragTarget (payload String)
- Multi drag (4→10, 2→7, 3→empty)

---

Complete Tutorial (English)

Recommended “best way” (no IDs): use GlobalKey + ObDraggable/ObDragTarget with tapStep/dragStep.

1. Attach a GlobalKey to any widget you want to highlight

```dart
final GlobalKey btnKey = GlobalKey();
ElevatedButton(key: btnKey, onPressed: () {}, child: const Text('Start'));
```

2. For drag & drop, wrap sources and destinations

- Source:

```dart
final GlobalKey sourceKey = GlobalKey();

ObDraggable<Item>(
  keyRef: sourceKey,
  data: item,
  child: buildItem(item),
  childWhenDragging: Opacity(opacity: 0.2, child: buildItem(item)),
  feedback: Material(color: Colors.transparent, child: buildItem(item)),
)
```

- Destination:

```dart
final GlobalKey destKey = GlobalKey();

ObDragTarget<Item>(
  keyRef: destKey,
  canAccept: (it) => canDrop(it),
  onAccept: (it) => setState(() => place(it)),
  builder: (context, candidates, _) => buildSlot(candidates),
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
    id: 'drag_item',
    sourceKey: sourceKey,
    destinationKey: destKey,
    title: 'Drag Item',
    description: 'Drag the item from source to destination.',
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

7. Multi-drag example (as in the sample app):

- Drag “4” → circle “10”
- Drag “2” → circle “7”
- Drag “3” → empty circle

Create GlobalKeys for each source/destination pair and add one dragStep per pair.

Customization

- TooltipPosition: top, bottom, left, right, auto
- DragTooltipAnchor: auto, source, destination (drag defaults to destination)
- TooltipConfig: colors, text, maxWidth, padding, margin, borderRadius, styles
- targetPadding to adjust highlight padding

Best Practices

- Call controller.start() in a post-frame callback.
- Keep GlobalKeys stable for all highlighted widgets.
- For drag flows, prefer anchoring tooltips near the destination to avoid covering the corridor.
- Avoid rebuilding widgets that would recreate GlobalKeys during onboarding.

Troubleshooting

- Tooltip overlaps highlight/drag corridor: default drag placement prefers destination and the engine avoids conflict zones; adjust position if needed.
- Overlay not visible on the first step: ensure start() is called after layout.
- Target not detected: ensure GlobalKeys are set on rendered widgets.

Optional: ID-based Binding (English)

If you prefer not to keep many GlobalKeys in state, use OnboardingKeyStore with tapStepById/dragStepById.

```dart
final keys = OnboardingKeyStore.instance;
ObDraggable<Item>(keyRef: keys.key('src_item'), data: item, child: ..., feedback: ...);
ObDragTarget<Item>(keyRef: keys.key('dst_slot'), canAccept: ..., onAccept: ..., builder: ...);

final steps = [
  tapStepById(id: 'welcome', targetId: 'btn_start', title: 'Start', description: 'Tap to start.'),
  dragStepById(id: 'drag_item', sourceId: 'src_item', destinationId: 'dst_slot', title: 'Drag', description: 'Drag from source to slot.'),
];
```

License

MIT
