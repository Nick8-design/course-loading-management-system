
import 'package:flutter/cupertino.dart';

class WavyAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20); // Start at the bottom-left

    /// 🎵 Create a wave effect
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(size.width * 0.75, size.height - 40, size.width, size.height - 20);

    path.lineTo(size.width, 0); // Top right
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/*
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WavyAppBarScreen(),
  ));
}

class WavyAppBarScreen extends StatefulWidget {
  @override
  _WavyAppBarScreenState createState() => _WavyAppBarScreenState();
}

class _WavyAppBarScreenState extends State<WavyAppBarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Wave speed
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipPath(
              clipper: AnimatedWavyAppBarClipper(_controller.value),
              child: AppBar(
                title: Text("Water Wave AppBar"),
                backgroundColor: Colors.blue,
                centerTitle: true,
                elevation: 0,
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Text(
          "Wavy Water AppBar!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// 🌊 **Animated Water-Like Clipper**
class AnimatedWavyAppBarClipper extends CustomClipper<Path> {
  final double animationValue;

  AnimatedWavyAppBarClipper(this.animationValue);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);

    // Sinusoidal wave effect
    double waveHeight = 20;
    double waveLength = size.width / 4;
    for (double i = 0; i <= size.width; i += waveLength) {
      double x = i;
      double y = size.height - 30 + sin((animationValue * 2 * pi) + (i / size.width * 2 * pi)) * waveHeight;
      path.quadraticBezierTo(x - waveLength / 2, y - waveHeight, x, y);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

 */