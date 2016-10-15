# Fix R8 missing class errors for SLF4J
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }
