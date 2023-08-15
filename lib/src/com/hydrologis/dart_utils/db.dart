part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2023. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */

/// Abstract class for common query result handling.
abstract class QueryResult {
  int get length;

  QueryResultRow get first;

  /// Run a function taking a [QueryResultRow] on the whole [QueryResult].
  void forEach(Function rowFunction);

  /// Find the [QueryResultRow] given a field and value.
  QueryResultRow? find(String field, dynamic value);
}

/// Abstract class for common query result rows handling.
abstract class QueryResultRow {
  dynamic get(String filedName);

  dynamic getAt(int index);

  /// Run a function taking a a key and its value on the whole [QueryResultRow].
  void forEach(Function keyValueFunction);
}
