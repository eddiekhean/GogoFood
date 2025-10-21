import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/home_view_model.dart';
import 'package:gogo_food/views/gogo_food_home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel()..startAnimation(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/': (context) => GogoFoodHome()},
      ),
    ),
  );
}
