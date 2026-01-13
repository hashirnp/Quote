import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quote.dart';

enum QuoteCardStyle {
  modern,
  classic,
  minimal,
}

class QuoteCardTemplates {
  static Widget buildCard({
    required Quote quote,
    required QuoteCardStyle style,
    required Size size,
  }) {
    switch (style) {
      case QuoteCardStyle.modern:
        return _buildModernCard(quote, size);
      case QuoteCardStyle.classic:
        return _buildClassicCard(quote, size);
      case QuoteCardStyle.minimal:
        return _buildMinimalCard(quote, size);
    }
  }

  // Modern Style: Gradient background with bold typography
  static Widget _buildModernCard(Quote quote, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.7),
            const Color(0xFF1A1D29),
          ],
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote text
          Text(
            quote.text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // Author
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                quote.author,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Classic Style: Elegant serif font with decorative elements
  static Widget _buildClassicCard(Quote quote, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Opening quote mark
          Row(
            children: [
              Text(
                '"',
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.primaryBlue,
                  fontSize: 80,
                  height: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          // Quote text
          Text(
            quote.text,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          // Decorative line
          Container(
            width: 100,
            height: 2,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 15),
          // Author
          Text(
            '— ${quote.author}',
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Closing quote mark
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '"',
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.primaryBlue,
                  fontSize: 80,
                  height: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Minimal Style: Clean and simple
  static Widget _buildMinimalCard(Quote quote, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small accent line
          Container(
            width: 60,
            height: 3,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 40),
          // Quote text
          Text(
            quote.text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),
          // Author
          Text(
            quote.author.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  static String getStyleName(QuoteCardStyle style) {
    switch (style) {
      case QuoteCardStyle.modern:
        return 'Modern';
      case QuoteCardStyle.classic:
        return 'Classic';
      case QuoteCardStyle.minimal:
        return 'Minimal';
    }
  }
}
