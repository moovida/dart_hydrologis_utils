part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// Class to handle int conversions.
class ByteConversionUtilities {
  /// Convert a 32 bit integer [number] to its int representation.
  static List<int> bytesFromInt32(int number, [Endian endian = Endian.big]) {
    var tmp = Uint8List.fromList([0, 0, 0, 0]);
    ByteData bdata = ByteData.view(tmp.buffer);
    bdata.setInt32(0, number, endian);
    return tmp;
  }

  /// Convert a 16 bit integer [number] to its int representation.
  static List<int> bytesFromInt16(int number, [Endian endian = Endian.big]) {
    var tmp = Uint8List.fromList([0, 0]);
    ByteData bdata = ByteData.view(tmp.buffer);
    bdata.setInt16(0, number, endian);
    return tmp;
  }

  /// Get a double from a list of 8 bytes.
  static double getDouble64(Uint8List list, [Endian endian = Endian.big]) {
    var bdata = ByteData.view(list.buffer);
    return bdata.getFloat64(0, endian);
  }

  /// Get a double from a list of 4 bytes.
  static double getDouble32(Uint8List list, [Endian endian = Endian.big]) {
    var bdata = ByteData.view(list.buffer);
    return bdata.getFloat32(0, endian);
  }

  /// Get an int from a list of 4 bytes.
  static int getInt32(Uint8List list, [Endian endian = Endian.big]) {
    var bdata = ByteData.view(list.buffer);
    return bdata.getInt32(0, endian);
  }

  /// Get an int from a list of 2 bytes.
  static int getInt16(Uint8List list, [Endian endian = Endian.big]) {
    var bdata = ByteData.view(list.buffer);
    return bdata.getInt16(0, endian);
  }

  /// Get an int from a list of 1 byte.
  static int getInt8(Uint8List list) {
    var bdata = ByteData.view(list.buffer);
    return bdata.getInt8(0);
  }

  /// Convert a 64 bit integer [number] to its int representation.
  static List<int> bytesFromInt64(int number, [Endian endian = Endian.big]) {
    var tmp = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]);
    ByteData bdata = ByteData.view(tmp.buffer);
    bdata.setInt64(0, number, endian);
    return tmp;
  }

  /// Convert a 64 bit double [number] to its int representation.
  static List<int> bytesFromDouble64(double number,
      [Endian endian = Endian.big]) {
    var tmp = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0]);
    ByteData bdata = ByteData.view(tmp.buffer);
    bdata.setFloat64(0, number, endian);
    return tmp;
  }

  /// Read a file from [path] into a bytes list.
  static Uint8List bytesFromFile(String path) {
    File outputFile = File(path);
    return outputFile.readAsBytesSync();
  }

  /// Write a list of [bytes] to file and return the written file [path].
  static String bytesToFile(String path, List<int> bytes) {
    File outputFile = File(path);
    outputFile.writeAsBytesSync(bytes);
    return outputFile.path;
  }

  /// Convert a [name] into a list of bytes.
  static List<int> bytesFromString(String fileName) {
    return fileName.codeUnits;
  }

  static void addPadding(List<int> data, int requiredSize) {
    if (data.length < requiredSize) {
      // add padding to complete the mtu
      var add = requiredSize - data.length;
      for (int i = 0; i < add; i++) {
        data.add(0);
      }
    }
  }
}
