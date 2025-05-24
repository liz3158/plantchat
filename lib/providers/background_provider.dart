import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundProvider with ChangeNotifier {
  String _currentBackground = 'default';
  String get currentBackground => _currentBackground;

  final List<String> _availableBackgrounds = [
    'default',
    'leaves',
    'flowers',
    'forest',
    'garden',
  ];

  List<String> get availableBackgrounds => _availableBackgrounds;

  BackgroundProvider() {
    _loadBackgroundPreference();
  }

  Future<void> _loadBackgroundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBackground = prefs.getString('chatBackground') ?? 'default';
    notifyListeners();
  }

  Future<void> setBackground(String background) async {
    if (!_availableBackgrounds.contains(background)) return;
    
    _currentBackground = background;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatBackground', background);
    notifyListeners();
  }

  String getBackgroundAsset() {
    switch (_currentBackground) {
      case 'leaves':
        return 'assets/images/leaves_bg.svg';
      case 'flowers':
        return 'assets/images/flowers_bg.svg';
      case 'forest':
        return 'assets/images/forest_bg.svg';
      case 'garden':
        return 'assets/images/garden_bg.svg';
      default:
        return 'assets/images/plant_bg.svg';
    }
  }
} 