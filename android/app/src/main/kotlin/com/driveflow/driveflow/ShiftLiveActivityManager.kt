package com.driveflow.driveflow

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.istornz.live_activities.LiveActivityManager

class ShiftLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext: Context = context.applicationContext

    private val pendingIntent: PendingIntent = PendingIntent.getActivity(
        appContext,
        201,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private val remoteViews: RemoteViews = RemoteViews(
        appContext.packageName,
        R.layout.shift_live_activity,
    )

    private fun updateRemoteViews(data: Map<String, Any>) {
        val title = data["title"] as? String ?: "Turno ativo"
        val revenue = data["revenueLabel"] as? String ?: "R$ 0,00"
        val elapsed = data["elapsedLabel"] as? String ?: "00:00"
        val subtitle = data["subtitle"] as? String ?: ""

        remoteViews.setTextViewText(R.id.shift_title, title)
        remoteViews.setTextViewText(R.id.shift_revenue, revenue)
        remoteViews.setTextViewText(
            R.id.shift_elapsed,
            if (subtitle.isEmpty()) elapsed else "$elapsed · $subtitle",
        )
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>,
    ): Notification {
        updateRemoteViews(data)

        val title = data["title"] as? String ?: "Turno ativo"
        val revenue = data["revenueLabel"] as? String ?: "R$ 0,00"

        return notification
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setContentTitle(title)
            .setContentText(revenue)
            .setContentIntent(pendingIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setPriority(Notification.PRIORITY_LOW)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
