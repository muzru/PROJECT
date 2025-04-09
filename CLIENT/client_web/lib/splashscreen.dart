import 'dart:async';
import 'package:client_web/welcome.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart'; // Make sure this is in your pubspec.yaml

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutBack,
    );

    _logoController.forward();

    // ✅ Play OGG sound on web
    _audioPlayer
        .play(AssetSource('assets/mixkit-cool-impact-movie-trailer-2909.ogg'));

    // ⏳ Navigate to WelcomePage after delay
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌿 Forest Background Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/forest_background.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          // 🌫️ Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 🔥 Logo & Text Centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💡 Glowing Logo Animation
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.8),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/newlogo.png',
                      width: 130,
                      height: 130,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔠 Animated Text
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.greenAccent,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Skill Connect'),
                      TyperAnimatedText('Skill Meets Success'),
                    ],
                    isRepeatingAnimation: false,
                    pause: const Duration(milliseconds: 800),
                  ),
                ),
                const SizedBox(height: 20),

                // 🕓 Loading Bar
                SizedBox(
                  width: 120,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    color: Colors.greenAccent,
                    minHeight: 5,
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
