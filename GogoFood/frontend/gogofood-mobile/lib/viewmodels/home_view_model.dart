import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _visibleIndex = -1;
  int get visibleIndex => _visibleIndex;

  bool _isAnimationDone = false;
  bool get isAnimationDone => _isAnimationDone;

  Future startAnimation() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      _visibleIndex = i;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isAnimationDone = true;
    notifyListeners();
  }
}
