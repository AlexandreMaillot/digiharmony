package com.creappi.digiharmony

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Activity Android active (applicationId = com.creappi.digiharmony).
 *
 * Étend [AudioServiceActivity] (just_audio_background) pour que la lecture
 * audio en arrière-plan fonctionne (écran Détox-lecteur). Héberge le
 * MethodChannel maison `digiharmony/usage_access` (Mon temps d'écran).
 * Aucune permission ni dépendance supplémentaire — `PACKAGE_USAGE_STATS`
 * (déjà au manifeste) suffit ; l'ouverture des réglages est un simple Intent.
 */
class MainActivity : AudioServiceActivity() {

    private val canalAccesUsage = "digiharmony/usage_access"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Mon temps d'écran : accès aux statistiques d'usage ───────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            canalAccesUsage,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "aLAcces" -> result.success(aLAccesUsage())
                "ouvrirReglagesAcces" -> {
                    ouvrirReglagesAccesUsage()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * True si l'app détient l'accès aux statistiques d'usage
     * (PACKAGE_USAGE_STATS), accordé manuellement dans les réglages système.
     *
     * Permission « spéciale » non runtime : vérifiée via [AppOpsManager], pas
     * via `checkSelfPermission`.
     */
    private fun aLAccesUsage(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Ouvre l'écran système d'octroi de l'accès aux statistiques d'usage
     * (Settings.ACTION_USAGE_ACCESS_SETTINGS). Aucune permission requise.
     */
    private fun ouvrirReglagesAccesUsage() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}
