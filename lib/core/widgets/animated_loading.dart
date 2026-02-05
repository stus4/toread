import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import '../../features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final String userId;

  const SplashScreen({super.key, required this.userId});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _topWaveController;
  late AnimationController _bottomWaveController;
  late Animation<Offset> _topWaveOffset;
  late Animation<Offset> _bottomWaveOffset;

  @override
  void initState() {
    super.initState();

    // Запускаємо анімації
    _topWaveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _bottomWaveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _topWaveOffset =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _topWaveController, curve: Curves.easeOut));
    _bottomWaveOffset =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _bottomWaveController, curve: Curves.easeOut));

    _topWaveController.forward();
    _bottomWaveController.forward();

    // Перехід до головної сторінки через 3 секунди
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: widget.userId),
        ),
      );
    });
  }

  @override
  void dispose() {
    _topWaveController.dispose();
    _bottomWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: Stack(
        children: [
          // нижні хвилі
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _bottomWaveOffset,
              child: Image.asset('assets/wave_bottom_2.png', fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _topWaveOffset,
              child: Image.asset('assets/wave_bottom_1.png', fit: BoxFit.cover),
            ),
          ),

          // верхні хвилі
          Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _bottomWaveOffset,
              child: Image.asset('assets/wave_top_2.png', fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _topWaveOffset,
              child: Image.asset('assets/wave_top_1.png', fit: BoxFit.cover),
            ),
          ),

          // центр: логотип і назва
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  '2Read',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4037),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
