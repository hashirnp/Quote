import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/quotes/domain/entities/quote.dart';
import '../../features/quotes/presentation/widgets/quote_card_templates.dart';
import '../services/quote_card_generator.dart';

class ShareHelper {
  static final QuoteCardGenerator _cardGenerator = QuoteCardGenerator();

  /// Share quote as text via system share sheet
  static Future<void> shareQuoteAsText(
    Quote quote, {
    BuildContext? context,
  }) async {
    try {
      final text = '"${quote.text}" — ${quote.author}';

      // For iOS, we need to provide sharePositionOrigin (especially on iPad)
      // Share.shareXFiles requires at least one file, so we create a temporary text file
      if (Platform.isIOS && context != null) {
        // Get the screen size and safe area
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final padding = mediaQuery.padding;

        // Calculate a valid position in the center-bottom area (where buttons typically are)
        final originX = screenSize.width / 2;
        final originY = screenSize.height - padding.bottom - 100;

        // Create a temporary text file to share
        // This allows us to use shareXFiles with sharePositionOrigin
        // Share.shareXFiles requires at least one file, so we create a temp text file
        final tempFile = await _createTempTextFile(text);

        try {
          await Share.shareXFiles(
            [XFile(tempFile)],
            text: text,
            sharePositionOrigin: Rect.fromLTWH(
              originX - 50, // 100px wide rect centered
              originY - 25, // 50px tall rect
              100,
              50,
            ),
          );
        } finally {
          // Clean up temporary file
          try {
            final file = File(tempFile);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            // Ignore cleanup errors
          }
        }
      } else {
        await Share.share(text);
      }
    } catch (e) {
      throw Exception('Failed to share quote as text: $e');
    }
  }

  /// Share quote as image card via system share sheet
  static Future<void> shareQuoteAsImage({
    required Quote quote,
    required QuoteCardStyle style,
    BuildContext? context,
  }) async {
    try {
      final filePath = await _cardGenerator.getQuoteCardFilePath(
        quote: quote,
        style: style,
      );

      if (filePath == null) {
        throw Exception('Failed to generate quote card image');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Quote card file not found');
      }

      // For iOS, we need to provide sharePositionOrigin
      if (Platform.isIOS && context != null) {
        // Get the screen size and safe area
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final padding = mediaQuery.padding;

        // Calculate a valid position in the center-bottom area (where buttons typically are)
        // This ensures the share sheet appears from a reasonable location
        final originX = screenSize.width / 2;
        final originY = screenSize.height -
            padding.bottom -
            100; // Near bottom but above safe area

        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Check out this inspiring quote!',
          sharePositionOrigin: Rect.fromLTWH(
            originX - 50, // 100px wide rect centered
            originY - 25, // 50px tall rect
            100,
            50,
          ),
        );
      } else {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Check out this inspiring quote!',
        );
      }
    } catch (e) {
      throw Exception('Failed to share quote as image: $e');
    }
  }

  /// Save quote card as image to device gallery
  static Future<bool> saveQuoteCardToGallery({
    required Quote quote,
    required QuoteCardStyle style,
  }) async {
    try {
      return await _cardGenerator.saveQuoteCardToGallery(
        quote: quote,
        style: style,
      );
    } catch (e) {
      throw Exception('Failed to save quote card: $e');
    }
  }

  /// Create a temporary text file for sharing
  static Future<String> _createTempTextFile(String text) async {
    final directory = await getTemporaryDirectory();
    final fileName = 'quote_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(text);
    return file.path;
  }

  /// Legacy method for backward compatibility
  static Future<void> shareQuote(Quote quote, {BuildContext? context}) async {
    await shareQuoteAsText(quote, context: context);
  }
}
