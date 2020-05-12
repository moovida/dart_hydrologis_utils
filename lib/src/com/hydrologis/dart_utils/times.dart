part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */

/// Time related utilities
class TimeUtilities {
  /// An ISO8601 date formatter (yyyy-MM-dd HH:mm:ss).
  static final DateFormat ISO8601_TS_FORMATTER =
      DateFormat("yyyy-MM-dd HH:mm:ss");
  static final DateFormat ISO8601_TS_FORMATTER_MILLIS =
      DateFormat("yyyy-MM-dd HH:mm:ss.SSS");

  /// An ISO8601 time formatter (HH:mm:ss).
  static final DateFormat ISO8601_TS_TIME_FORMATTER = DateFormat("HH:mm:ss");

  /// An ISO8601 day formatter (yyyy-MM-dd).
  static final DateFormat ISO8601_TS_DAY_FORMATTER = DateFormat("yyyy-MM-dd");

  /// A date formatter (yyyyMMdd_HHmmss) useful for file names (it contains no spaces).
  static final DateFormat DATE_TS_FORMATTER = DateFormat("yyyyMMdd_HHmmss");

  /// A date formatter (yyyyMMdd) useful for file names (it contains no spaces).
  static final DateFormat DAY_TS_FORMATTER = DateFormat("yyyyMMdd");

  /// A date formatter (yyyyMMdd_HH) useful for file names (it contains no spaces).
  static final DateFormat DAYHOUR_TS_FORMATTER = DateFormat("yyyyMMdd_HH");

  /// A date formatter (yyyyMMdd_HHmm) useful for file names (it contains no spaces).
  static final DateFormat DAYHOURMINUTE_TS_FORMATTER =
      DateFormat("yyyyMMdd_HHmm");
}
