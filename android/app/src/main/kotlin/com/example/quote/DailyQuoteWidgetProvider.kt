package com.example.quote

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import java.util.Calendar

class DailyQuoteWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.MY_PACKAGE_REPLACED") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, DailyQuoteWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
            
            // Schedule daily updates
            scheduleDailyUpdate(context)
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Schedule daily updates when first widget is added
        scheduleDailyUpdate(context)
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Cancel updates when all widgets are removed
        cancelDailyUpdate(context)
    }
    
    private fun scheduleDailyUpdate(context: Context) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            if (alarmManager == null) {
                android.util.Log.w("WidgetProvider", "AlarmManager service not available")
                return
            }
            
            val intent = Intent(context, DailyQuoteWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            // Schedule for midnight every day
            val calendar = Calendar.getInstance().apply {
                timeInMillis = System.currentTimeMillis()
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                
                // If midnight has passed today, schedule for tomorrow
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                try {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                } catch (e: SecurityException) {
                    android.util.Log.w("WidgetProvider", "Cannot set exact alarm: ${e.message}")
                    // Fallback to inexact alarm
                    alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
            }
            
            android.util.Log.d("WidgetProvider", "Scheduled daily update for ${calendar.time}")
        } catch (e: Exception) {
            android.util.Log.e("WidgetProvider", "Error scheduling update: ${e.message}", e)
        }
    }
    
    private fun cancelDailyUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DailyQuoteWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            // Flutter SharedPreferences uses "FlutterSharedPreferences" file
            // Keys are stored with "flutter." prefix by default
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Try direct keys first (what we're saving with sharedPreferences.setString)
            // Flutter SharedPreferences stores keys with "flutter." prefix
            var quoteText = flutterPrefs.getString("flutter.widget_quote_text", null)
            var quoteAuthor = flutterPrefs.getString("flutter.widget_quote_author", null)
            
            // If not found, try home_widget format (version 0.9.0)
            if (quoteText == null) {
                quoteText = flutterPrefs.getString("flutter.home_widget.quote_text", null)
            }
            if (quoteAuthor == null) {
                quoteAuthor = flutterPrefs.getString("flutter.home_widget.quote_author", null)
            }
            
            // Try without flutter prefix (in case home_widget stores differently)
            if (quoteText == null) {
                quoteText = flutterPrefs.getString("home_widget.quote_text", null)
            }
            if (quoteAuthor == null) {
                quoteAuthor = flutterPrefs.getString("home_widget.quote_author", null)
            }
            
            // Try direct keys without prefix
            if (quoteText == null) {
                quoteText = flutterPrefs.getString("widget_quote_text", null)
            }
            if (quoteAuthor == null) {
                quoteAuthor = flutterPrefs.getString("widget_quote_author", null)
            }
            
            // Get theme mode
            var isDarkMode = flutterPrefs.getBoolean("flutter.widget_is_dark_mode", true)
            if (!flutterPrefs.contains("flutter.widget_is_dark_mode")) {
                // Try home_widget format
                isDarkMode = flutterPrefs.getBoolean("flutter.home_widget.is_dark_mode", true)
            }
            
            // Default values if still not found
            quoteText = quoteText ?: "Loading quote..."
            quoteAuthor = quoteAuthor ?: "Author"
            
            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.daily_quote_widget)
            
            // Update text
            views.setTextViewText(R.id.quote_text, quoteText)
            views.setTextViewText(R.id.quote_author, quoteAuthor)
            
            // Set colors based on theme - high contrast for readability
            // Light theme uses dark blue-gray instead of pure black for better visual appeal
            val textColor = if (isDarkMode) 0xFFFFFFFF.toInt() else 0xFF26334D.toInt() // Full white or dark blue-gray
            val authorColor = if (isDarkMode) 0xFFFFFFFF.toInt() else 0xFF26334D.toInt() // Same color
            val iconColor = if (isDarkMode) 0xCCFFFFFF.toInt() else 0xB326334D.toInt()
            
            views.setTextColor(R.id.quote_text, textColor)
            views.setTextColor(R.id.quote_author, authorColor)
            views.setTextColor(R.id.quote_author_dash, authorColor)
            
            // Set background drawable based on theme
            val backgroundRes = if (isDarkMode) {
                R.drawable.widget_background
            } else {
                R.drawable.widget_background_light
            }
            try {
                views.setInt(R.id.widget_container, "setBackgroundResource", backgroundRes)
            } catch (e: Exception) {
                android.util.Log.w("WidgetProvider", "Could not set background: ${e.message}")
            }
            
            // Try to set icon color, but don't crash if it doesn't exist
            try {
                views.setTextColor(R.id.quote_icon, iconColor)
            } catch (e: Exception) {
                android.util.Log.w("WidgetProvider", "Could not set icon color: ${e.message}")
            }
            
            // Set click intent to open app to daily quote
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_daily_quote", true)
            }
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            // Update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("WidgetProvider", "Error updating widget: ${e.message}", e)
            // Try to show at least a basic widget with error message
            try {
                val views = RemoteViews(context.packageName, R.layout.daily_quote_widget)
                views.setTextViewText(R.id.quote_text, "Error loading quote")
                views.setTextViewText(R.id.quote_author, "— Please open app")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e2: Exception) {
                android.util.Log.e("WidgetProvider", "Critical error: ${e2.message}", e2)
            }
        }
    }
}

