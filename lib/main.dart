import 'package:flutter/material.dart';

import 'app.dart';
import 'di.dart';

void main() {
  configureDependencies();
  runApp(const App());
}
