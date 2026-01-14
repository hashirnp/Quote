import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/share_helper.dart';
import '../../domain/entities/quote.dart';
import '../widgets/quote_card_templates.dart';

class ShareQuotePage extends StatefulWidget {
  final Quote quote;

  const ShareQuotePage({
    super.key,
    required this.quote,
  });

  @override
  State<ShareQuotePage> createState() => _ShareQuotePageState();
}

class _ShareQuotePageState extends State<ShareQuotePage> {
  QuoteCardStyle _selectedStyle = QuoteCardStyle.modern;
  bool _isGenerating = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.shareQuote,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Section
            _buildPreviewSection(),
            const SizedBox(height: 32),
            // Style Selection
            _buildStyleSelection(),
            const SizedBox(height: 32),
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.preview,
            style: GoogleFonts.poppins(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Preview card (scaled down)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 250,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: QuoteCardTemplates.buildCard(
                    quote: widget.quote,
                    style: _selectedStyle,
                    size: const Size(400, 400),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.cardStyle,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: QuoteCardStyle.values.map((style) {
            final isSelected = _selectedStyle == style;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStyle = style;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getStyleIcon(style),
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : theme.textTheme.bodyMedium?.color,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          QuoteCardTemplates.getStyleName(style),
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getStyleIcon(QuoteCardStyle style) {
    switch (style) {
      case QuoteCardStyle.modern:
        return Icons.auto_awesome;
      case QuoteCardStyle.classic:
        return Icons.style;
      case QuoteCardStyle.minimal:
        return Icons.minimize;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Share as Image Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _shareAsImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isGenerating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.shareAsImage,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Save to Gallery Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _isSaving ? null : _saveToGallery,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.saveToGallery,
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Share as Text Button
        TextButton(
          onPressed: _shareAsText,
          child: Text(
            AppStrings.shareAsText,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareAsImage() async {
    setState(() => _isGenerating = true);
    try {
      await ShareHelper.shareQuoteAsImage(
        quote: widget.quote,
        style: _selectedStyle,
        context: context,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.quoteSharedSuccess,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error logged via SnackBar display
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.errorSharingQuote}: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final success = await ShareHelper.saveQuoteCardToGallery(
        quote: widget.quote,
        style: _selectedStyle,
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.quoteSavedSuccess,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else {
          // Check if permission is permanently denied
          final permission = Platform.isIOS
              ? await Permission.photosAddOnly.status
              : await Permission.photos.status;

          String errorMessage = AppStrings.errorSavingQuotePermissions;
          if (permission.isPermanentlyDenied) {
            errorMessage = AppStrings.permissionDenied;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: permission.isPermanentlyDenied
                  ? SnackBarAction(
                      label: AppStrings.openSettings,
                      textColor: Colors.white,
                      onPressed: () {
                        openAppSettings();
                      },
                    )
                  : null,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.errorSavingQuote}: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareAsText() async {
    try {
      await ShareHelper.shareQuoteAsText(
        widget.quote,
        context: context,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.errorSharingQuote}: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
