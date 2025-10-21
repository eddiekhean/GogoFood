import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/home_view_model.dart';
import 'package:gogo_food/viewmodels/welcome_view_model.dart';
import 'package:gogo_food/views/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GogoFoodHome extends StatefulWidget {
  const GogoFoodHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GogoFoodHome();
  }
}

class _GogoFoodHome extends State<GogoFoodHome> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HomeViewModel>(context, listen: false).startAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    if (viewModel.isAnimationDone) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, _, __) => ChangeNotifierProvider(
              create: (_) => WelcomeViewModel(),
              child: WelcomeScreen(),
            ),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      });
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE13454), Color(0xFFE1434D), Color(0xFFDF7734)],
              stops: [0.0, 0.23, 1.0],
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                Center(child: _buildTitleSection()),
                _buildAnimatedImages(context, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GoGoFood',
              style: GoogleFonts.fredoka(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset('assets/images/home_icon.png'),
          ],
        ),
        Text(
          'GoGoFood: Every Bite, an Adventure!',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedImages(BuildContext context, HomeViewModel vm) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: AnimatedOpacity(
            opacity: vm.visibleIndex >= 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Image.asset('assets/images/home1.png'),
          ),
        ),
        Positioned(
          bottom: 80,
          left: MediaQuery.of(context).size.width / 2 - 100,
          child: AnimatedOpacity(
            opacity: vm.visibleIndex >= 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Image.asset('assets/images/home2.png'),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: vm.visibleIndex >= 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Image.asset('assets/images/home3.png'),
          ),
        ),
      ],
    );
  }
}
