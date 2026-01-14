import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:screenshot/screenshot.dart';

import '../../features/quotes/domain/entities/quote.dart';
import '../../features/quotes/presentation/widgets/quote_card_templates.dart';

class QuoteCardGenerator {
  /// Generate quote card as image
  Future<Uint8List?> generateQuoteCardImage({
    required Quote quote,
    required QuoteCardStyle style,
    Size size = const Size(1080, 1080), // Square format, high resolution
  }) async {
    try {
      final screenshotController = ScreenshotController();
      final widget = QuoteCardTemplates.buildCard(
        quote: quote,
        style: style,
        size: size,
      );

      // Wrap widget in Material for proper rendering
      final materialWidget = Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
          child: widget,
        ),
      );

      // Capture the widget as image
      final image = await screenshotController.captureFromWidget(
        materialWidget,
        pixelRatio: 3.0, // High resolution
        delay: const Duration(milliseconds: 300),
      );

      return image;
    } catch (e) {
      debugPrint('Error generating quote card image: $e');
      return null;
    }
  }

  /// Save quote card image to device gallery
  Future<bool> saveQuoteCardToGallery({
    required Quote quote,
    required QuoteCardStyle style,
    Size size = const Size(1080, 1080),
  }) async {
    try {
      // Request storage permission (Android 13+ uses photos, older uses storage)
      Permission permission;
      if (Platform.isAndroid) {
        // Check Android version
        permission = Permission.photos;
        final status = await permission.status;
        if (!status.isGranted) {
          final result = await permission.request();
          if (!result.isGranted) {
            // Try storage permission for older Android versions
            final storageStatus = await Permission.storage.status;
            if (!storageStatus.isGranted) {
              final storageResult = await Permission.storage.request();
              if (!storageResult.isGranted) {
                return false;
              }
            }
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, saver_gallery uses PHPhotoLibrary which requires permission
        // iOS 14+ can use photosAddOnly (add-only access, less intrusive)
        // iOS 13 and below need full photos permission

        PermissionStatus permissionStatus;

        // Check if photosAddOnly is available (iOS 14+)
        try {
          permissionStatus = await Permission.photosAddOnly.status;
          debugPrint('Current photosAddOnly status: $permissionStatus');

          if (!permissionStatus.isGranted) {
            if (permissionStatus.isPermanentlyDenied) {
              debugPrint(
                  'photosAddOnly is permanently denied. User needs to enable in Settings.');
              // Return false - user needs to go to settings
              return false;
            }

            debugPrint('Requesting photosAddOnly permission...');
            permissionStatus = await Permission.photosAddOnly.request();
            debugPrint('photosAddOnly request result: $permissionStatus');

            if (!permissionStatus.isGranted) {
              debugPrint(
                  'photosAddOnly denied, trying full photos permission...');
              // Fallback to full photos permission
              var photosStatus = await Permission.photos.status;
              debugPrint('Current photos status: $photosStatus');

              if (!photosStatus.isGranted) {
                if (photosStatus.isPermanentlyDenied) {
                  debugPrint(
                      'photos permission is permanently denied. User needs to enable in Settings.');
                  return false;
                }

                debugPrint('Requesting photos permission...');
                photosStatus = await Permission.photos.request();
                debugPrint('photos request result: $photosStatus');

                if (!photosStatus.isGranted) {
                  debugPrint(
                      'Photo library permission denied. Status: $photosStatus');
                  return false;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error checking photosAddOnly permission: $e');
          // Fallback to photos permission if photosAddOnly fails
          var photosStatus = await Permission.photos.status;
          if (!photosStatus.isGranted) {
            if (photosStatus.isPermanentlyDenied) {
              debugPrint('photos permission is permanently denied.');
              return false;
            }
            photosStatus = await Permission.photos.request();
            if (!photosStatus.isGranted) {
              debugPrint(
                  'Photo library permission denied. Status: $photosStatus');
              return false;
            }
          }
        }

        debugPrint('Photo library permission granted');
      }

      // Generate image
      final imageBytes = await generateQuoteCardImage(
        quote: quote,
        style: style,
        size: size,
      );

      if (imageBytes == null) {
        return false;
      }

      // Save to gallery using saver_gallery
      final fileName =
          'quote_${quote.author.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';

      try {
        final result = await SaverGallery.saveImage(
          imageBytes,
          name: fileName,
          androidExistNotSave: false,
        );

        // SaverGallery returns SaveResult with isSuccess property
        if (!result.isSuccess) {
          debugPrint(
              'SaverGallery returned isSuccess=false. Error: ${result.errorMessage}');
          return false;
        }

        debugPrint('Image saved successfully: $fileName');
        return true;
      } catch (e) {
        debugPrint('Error calling SaverGallery.saveImage: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error saving quote card to gallery: $e');
      return false;
    }
  }

  /// Get temporary file path for quote card
  Future<String?> getQuoteCardFilePath({
    required Quote quote,
    required QuoteCardStyle style,
    Size size = const Size(1080, 1080),
  }) async {
    try {
      final imageBytes = await generateQuoteCardImage(
        quote: quote,
        style: style,
        size: size,
      );

      if (imageBytes == null) {
        return null;
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'quote_${quote.author.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(imageBytes);

      return file.path;
    } catch (e) {
      debugPrint('Error getting quote card file path: $e');
      return null;
    }
  }
}
