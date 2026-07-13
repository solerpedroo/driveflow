package com.driveflow.driveflow.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.driveflow.driveflow.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class DriveFlowHomeWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            WidgetContent(context, currentState())
        }
    }

    @Composable
    private fun WidgetContent(context: Context, state: HomeWidgetGlanceState) {
        val prefs = state.preferences
        val profit = prefs.getString("today_profit", "R$ 0,00") ?: "R$ 0,00"
        val revenue = prefs.getString("today_revenue", "R$ 0,00") ?: "R$ 0,00"
        val shiftActive = prefs.getBoolean("shift_active", false)
        val shiftRevenue = prefs.getString("shift_revenue", "") ?: ""
        val shiftElapsed = prefs.getString("shift_elapsed", "") ?: ""
        val deepLink = if (shiftActive) "driveflow://shift" else "driveflow://earning/quick"
        val launchIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse(deepLink),
            context,
            MainActivity::class.java,
        ).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val subtitle = when {
            shiftActive && shiftRevenue.isNotBlank() ->
                "Turno $shiftElapsed · $shiftRevenue"
            else -> "Ganhos $revenue · Toque para abrir"
        }

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color(0xFF0064F5))
                .clickable(actionStartActivity(launchIntent))
                .padding(16.dp),
            verticalAlignment = Alignment.Vertical.CenterVertically,
            horizontalAlignment = Alignment.Horizontal.Start,
        ) {
            Text(
                text = if (shiftActive) "Turno ativo" else "Lucro hoje",
                style = TextStyle(
                    color = ColorProvider(Color.White),
                    fontSize = 12.sp,
                ),
            )
            Text(
                text = if (shiftActive && shiftRevenue.isNotBlank()) shiftRevenue else profit,
                style = TextStyle(
                    color = ColorProvider(Color.White),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                ),
            )
            Text(
                text = subtitle,
                style = TextStyle(
                    color = ColorProvider(Color(0xCCFFFFFF)),
                    fontSize = 11.sp,
                ),
            )
        }
    }
}
