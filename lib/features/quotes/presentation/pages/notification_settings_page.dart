import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/di/injection_container.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = getIt<NotificationService>();
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      _notificationsEnabled =
          await _notificationService.isNotificationEnabled();
      final time = await _notificationService.getNotificationTime();
      if (time != null) {
        _notificationTime = time;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.errorLoadingSettings,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryBlue,
              brightness: Theme.of(context).brightness,
            ).copyWith(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardTheme.color,
              onSurface: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _notificationTime = picked;
      });
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _notificationService.setNotificationEnabled(_notificationsEnabled);

      if (_notificationsEnabled) {
        // Schedule notifications for next 5 days with actual daily quotes
        await _notificationService.scheduleDailyQuoteNotification(
          notificationTime: _notificationTime,
        );
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _notificationsEnabled
                  ? 'Notification time saved successfully'
                  : 'Notifications disabled',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.errorSavingSettings,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.notificationSettingsTitle,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable Notifications Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications_active,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      title: Text(
                        AppStrings.dailyQuoteNotifications,
                        style: GoogleFonts.poppins(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.receiveDailyQuote,
                        style: GoogleFonts.poppins(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          await _saveSettings();
                        },
                        activeThumbColor: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Notification Time
                  if (_notificationsEnabled) ...[
                    Text(
                      AppStrings.notificationTime,
                      style: GoogleFonts.poppins(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                        title: Text(
                          AppStrings.time,
                          style: GoogleFonts.poppins(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        onTap: _selectTime,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.notificationInfoMessage,
                              style: GoogleFonts.poppins(
                                color: theme.textTheme.titleLarge?.color,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
