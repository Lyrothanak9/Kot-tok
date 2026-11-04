import 'package:flutter/material.dart';

class BottomAppBarProvider with ChangeNotifier {
  bool _showFab = true;
  bool _showNotch = true;
  FloatingActionButtonLocation _fabLocation = FloatingActionButtonLocation.endDocked;
  int _currentIndex = 0; // Added for screen navigation
  bool _isGridView = false; // Layout view toggle (single list vs grid)

  bool get showFab => _showFab;
  bool get showNotch => _showNotch;
  FloatingActionButtonLocation get fabLocation => _fabLocation;
  int get currentIndex => _currentIndex;
  bool get isGridView => _isGridView;

  void setShowFab(bool value) {
    _showFab = value;
    notifyListeners();
  }

  void setShowNotch(bool value) {
    _showNotch = value;
    notifyListeners();
  }

  void setFabLocation(FloatingActionButtonLocation value) {
    _fabLocation = value;
    notifyListeners();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleGridView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }
}