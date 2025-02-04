//packages/flutter_suika_game/lib/route/navigator_key.dart
import 'package:flutter/material.dart';

// Timing issue with reset in GetIt,
// not really good, but treat navigatorKey as a global variable.
final navigatorKey = GlobalKey<NavigatorState>();
