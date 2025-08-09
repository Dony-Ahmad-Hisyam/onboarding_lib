import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

class MathGameDemo extends StatefulWidget {
  const MathGameDemo({Key? key}) : super(key: key);

  @override
  State<MathGameDemo> createState() => _MathGameDemoState();
}

class _MathGameDemoState extends State<MathGameDemo> {
  late OnboardingController _onboardingController;

  // Tap targets
  final GlobalKey _gameSelectionKey = GlobalKey(debugLabel: 'gameSelectionKey');

  // Drag sources
  final GlobalKey _src3Key = GlobalKey(debugLabel: 'src_3');

  // Drag destinations
  final GlobalKey _dstEmptyKey = GlobalKey(debugLabel: 'dst_empty');

  // Drag-drop progress (generic)
  String? _valueInEmpty; // for dst_empty
  String? _valueOnSeven; // for dst_7
  String? _valueOnTen; // for dst_10

  @override
  void initState() {
    super.initState();
    _initOnboarding();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _onboardingController.start();
      });
    });
  }

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  void _initOnboarding() {
    final steps = [
      tapStep(
        id: 'select_game',
        targetKey: _gameSelectionKey,
        description: 'Choose The Mini-game',
      ),

      // Drag 3 -> empty
      dragStep(
        id: 'drag_number1',
        sourceKey: _src3Key,
        destinationKey: _dstEmptyKey,
        description: 'Play, Learn and Earn Coins',
      ),
      // Drag 2 -> 7
    ];

    _onboardingController = ob(
      steps: steps,
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding completed! Great job!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _onboardingController.start(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGameSelection(),
          Expanded(child: _buildMathGame()),
        ],
      ),
    ).withOnboarding(_onboardingController);
  }

  Widget _buildGameSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Choose a Mini-game',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Container(
                  key: _gameSelectionKey,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videogame_asset, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Math Game', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathGame() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Text('2. Play, Learn and Earn Coins',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 24),
            _buildMathProblem(),
            const SizedBox(height: 40),
            _buildNumberOptions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMathProblem() {
    return Container(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Destination 10
              DragTarget<String>(
                onWillAccept: (d) => d == '4' && _valueOnTen == null,
                onAccept: (d) => setState(() => _valueOnTen = d),
                builder: (context, cand, _) {
                  final color = _valueOnTen != null
                      ? Colors.green
                      : (cand.isNotEmpty
                          ? Colors.purple.shade700
                          : Colors.purple);
                  return _buildNumberCircle('10', color);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Destination 7
              DragTarget<String>(
                onWillAccept: (d) => d == '2' && _valueOnSeven == null,
                onAccept: (d) => setState(() => _valueOnSeven = d),
                builder: (context, cand, _) {
                  final color = _valueOnSeven != null
                      ? Colors.green
                      : (cand.isNotEmpty
                          ? Colors.purple.shade700
                          : Colors.purple);
                  return _buildNumberCircle('7', color);
                },
              ),
              const Text('+',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              // Destination empty
              DragTarget<String>(
                key: _dstEmptyKey,
                onWillAccept: (d) => d == '3' && _valueInEmpty == null,
                onAccept: (d) => setState(() => _valueInEmpty = d),
                builder: (context, cand, _) {
                  final highlight = cand.isNotEmpty;
                  final hasValue = _valueInEmpty != null;
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: hasValue ? Colors.purple : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            highlight ? Colors.purple.shade700 : Colors.purple,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        hasValue ? _valueInEmpty! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCircle(String number, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Source 3
        Builder(builder: (context) {
          final number = '3';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueInEmpty == null;
          final circleWithKey = Container(key: _src3Key, child: circle);
          return enabled
              ? Draggable<String>(
                  data: number,
                  child: circleWithKey,
                  childWhenDragging:
                      Opacity(opacity: 0.2, child: circleWithKey),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circleWithKey);
        }),
        const SizedBox(width: 16),
        // Source 4
        Builder(builder: (context) {
          final number = '4';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueOnTen == null;
          final circleWithKey = Container(child: circle);
          return enabled
              ? Draggable<String>(
                  data: number,
                  child: circleWithKey,
                  childWhenDragging:
                      Opacity(opacity: 0.2, child: circleWithKey),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circleWithKey);
        }),
        const SizedBox(width: 16),
        // Source 2
        Builder(builder: (context) {
          final number = '2';
          final circle = Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          );
          final feedback = Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
          final enabled = _valueOnSeven == null;
          final circleWithKey = Container(child: circle);
          return enabled
              ? Draggable<String>(
                  data: number,
                  child: circleWithKey,
                  childWhenDragging:
                      Opacity(opacity: 0.2, child: circleWithKey),
                  feedback: feedback,
                )
              : Opacity(opacity: 0.4, child: circleWithKey);
        }),
      ],
    );
  }
}
