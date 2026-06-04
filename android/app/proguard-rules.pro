# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Stripe
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Agora
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# OkHttp / Retrofit (used by many plugins)
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Gson (JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data classes used by JSON parsing
-keep class com.flowachat.yan.** { *; }

# Prevent stripping of enums
-keepclassmembers enum * { *; }

# Multidex
-keep class androidx.multidex.** { *; }
