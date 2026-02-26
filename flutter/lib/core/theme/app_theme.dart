import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── Color Palette ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFDC2626); // Strong Red
  static const Color primaryLight = Color(0xFFEF4444); // Red 500
  static const Color primaryDark = Color(0xFF991B1B); // Red 800
  static const Color primarySurface = Color(0xFFFEF2F2); // Very Light Red

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Status pills
  static const Color activeGreen = Color(0xFF10B981);
  static const Color expiredRed = Color(0xFFEF4444);
  static const Color pendingAmber = Color(0xFFF59E0B);
  static const Color frozenBlue = Color(0xFF3B82F6);

  // Chart colors
  static const List<Color> chartGradient = [
    Color(0xFFDC2626),
    Color(0xFFEF4444),
  ];
  static const List<Color> chartPalette = [
    Color(0xFFDC2626),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // ─── Dark Mode Colors ─────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF283548);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderLightDark = Color(0xFF283548);
  static const Color dividerDark = Color(0xFF334155);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static List<BoxShadow> get cardShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// ─── Spacing ─────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

/// ─── Border Radius ─────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
  static const double full = 999;
}

/// ─── Theme Builder ──────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.border,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
          fontSize: 12,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2.5),
        ),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        backgroundColor: AppColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.textOnPrimary,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        outline: AppColors.borderDark,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiaryDark,
          fontSize: 12,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        color: AppColors.surfaceDark,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiaryDark,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: const BorderSide(color: AppColors.borderDark),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiaryDark,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2.5),
        ),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        backgroundColor: AppColors.surfaceDark,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
        ),
      ),
    );
  }
}
