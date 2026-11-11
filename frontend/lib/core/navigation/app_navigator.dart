import 'package:flutter/material.dart';

class AppNavigator {
  const AppNavigator._();

  static Route<T> route<T>(Widget page) {
    return MaterialPageRoute<T>(builder: (_) => page);
  }

  static Route<T> material<T>({required WidgetBuilder builder}) {
    return MaterialPageRoute<T>(builder: builder);
  }

  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).push<T>(route<T>(page));
  }

  static Future<T?> replace<T>(
    BuildContext context,
    Widget page, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushReplacement<T, void>(route<T>(page));
  }

  static Future<T?> replaceAll<T>(
    BuildContext context,
    Widget page, {
    bool rootNavigator = false,
  }) {
    return replaceAllRoute<T>(
      context,
      route<T>(page),
      rootNavigator: rootNavigator,
    );
  }

  static Future<T?> replaceAllRoute<T>(
    BuildContext context,
    Route<T> route, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushAndRemoveUntil<T>(route, (_) => false);
  }
}








