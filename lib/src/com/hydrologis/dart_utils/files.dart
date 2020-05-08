part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

/// Pure dart classes and methods for HydroloGIS projects.

/// File path and folder utilities.
class FileUtilities {
  static String joinPaths(String path1, String path2) {
    if (path2.startsWith('/')) {
      path2 = path2.substring(1);
      if (!path1.endsWith('/')) {
        path1 = path1 + '/';
      }
    }
    return join(path1, path2);
  }

  static String nameFromFile(String filePath, bool withExtension) {
    if (withExtension) {
      return basename(filePath);
    } else {
      return basenameWithoutExtension(filePath);
    }
  }

  static String getExtension(String filePath) {
    var lastDot = filePath.lastIndexOf(".");
    if (lastDot > 0) {
      return filePath.substring(lastDot + 1);
    } else {
      return null;
    }
  }

  static String parentFolderFromFile(String filePath) {
    return dirname(filePath);
  }

  static String readFile(String filePath) {
    return File(filePath).readAsStringSync();
  }

  static List<String> readFileToList(String filePath) {
    var fileText = readFile(filePath);
    List<String> split = fileText.split('\n');
    return split;
  }

  static void writeStringToFile(String filePath, String stringToWrite) {
    return File(filePath).writeAsStringSync(stringToWrite);
  }

  static void writeBytesToFile(String filePath, List<int> bytesToWrite) {
    return File(filePath).writeAsBytesSync(bytesToWrite);
  }

  static void copyFile(String fromPath, String toPath) {
    File from = File(fromPath);
    from.copySync(toPath);
  }

  /// Method to read a properties [file] into a hashmap.
  ///
  /// Empty lines are ignored, as well as lines that do not contain the separator.
  static Map<String, String> readFileToHashMap(String filePath,
      {String separator = "=", bool valueFirst = false}) {
    var fileTxt = readFile(filePath);
    var lines = fileTxt.split("\n");

    Map<String, String> propertiesMap = {};
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        continue;
      }
      int firstSep = line.indexOf(separator);
      if (firstSep == -1) {
        continue;
      }

      String first = line.substring(0, firstSep);
      String second = line.substring(firstSep + 1);

      if (!valueFirst) {
        propertiesMap[first] = second;
      } else {
        propertiesMap[second] = first;
      }
    }
    return propertiesMap;
  }

  /// Get the list of files names from a given [parentPath] and optionally filtered by [ext].
  static List<String> getFilesInPathByExt(String parentPath, [String ext]) {
    List<String> filenameList = [];

    try {
      Directory(parentPath).listSync().forEach((FileSystemEntity fse) {
        String path = fse.path;
        String filename = basename(path);
        if (ext == null || filename.endsWith(ext)) {
          filenameList.add(filename);
        }
      });
    } catch (e) {
      print(e);
    }
    return filenameList;
  }

  static List<List<dynamic>> listFiles(String parentPath,
      {bool doOnlyFolder = false,
      List<String> allowedExtensions,
      bool doHidden = false,
      bool order = true}) {
    List<List<dynamic>> pathAndNameList = [];

    try {
      var list = Directory(parentPath).listSync();
      for (var fse in list) {
        String path = fse.path;
        String filename = basename(path);
        if (filename.startsWith(".")) {
          continue;
        }
        String parentname = dirname(path);

        var isDirectory = FileSystemEntity.isDirectorySync(path);
        if (doOnlyFolder && !isDirectory) {
          continue;
        }

        if (isDirectory) {
          pathAndNameList.add(<dynamic>[parentname, filename, isDirectory]);
        } else if (allowedExtensions != null) {
          for (var ext in allowedExtensions) {
            if (filename.endsWith(ext)) {
              pathAndNameList.add(<dynamic>[parentname, filename, isDirectory]);
              break;
            }
          }
        } else {
          pathAndNameList.add(<dynamic>[parentname, filename, isDirectory]);
        }
      }
    } catch (e) {
      print(e);
    }

    pathAndNameList.sort((o1, o2) {
      String n1 = o1[1];
      String n2 = o2[1];
      return n1.compareTo(n2);
    });

    return pathAndNameList;
  }

  /// Get a temporary file.
  /// 
  /// This method doesn't create the file.
  static File getTmpFile(ext, {prefix: 'tmp_', postfix}) {
    postfix ??= TimeUtilities.DAYHOURMINUTE_TS_FORMATTER.format(DateTime.now());
    var fileName = prefix + postfix + '.' + ext;

    var dir = Directory.systemTemp.createTempSync();
    return File("${dir.path}/$fileName");
  }
}

/// A reader class to wrap the buffer method/package used.
class FileReader {
  final File _file;
  bool _isOpen = false;
  dynamic channel;

  FileReader(this._file, {buffered: false}) {
    if (buffered) {
      Stream<List<int>> stream = _file.openRead();
      channel = ChunkedStreamIterator(stream);
    } else {
      channel = _file.openSync();
    }
    _isOpen = true;
  }

  Future<int> getByte() async {
    return (await channel.read(1))[0];
  }

  Future<List<int>> get(int bytesCount) async {
    return await channel.read(bytesCount);
  }

  Future<int> getInt32([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(4));
    return ByteConversionUtilities.getInt32(data, endian);
  }

  Future skip(int bytesToSkip) async {
    await channel.read(bytesToSkip);
  }

  bool get isOpen => _isOpen;

  void close() {
    if (channel is RandomAccessFile) {
      channel?.closeSync();
    }
  }
}

/// A writer class.
class FileWriter {
  final File _file;
  bool _isOpen = false;
  RandomAccessFile randomAccessFile;

  FileWriter(this._file) {
    randomAccessFile = _file.openSync();
    _isOpen = true;
  }

  bool get isOpen => _isOpen;

  void close() {
    randomAccessFile?.closeSync();
  }

  Future<void> put(List<int> buffer) async {
    await randomAccessFile.writeFrom(buffer);
  }
}
