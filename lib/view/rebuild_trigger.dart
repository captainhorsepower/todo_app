import 'package:flutter/material.dart';

class RebuildTrigger with ChangeNotifier {

  void trigger() {
    notifyListeners();
  }
  
}
