part of dart_hydrologis_utils;

/*
 * Copyright (c) 2019-2023. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */
class StringUtilities {
  static bool equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }

  /// Format [meters] to be Km or meters.
  static String formatMeters(double meters) {
    if (meters >= 1000) {
      var totalKm = meters / 1000.0;
      return "${totalKm.toStringAsFixed(1)} km";
    } else {
      return "${meters.round()} m";
    }
  }

  /// Format a [durationMillis] in milliseconds to contain the hours/minutes/seconds part.
  static String formatDurationMillis(int durationMillis) {
    double durationSeconds = durationMillis / 1000;
    String durationStr = "${durationSeconds.toInt()} sec";
    if (durationSeconds > 60) {
      double durationMinutes = durationSeconds / 60;
      double leftSeconds = durationSeconds % 60;
      durationStr = "${durationMinutes.toInt()} min";
      if (leftSeconds > 0) {
        durationStr += ", ${leftSeconds.toInt()} sec";
      }
      if (durationMinutes > 60) {
        double durationhours = durationMinutes / 60;
        double leftMinutes = durationMinutes % 60;
        durationStr = "${durationhours.toInt()} h";
        if (leftMinutes > 0) {
          durationStr += ", ${leftMinutes.toInt()} min";
        }
      }
    }
    return durationStr;
  }
}
