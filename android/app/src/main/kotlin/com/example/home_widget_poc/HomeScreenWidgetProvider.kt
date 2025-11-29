package com.example.home_widget_poc  // your package name

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->

            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                // Open app when widget is clicked
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // Read counter value from shared preferences
                val counter = widgetData.getInt("_counter", 0)
                setTextViewText(R.id.tv_counter, counter.toString())

                // Increment button
                val incrementIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("myAppWidget://increment")
                )
                setOnClickPendingIntent(R.id.bt_increment, incrementIntent)

                // Decrement button
                val decrementIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("myAppWidget://decrement")
                )
                setOnClickPendingIntent(R.id.bt_decrement, decrementIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
