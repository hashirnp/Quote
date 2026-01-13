package com.example.quote

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews

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
        
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, DailyQuoteWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Flutter SharedPreferences uses "FlutterSharedPreferences" file
        // Keys are stored with "flutter." prefix by default
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        
        // Log all keys for debugging
        val allKeys = flutterPrefs.all.keys
        android.util.Log.d("WidgetProvider", "All FlutterSharedPreferences keys: ${allKeys.joinToString(", ")}")
        
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
        
        android.util.Log.d("WidgetProvider", "Found quoteText: ${if (quoteText != null) quoteText.take(30) + "..." else "null"}")
        android.util.Log.d("WidgetProvider", "Found quoteAuthor: $quoteAuthor")
        
        // Default values if still not found
        quoteText = quoteText ?: "Loading quote..."
        quoteAuthor = quoteAuthor ?: "Author"
        
        // Create RemoteViews
        val views = RemoteViews(context.packageName, R.layout.daily_quote_widget)
        
        // Update text
        views.setTextViewText(R.id.quote_text, quoteText)
        views.setTextViewText(R.id.quote_author, "— $quoteAuthor")
        
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
    }
}

