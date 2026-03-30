package com.aivpn.client

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Secure storage using EncryptedSharedPreferences.
 * Keys are encrypted with Android Keystore — safe from root access.
 */
object SecureStorage {

    private const val PREFS_FILE = "aivpn_secure_prefs"

    private fun getPrefs(context: Context): SharedPreferences {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        return EncryptedSharedPreferences.create(
            context,
            PREFS_FILE,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun saveString(context: Context, key: String, value: String) {
        getPrefs(context).edit().putString(key, value).apply()
    }

    fun loadString(context: Context, key: String, defaultValue: String = ""): String {
        return try {
            getPrefs(context).getString(key, defaultValue) ?: defaultValue
        } catch (_: Exception) {
            defaultValue
        }
    }

    fun remove(context: Context, key: String) {
        getPrefs(context).edit().remove(key).apply()
    }

    // Connection key helpers
    fun saveConnectionKey(context: Context, key: String) {
        saveString(context, "connection_key", key)
    }

    fun loadConnectionKey(context: Context): String {
        return loadString(context, "connection_key")
    }

    // Language preference (non-sensitive, but kept in same store for simplicity)
    fun saveLanguage(context: Context, lang: String) {
        saveString(context, "language", lang)
    }

    fun loadLanguage(context: Context): String {
        return loadString(context, "language", "en")
    }
}
