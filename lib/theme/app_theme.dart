import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Merakit ThemeData dari token. Semua komponen Material di-style di sini
/// sehingga halaman tidak perlu menimpa warna/bentuk secara manual.
abstract final class AppTheme {
  static ThemeData light({bool webFont = true}) =>
      _build(AppSemantic.light, Brightness.light, webFont);

  static ThemeData dark({bool webFont = true}) =>
      _build(AppSemantic.dark, Brightness.dark, webFont);

  static ThemeData _build(AppSemantic t, Brightness b, bool webFont) {
    final scheme = ColorScheme(
      brightness: b,
      primary: t.action,
      onPrimary: t.textOnAction,
      primaryContainer: t.actionSoft,
      onPrimaryContainer: t.actionText,
      secondary: t.brand,
      onSecondary: Colors.white,
      error: t.danger,
      onError: Colors.white,
      errorContainer: t.dangerSoft,
      onErrorContainer: t.dangerText,
      surface: t.surface,
      onSurface: t.text,
      onSurfaceVariant: t.textMuted,
      surfaceContainerLowest: t.bg,
      surfaceContainerLow: t.surface2,
      surfaceContainer: t.surface2,
      surfaceContainerHigh: t.surfaceSunken,
      surfaceContainerHighest: t.surfaceSunken,
      outline: t.borderStrong,
      outlineVariant: t.border,
      shadow: Colors.black,
      scrim: t.overlay,
    );

    final base = ThemeData(brightness: b, useMaterial3: true).textTheme;
    var text = AppType.textTheme(base)
        .apply(bodyColor: t.text, displayColor: t.text);
    if (webFont) {
      text = GoogleFonts.plusJakartaSansTextTheme(text);
    }

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: c, width: w),
    );

    const buttonShape = StadiumBorder();
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpace.s6,
      vertical: AppSpace.s3,
    );
    const buttonMin = Size(AppLayout.minTapTarget, AppLayout.minTapTarget);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.surface,
      textTheme: text,
      extensions: [t],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.surface,
        foregroundColor: t.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: t.border,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          color: t.text,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: t.text),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: t.border),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        scrimColor: t.overlay,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.textMuted,
        textColor: t.text,
        selectedColor: t.actionText,
        selectedTileColor: t.actionSoft,
        shape: const StadiumBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      ),
      dividerTheme: DividerThemeData(color: t.border, space: 1, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: t.actionSoft,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? t.actionText
                : t.textSubtle,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall?.copyWith(
            color: s.contains(WidgetState.selected)
                ? t.actionText
                : t.textSubtle,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        selectedColor: t.actionSoft,
        showCheckmark: false,
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.selected) ? t.action : t.border,
          ),
        ),
        labelStyle: text.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (s) =>
                s.contains(WidgetState.selected) ? t.actionText : t.textMuted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: t.overlay,
        dragHandleColor: t.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.action,
        foregroundColor: t.textOnAction,
        shape: const StadiumBorder(),
        extendedTextStyle: text.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s4,
        ),
        labelStyle: text.bodyMedium?.copyWith(color: t.textSubtle),
        floatingLabelStyle: text.bodyMedium?.copyWith(
          color: t.actionText,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: t.textSubtle),
        helperStyle: text.bodySmall?.copyWith(color: t.textSubtle),
        errorStyle: text.bodySmall?.copyWith(
          color: t.dangerText,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: t.textSubtle,
        suffixIconColor: t.textSubtle,
        border: border(t.border),
        enabledBorder: border(t.border),
        disabledBorder: border(t.border),
        focusedBorder: border(t.action, 2),
        errorBorder: border(t.danger),
        focusedErrorBorder: border(t.danger, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: const WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: WidgetStatePropertyAll(t.textOnAction),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return t.surfaceSunken;
            if (s.contains(WidgetState.pressed)) return t.actionPress;
            if (s.contains(WidgetState.hovered)) return t.actionHover;
            return t.action;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          padding: const WidgetStatePropertyAll(buttonPadding),
          shape: const WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          foregroundColor: WidgetStatePropertyAll(t.actionText),
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(
              color:
                  s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed)
                  ? t.action
                  : t.borderStrong,
              width: 1.5,
            ),
          ),
          overlayColor: WidgetStatePropertyAll(t.actionSoft),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          shape: const WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          foregroundColor: WidgetStatePropertyAll(t.actionText),
          overlayColor: WidgetStatePropertyAll(t.actionSoft),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          foregroundColor: WidgetStatePropertyAll(t.text),
          overlayColor: WidgetStatePropertyAll(t.actionSoft),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(t.textOnAction),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.action : t.borderStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: t.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.ink900,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        insetPadding: const EdgeInsets.all(AppSpace.s4),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppPalette.ink800,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }
}
