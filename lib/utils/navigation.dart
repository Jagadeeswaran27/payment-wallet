import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

void pushToScreen(BuildContext context, String screenPath, {Object? extra}) {
  context.push(screenPath, extra: extra);
}

void pushToScreenNamed(BuildContext context, String screenName) {
  context.pushNamed(screenName);
}

void goToScreen(BuildContext context, String screenPath) {
  context.go(screenPath);
}

void goToScreenNamed(BuildContext context, String screenName) {
  context.goNamed(screenName);
}

void pushReplacementToScreen(BuildContext context, String screenPath) {
  context.pushReplacement(screenPath);
}

void pushReplacementToScreenNamed(BuildContext context, String screenName) {
  context.pushReplacementNamed(screenName);
}

void popScreen(BuildContext context) {
  context.pop();
}
