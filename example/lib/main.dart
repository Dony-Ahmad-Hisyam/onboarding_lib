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

    final steps = [
      tapStep(
        id: 'open_math_game',
        targetKey: _mathBtnKey,
        title: 'Mulai dari sini',
        description:
            'Tap tombol ini untuk membuka Math Game. Onboarding akan memandu kamu di halaman berikutnya.',
        onComplete: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MathGameDemo()),
          );
        },
      ),
      tapStep(
        id: 'lihat_position_demo',
        targetKey: _positionBtnKey,
        title: 'Atau coba Position Demo',
        description: 'Kamu juga bisa membuka demo posisi tooltip di sini.',
        onComplete: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PositionDemo()),
          );
        },
      ),
    ];

    _homeOnboarding = ob(steps: steps);

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
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Game Onboarding Demo'),
      ),
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MathGameDemo(),
                    ),
                  );
                },
                child: const Text('Math Game Demo'),
              ),
            ),
            ElevatedButton(
              key: _positionBtnKey,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PositionDemo()),
                );
              },
              child: const Text('Position Demo'),
            ),
          ],
        ),
      ),
    );
    return scaffold.withOnboarding(_homeOnboarding);
  }
}
