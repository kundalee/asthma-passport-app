import 'package:flutter/material.dart';

// Lets services below the widget tree (e.g. ApiClient reacting to a 401)
// trigger navigation without needing a BuildContext of their own.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
