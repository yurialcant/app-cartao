import 'package:flutter/material.dart';

/// Sistema de temas do aplicativo
class AppTheme {
  // ========================================
  // 🎨 TEMA CLARO
  // ========================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      
      // Cores primárias
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF1E40AF),
      primaryColorLight: const Color(0xFF3B82F6),
      primaryColorDark: const Color(0xFF1E3A8A),
      
      // Cores de fundo
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      
      // Cores de texto
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF374151),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF9CA3AF),
        ),
      ),
      
      // Tema dos campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE53E3E),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      
      // Tema dos botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Tema dos cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      
      // Tema da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
  
  // ========================================
  // 🌙 TEMA ESCURO
  // ========================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      
      // Cores primárias
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF60A5FA),
      primaryColorLight: const Color(0xFF93C5FD),
      primaryColorDark: const Color(0xFF3B82F6),
      
      // Cores de fundo
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardColor: const Color(0xFF374151),
      
      // Cores de texto
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFD1D5DB),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
      
      // Tema dos campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4B5563),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4B5563),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF60A5FA),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFF87171),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: const Color(0xFF374151),
      ),
      
      // Tema dos botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Tema dos cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF374151),
      ),
      
      // Tema da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
