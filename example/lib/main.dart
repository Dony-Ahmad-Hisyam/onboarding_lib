import 'package:example/match_game_demo.dart';
import 'package:example/position_demo.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Onboarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomePage(),
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

  late OnboardingController _homeOnboarding;

  @override
  void initState() {
    super.initState();

    _homeOnboarding = OnboardingController(
      config: OnboardingConfig(
        steps: [
          OnboardingStep(
            id: 'open_math_game',
            targetKey: _mathBtnKey,
            title: 'Mulai dari sini',
            description:
                'Tap tombol ini untuk membuka Math Game. Onboarding akan memandu kamu di halaman berikutnya.',
            interactionType: InteractionType.tap,
            position: TooltipPosition.auto,
            iconPosition: IconPosition.center,
            hintIconColor: Colors.greenAccent,
            hintIcon: Icons.touch_app,
            onComplete: () {
              // Navigasi ke halaman game ketika step selesai
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MathGameDemo()),
              );
            },
          ),
          OnboardingStep(
            id: 'lihat_position_demo',
            targetKey: _positionBtnKey,
            title: 'Atau coba Position Demo',
            description: 'Kamu juga bisa membuka demo posisi tooltip di sini.',
            interactionType: InteractionType.tap,
            position: TooltipPosition.auto,
            iconPosition: IconPosition.center,
            hintIconColor: Colors.greenAccent,
            hintIcon: Icons.touch_app,
            onComplete: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PositionDemo()),
              );
            },
          ),
        ],
        // Samakan konfigurasi tooltip seperti di MathGameDemo
        tooltipConfig: const TooltipConfig(
          backgroundColor: Color(0xFF6750A4),
          textColor: Colors.white,
          maxWidth: 320,
          padding: EdgeInsets.all(16),
        ),
        overlayOpacity: 0.7,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mulai onboarding di halaman Home
      _homeOnboarding.start();
    });
  }

  @override
  void dispose() {
    _homeOnboarding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingOverlay(
      controller: _homeOnboarding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Onboarding Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                key: _mathBtnKey,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MathGameDemo(),
                    ),
                  );
                },
                child: const Text('Math Game Demo'),
              ),
              ElevatedButton(
                key: _positionBtnKey,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const PositionDemo()),
                  );
                },
                child: const Text('Position Demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
