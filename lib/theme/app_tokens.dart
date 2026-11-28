import 'package:flutter/material.dart';

/// ===========================================================================
/// DESIGN TOKENS: Gojek-inspired
///
/// Tiga lapisan (mengikuti static/css/tokens.css pada proyek web):
///   1. Primitive : nilai mentah (AppPalette) — jangan dipakai langsung di UI.
///   2. Semantic  : makna/peran, beda per tema (AppSemantic, lewat context.tokens).
///   3. Scale     : spacing, radius, motion, typography (AppSpace, dst.).
///
/// Aturan: widget hanya memakai token semantic + scale, bukan hex/angka.
/// ===========================================================================

/// 1) PRIMITIVE — palet mentah.
abstract final class AppPalette {
  // Green
  static const green50 = Color(0xFFE8F8EA);
  static const green100 = Color(0xFFC6EFCB);
  static const green200 = Color(0xFF98E0A1);
  static const green300 = Color(0xFF63CE70);
  static const green400 = Color(0xFF2FBB41);
  static const green500 = Color(0xFF00AA13); // brand
  static const green600 = Color(0xFF009A11);
  static const green700 = Color(0xFF00880F); // action (kontras AA dengan putih)
  static const green800 = Color(0xFF00690C);
  static const green900 = Color(0xFF004A08);

  // Neutrals (ink)
  static const ink0 = Color(0xFFFFFFFF);
  static const ink25 = Color(0xFFFAFAFA);
  static const ink50 = Color(0xFFF4F5F4);
  static const ink100 = Color(0xFFEBEDEB);
  static const ink200 = Color(0xFFDFE2DF);
  static const ink300 = Color(0xFFC9CDC9);
  static const ink400 = Color(0xFF9AA09A);
  static const ink500 = Color(0xFF6F756F);
  static const ink600 = Color(0xFF565C56);
  static const ink700 = Color(0xFF3F443F);
  static const ink800 = Color(0xFF2A2D2A);
  static const ink850 = Color(0xFF1F221F);
  static const ink900 = Color(0xFF151715);
  static const ink950 = Color(0xFF0B0C0B);

  // Status & accent
  static const red50 = Color(0xFFFDECEC);
  static const red500 = Color(0xFFE5262F);
  static const red600 = Color(0xFFC91F27);
  static const red700 = Color(0xFFA3161D);
  static const orange500 = Color(0xFFF28C00);
  static const yellow50 = Color(0xFFFFF6DD);
  static const yellow400 = Color(0xFFFFC12E);
  static const yellow700 = Color(0xFF8A5A00);
  static const blue50 = Color(0xFFE8F1FD);
  static const blue500 = Color(0xFF1A73E8);
  static const blue700 = Color(0xFF0F4FA8);
}

/// 2) SEMANTIC — peran warna; nilai berbeda untuk light & dark.
@immutable
class AppSemantic extends ThemeExtension<AppSemantic> {
  const AppSemantic({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.textOnAction,
    required this.brand,
    required this.action,
    required this.actionHover,
    required this.actionPress,
    required this.actionSoft,
    required this.actionText,
    required this.danger,
    required this.dangerSoft,
    required this.dangerText,
    required this.warningSoft,
    required this.warningText,
    required this.infoSoft,
    required this.infoText,
    required this.ring,
    required this.overlay,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.shadowBrand,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;

  final Color text;
  final Color textMuted;
  final Color textSubtle;
  final Color textOnAction;

  final Color brand;
  final Color action;
  final Color actionHover;
  final Color actionPress;
  final Color actionSoft;
  final Color actionText;

  final Color danger;
  final Color dangerSoft;
  final Color dangerText;
  final Color warningSoft;
  final Color warningText;
  final Color infoSoft;
  final Color infoText;

  final Color ring;
  final Color overlay;

  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;
  final List<BoxShadow> shadowBrand;

  Color get dangerStrong => AppPalette.red700;
  Color get onBrand => Colors.white;

  // Mulai dari green700 agar teks putih di atasnya tetap lolos kontras AA.
  LinearGradient get heroGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.green700, AppPalette.green800],
  );

  static List<BoxShadow> _shadow(
    Color c,
    double a1,
    double b1,
    double y1, [
    double s1 = 0,
  ]) => [
    BoxShadow(
      color: c.withValues(alpha: a1),
      blurRadius: b1,
      offset: Offset(0, y1),
      spreadRadius: s1,
    ),
  ];

  static final light = AppSemantic(
    bg: AppPalette.ink50,
    surface: AppPalette.ink0,
    surface2: AppPalette.ink25,
    surfaceSunken: AppPalette.ink100,
    border: AppPalette.ink200,
    borderStrong: AppPalette.ink300,
    text: AppPalette.ink900,
    textMuted: AppPalette.ink600,
    textSubtle: AppPalette.ink500,
    textOnAction: Colors.white,
    brand: AppPalette.green500,
    action: AppPalette.green700,
    actionHover: AppPalette.green800,
    actionPress: AppPalette.green900,
    actionSoft: AppPalette.green50,
    actionText: AppPalette.green700,
    danger: AppPalette.red500,
    dangerSoft: AppPalette.red50,
    dangerText: AppPalette.red700,
    warningSoft: AppPalette.yellow50,
    warningText: AppPalette.yellow700,
    infoSoft: AppPalette.blue50,
    infoText: AppPalette.blue700,
    ring: AppPalette.green500.withValues(alpha: 0.45),
    overlay: AppPalette.ink950.withValues(alpha: 0.55),
    shadowSm: _shadow(AppPalette.ink900, 0.08, 3, 1),
    shadowMd: _shadow(AppPalette.ink900, 0.12, 16, 6, -4),
    shadowLg: _shadow(AppPalette.ink900, 0.20, 40, 18, -12),
    shadowBrand: _shadow(AppPalette.green700, 0.55, 24, 10, -8),
  );

  static final dark = AppSemantic(
    bg: AppPalette.ink950,
    surface: AppPalette.ink900,
    surface2: AppPalette.ink850,
    surfaceSunken: AppPalette.ink800,
    border: AppPalette.ink800,
    borderStrong: AppPalette.ink700,
    text: const Color(0xFFF2F4F2),
    textMuted: AppPalette.ink300,
    textSubtle: AppPalette.ink400,
    textOnAction: Colors.white,
    brand: AppPalette.green500,
    action: AppPalette.green700,
    actionHover: AppPalette.green600,
    actionPress: AppPalette.green800,
    actionSoft: AppPalette.green500.withValues(alpha: 0.16),
    actionText: AppPalette.green300,
    danger: AppPalette.red500,
    dangerSoft: AppPalette.red500.withValues(alpha: 0.16),
    dangerText: const Color(0xFFFF8A90),
    warningSoft: AppPalette.yellow400.withValues(alpha: 0.16),
    warningText: AppPalette.yellow400,
    infoSoft: AppPalette.blue500.withValues(alpha: 0.18),
    infoText: const Color(0xFF8AB8F5),
    ring: AppPalette.green300.withValues(alpha: 0.5),
    overlay: Colors.black.withValues(alpha: 0.65),
    shadowSm: _shadow(Colors.black, 0.5, 3, 1),
    shadowMd: _shadow(Colors.black, 0.6, 20, 8, -6),
    shadowLg: _shadow(Colors.black, 0.75, 44, 20, -14),
    shadowBrand: _shadow(AppPalette.green500, 0.4, 24, 10, -8),
  );

  @override
  AppSemantic copyWith() => this;

  @override
  AppSemantic lerp(ThemeExtension<AppSemantic>? other, double t) {
    if (other is! AppSemantic) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemantic(
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textSubtle: c(textSubtle, other.textSubtle),
      textOnAction: c(textOnAction, other.textOnAction),
      brand: c(brand, other.brand),
      action: c(action, other.action),
      actionHover: c(actionHover, other.actionHover),
      actionPress: c(actionPress, other.actionPress),
      actionSoft: c(actionSoft, other.actionSoft),
      actionText: c(actionText, other.actionText),
      danger: c(danger, other.danger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      dangerText: c(dangerText, other.dangerText),
      warningSoft: c(warningSoft, other.warningSoft),
      warningText: c(warningText, other.warningText),
      infoSoft: c(infoSoft, other.infoSoft),
      infoText: c(infoText, other.infoText),
      ring: c(ring, other.ring),
      overlay: c(overlay, other.overlay),
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t)!,
      shadowMd: BoxShadow.lerpList(shadowMd, other.shadowMd, t)!,
      shadowLg: BoxShadow.lerpList(shadowLg, other.shadowLg, t)!,
      shadowBrand: BoxShadow.lerpList(shadowBrand, other.shadowBrand, t)!,
    );
  }
}

/// Akses ringkas: `context.tokens.surface`.
extension AppTokensX on BuildContext {
  AppSemantic get tokens => Theme.of(this).extension<AppSemantic>()!;
}

/// 3) SCALE — spacing (basis 4px).
abstract final class AppSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// Radius.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double x2 = 32;
  static const double pill = 999;

  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
}

/// Motion.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 380);

  static const Curve easeOut = Cubic(0.22, 1, 0.36, 1);
  static const Curve easeInOut = Cubic(0.65, 0, 0.35, 1);
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);
}

/// Layout.
abstract final class AppLayout {
  /// Lebar konten maksimum agar nyaman di Chrome/tablet.
  static const double maxContentWidth = 600;
  static const double minTapTarget = 48;
}

/// Typography: skala dari tokens.css (xs 12 … 2xl 36), Plus Jakarta Sans.
abstract final class AppType {
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double x2 = 36;

  static const double lhTight = 1.1;
  static const double lhSnug = 1.3;
  static const double lhBody = 1.5;

  static const String family = 'Plus Jakarta Sans';

  /// Membangun TextTheme dari token; warna diatur lewat tema.
  static TextTheme textTheme(TextTheme base0) {
    TextStyle s(
      TextStyle? b,
      double size,
      FontWeight w,
      double h, [
      double ls = 0,
    ]) => (b ?? const TextStyle()).copyWith(
      fontSize: size,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
    );
    return base0.copyWith(
      displaySmall: s(base0.displaySmall, x2, FontWeight.w800, lhTight, -0.5),
      headlineMedium: s(
        base0.headlineMedium,
        xl,
        FontWeight.w800,
        lhSnug,
        -0.4,
      ),
      headlineSmall: s(base0.headlineSmall, lg, FontWeight.w700, lhSnug, -0.2),
      titleLarge: s(base0.titleLarge, md, FontWeight.w700, lhSnug),
      titleMedium: s(base0.titleMedium, base, FontWeight.w700, lhSnug),
      titleSmall: s(base0.titleSmall, sm, FontWeight.w700, lhSnug),
      bodyLarge: s(base0.bodyLarge, base, FontWeight.w500, lhBody),
      bodyMedium: s(base0.bodyMedium, sm, FontWeight.w500, lhBody),
      bodySmall: s(base0.bodySmall, xs, FontWeight.w500, lhBody),
      labelLarge: s(base0.labelLarge, sm, FontWeight.w700, lhSnug),
      labelMedium: s(base0.labelMedium, xs, FontWeight.w700, lhSnug, 0.4),
      labelSmall: s(base0.labelSmall, 11, FontWeight.w600, lhSnug, 0.4),
    );
  }
}
