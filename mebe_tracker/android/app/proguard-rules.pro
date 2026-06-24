# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Play Core / In-App Purchase
-keep class com.android.vending.billing.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
