// ===============================
// FILE: lib/main.dart
// Simple app with GetX routes and auto-start onboarding on Home
// ===============================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

import 'match_game_demo.dart';
import 'position_demo.dart';
import 'onboarding_center.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OnboardingCenter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final observer = OnbRouteObserver();
    return GetMaterialApp(
      title: 'Game Onboarding Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/match', page: () => const MatchGameDemo()),
        GetPage(name: '/position', page: () => const PositionDemo()),
      ],
      navigatorObservers: [observer],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _mathBtnKey = GlobalKey(debugLabel: 'mathBtn');
  final GlobalKey _positionBtnKey = GlobalKey(debugLabel: 'positionBtn');

  @override
  void initState() {
    super.initState();
    // Register steps for this route's scope with a lazy builder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingCenter.to.register('home', () => _buildHomeSteps(context));
      // Start once when keys are ready (route observer may also start; it's safe due to "once")
      // ignore: discarded_futures
      OnboardingCenter.to.start(context, 'home', once: true);
    });
  }

  List<OnboardingStep> _buildHomeSteps(BuildContext ctx) {
    return [
      tapStep(
        id: 'open_math_game',
        targetKey: _mathBtnKey,
        // Desentralisasi pemakaian: cukup definisikan step di fitur ini
        description: 'Main Math Game',
        iconPosition: IconPosition.bottomRight,
      ),
      tapStep(
        id: 'lihat_position_demo',
        targetKey: _positionBtnKey,
        description: 'Coba Position Demo',
        iconPosition: IconPosition.bottomLeft,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Onboarding Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 200,
              color: Colors.green,
              key: _mathBtnKey,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/match'),
                child: const Text('Math/Match Game Demo'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: _positionBtnKey,
              onPressed: () => Get.toNamed('/position'),
              child: const Text('Position Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
