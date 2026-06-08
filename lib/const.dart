import 'package:flutter/material.dart';
import 'package:promptseen/Admob/app_config.dart';

/// App color palette.
///
/// Colors are driven by the server via [AppConfig] (fetched in the splash
/// screen and cached to disk). Change the JSON at the remote config URL to
/// re-theme the whole app on the next launch — no app update needed.
/// If the server sends nothing, the Ocean Blue (dark) defaults in
/// [AppConfig] are used.
class AppColor {
  static Color _parse(String hex) =>
      Color(int.parse(hex, radix: 16));

  /// Primary brand color (buttons, highlights, gradients).
  static Color get themColors => _parse(AppConfig.themePrimary);

  /// Secondary / accent color.
  static Color get accent => _parse(AppConfig.themeAccent);

  /// Scaffold / app background.
  static Color get primaryColor => _parse(AppConfig.themeBackground);

  /// Surface / card background.
  static Color get secoundaryColor => _parse(AppConfig.themeSurface);

  static Color get cardBackground => _parse(AppConfig.themeSurface);

  /// Primary text color (server-driven).
  static Color get primary => _parse(AppConfig.themeText);

  // Fixed colors that should not change with theme.
  static Color black = Colors.black;
  static Color white = Colors.white;
}
