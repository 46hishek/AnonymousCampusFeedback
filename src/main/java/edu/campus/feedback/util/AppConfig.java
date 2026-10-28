package edu.campus.feedback.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Properties;

/**
 * Reads settings from (highest priority first):
 * 1. environment variable CF_KEY       (db.url -> CF_DB_URL)
 * 2. JVM option -Dcf.key=value         (-Dcf.db.url=...)
 * 3. campus-feedback.properties on the classpath (src/main/resources)
 */
public final class AppConfig {

    private static final Properties FILE_PROPS = load();

    private AppConfig() {
    }

    private static Properties load() {
        Properties props = new Properties();
        try (InputStream in = AppConfig.class.getClassLoader()
                .getResourceAsStream("campus-feedback.properties")) {
            if (in != null) {
                try (Reader reader =
                         new InputStreamReader(in, StandardCharsets.UTF_8)) {
                    props.load(reader);
                }
            }
        } catch (IOException e) {
            throw new IllegalStateException(
                "campus-feedback.properties could not be read.", e);
        }
        return props;
    }

    private static String clean(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    /** Returns the setting, or null when it is empty or missing. */
    public static String get(String key) {
        String envName = "CF_" + key.toUpperCase(Locale.ROOT).replace('.', '_');

        String value = clean(System.getenv(envName));
        if (value == null) {
            value = clean(System.getProperty("cf." + key));
        }
        if (value == null) {
            value = clean(FILE_PROPS.getProperty(key));
        }
        return value;
    }

    public static String get(String key, String defaultValue) {
        String value = get(key);
        return value == null ? defaultValue : value;
    }

    public static boolean getBoolean(String key, boolean defaultValue) {
        String value = get(key);
        return value == null ? defaultValue : Boolean.parseBoolean(value);
    }

    public static int getInt(String key, int defaultValue) {
        String value = get(key);
        if (value == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
