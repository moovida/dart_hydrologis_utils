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

/// File reader class, be it buffered or random.
///
/// This class can't rewind.
abstract class AFileReader {
  /// Get [bytesCount] of bytes into a list.
  Future<List<int>> get(int bytesCount);

  /// Get [bytesCount] of bytes into a [LByteBuffer].
  Future<LByteBuffer> getBuffer(int bytesCount);

  /// Read the amount of remaining bytes of the [buffer]
  /// from the reader. returns the real count read.
  Future<int> readIntoBuffer(LByteBuffer buffer);

  /// Get a single byte.
  Future<int> getByte();

  /// Get a 4 bytes integer with a chosen [endian]ness.
  Future<int> getInt32([Endian endian = Endian.big]);

  /// Get a 8 bytes double with a chosen [endian]ness.
  Future<double> getDouble64([Endian endian = Endian.big]);

  /// Get a 4 bytes float with a chosen [endian]ness.
  Future<double> getDouble32([Endian endian = Endian.big]);

  /// Skip [bytesToSkip] bytes.
  Future skip(int bytesToSkip);

  /// Check if the file is open.
  bool get isOpen;

  /// Close the reader.
  void close();
}

/// A reader class to wrap the buffer method/package used.
class FileReaderBuffered extends AFileReader {
  final File _file;
  bool _isOpen = false;
  ChunkedStreamIterator channel;

  FileReaderBuffered(this._file) {
    Stream<List<int>> stream = _file.openRead();
    channel = ChunkedStreamIterator(stream);
    _isOpen = true;
  }

  @override
  Future<int> getByte() async {
    return (await channel.read(1))[0];
  }

  @override
  Future<List<int>> get(int bytesCount) async {
    return await channel.read(bytesCount);
  }

  @override
  Future<int> readIntoBuffer(LByteBuffer buffer) async {
    List<int> read = await channel.read(buffer.remaining);
    buffer.set(read);
    if (read == null || read.isEmpty) {
      return -1;
    }
    return read.length;
  }

  @override
  Future<LByteBuffer> getBuffer(int bytesCount) async {
    return LByteBuffer.fromData(await channel.read(bytesCount));
  }

  @override
  Future<int> getInt32([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(4));
    return ByteConversionUtilities.getInt32(data, endian);
  }

  @override
  Future<double> getDouble64([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(8));
    return ByteConversionUtilities.getDouble64(data, endian);
  }

  @override
  Future<double> getDouble32([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(4));
    return ByteConversionUtilities.getDouble32(data, endian);
  }

  @override
  Future skip(int bytesToSkip) async {
    await channel.read(bytesToSkip);
  }

  @override
  bool get isOpen => _isOpen;

  @override
  void close() {
    _isOpen = false;
  }
}

/// A reader class to wrap the random method/package used.
class FileReaderRandom extends AFileReader {
  final File _file;
  bool _isOpen = false;
  RandomAccessFile channel;

  FileReaderRandom(this._file) {
    channel = _file.openSync();
    _isOpen = true;
  }

  @override
  Future<int> getByte() async {
    return (await channel.read(1))[0];
  }

  @override
  Future<List<int>> get(int bytesCount) async {
    return await channel.read(bytesCount);
  }

  @override
  Future<int> readIntoBuffer(LByteBuffer buffer) async {
    // List<int> read = [];
    int read = await channel.readInto(
        buffer._data, buffer._position, buffer._position + buffer.remaining);
    buffer._position = buffer._position + read;
    if (read <= 0) {
      return -1;
    }
    return read;
  }

  @override
  Future<LByteBuffer> getBuffer(int bytesCount) async {
    return LByteBuffer.fromData(await channel.read(bytesCount));
  }

  @override
  Future<int> getInt32([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(4));
    return ByteConversionUtilities.getInt32(data, endian);
  }

  @override
  Future<double> getDouble64([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(8));
    return ByteConversionUtilities.getDouble64(data, endian);
  }

  @override
  Future<double> getDouble32([Endian endian = Endian.big]) async {
    var data = Uint8List.fromList(await channel.read(4));
    return ByteConversionUtilities.getDouble32(data, endian);
  }

  @override
  Future skip(int bytesToSkip) async {
    await channel.read(bytesToSkip);
  }

  @override
  bool get isOpen => _isOpen;

  Future<void> setPosition(int newPosition) async {
    await channel.setPosition(newPosition);
  }

  Future<int> position() async {
    return await channel.position();
  }

  @override
  void close() {
    if (channel is RandomAccessFile) {
      channel?.closeSync();
    }
  }
}

/// A byte buffer that wraps a list of bytes.
///
/// Simplifies access to data.
class LByteBuffer {
  List<int> _data;

  int _position = 0;
  int _mark = -1;
  int _limit = 0;
  Endian _endian = Endian.big;

  final bool readOnly;
  final bool doSigned;

  LByteBuffer.fromData(List data,
      {this.readOnly = false, this.doSigned = false}) {
    if (doSigned) {
      _data = Int8List.fromList(data);
    } else {
      _data = Uint8List.fromList(data);
    }
    _limit = _data.length;
  }

  LByteBuffer(int size, {this.readOnly = false, this.doSigned = false}) {
    if (doSigned) {
      _data = Int8List(size);
    } else {
      _data = Uint8List(size);
    }
    _limit = size;
  }

  int getByte() {
    return _data[_position++];
  }

  String getByteChar() {
    return String.fromCharCode(_data[_position++]);
  }

  List<int> get(int length) {
    var sublist = _data.sublist(_position, _position + length);
    _position += length;
    return sublist;
  }

  int getInt32() {
    var ul = doSigned ? Int8List.fromList(get(4)) : Uint8List.fromList(get(4));
    return ByteConversionUtilities.getInt32(ul, _endian);
  }

  void putInt32(int num) {
    var bytesList =
        ByteConversionUtilities.bytesFromInt32(num, endian: _endian);
    _data.setRange(_position, _position + bytesList.length, bytesList);
    _position = _position + bytesList.length;
  }

  double getDouble64() {
    var ul = doSigned ? Int8List.fromList(get(8)) : Uint8List.fromList(get(8));
    return ByteConversionUtilities.getDouble64(ul, _endian);
  }

  void putDouble64(double num) {
    var bytesList =
        ByteConversionUtilities.bytesFromDouble64(num, endian: _endian);
    _data.setRange(_position, _position + bytesList.length, bytesList);
    _position = _position + bytesList.length;
  }

  double getDouble32() {
    var ul = doSigned ? Int8List.fromList(get(4)) : Uint8List.fromList(get(4));
    return ByteConversionUtilities.getDouble32(ul, _endian);
  }

  void skip(int bytesToSkip) {
    _position += bytesToSkip;
  }

  set position(int newPosition) {
    _position = newPosition;
  }

  void clear() {
    _limit = _data.length;
    _position = 0;
  }

  void compact() {
    var sublist = _data.sublist(_position, _limit);
    _data.setRange(0, sublist.length, sublist);
    _limit = _data.length;
    _position = sublist.length;
    _mark = 0;
  }

  void flip() {
    _limit = _position;
    _position = 0;
  }

  int get position => _position;

  int get limit => _limit;

  set limit(int newLimit) {
    _limit = newLimit;
    if (_position > _limit) {
      _position = _limit;
    }
  }

  int get remaining => _limit - _position;

  bool get isReadOnly => readOnly;

  int get capacity => _data.length;

  set endian(Endian newEndian) {
    _endian = newEndian;
  }

  void set(List<int> read) {
    if (read.length <= remaining) {
      _data.setRange(_position, _position + read.length, read);
      _position += read.length;
    } else {
      _data.setRange(
          _position, _position + remaining, read.sublist(0, remaining));
      _position += remaining;
    }
  }

  void mark() {
    _mark = _position;
  }

  void reset() {
    _position = _mark;
  }

  void rewind() {
    _position = 0;
    _mark = -1;
  }

  /// Put a [buffer] into this buffer, considering the current
  /// position and remaining bytes.
  void put(LByteBuffer buffer) {
    var rem = buffer.remaining;
    _data.setRange(_position, _position + rem, buffer._data, buffer._position);
    _position = _position + rem;
  }

  @override
  String toString() {
    var cols = 20;
    var f = NumberFormat("###");

    StringBuffer sb = StringBuffer();
    for (var i = 0; i < _data.length; i++) {
      sb.write("$i) ");
      for (var j = 0; j < cols; j++) {
        var data = _data[i++];
        if (data == null) {
          sb.write("***");
        } else {
          sb.write(f.format(data));
        }
        sb.write(" ");

        if (i == _data.length) {
          break;
        }
      }
      i--;
      sb.write("\n");
    }

    return sb.toString();
  }
}

/// A writer class.
class FileWriter {
  final File _file;
  bool _isOpen = false;
  RandomAccessFile randomAccessFile;

  FileWriter(this._file, {overwrite: true}) {
    if (_file.existsSync()) {
      if (overwrite) {
        _file.deleteSync();
      } else {
        throw StateError("The file $_file already exists. Can't overwrite");
      }
    }
    randomAccessFile = _file.openSync(mode: FileMode.append);
    _isOpen = true;
  }

  bool get isOpen => _isOpen;

  void close() {
    randomAccessFile?.closeSync();
  }

  Future<void> put(List<int> buffer) async {
    await randomAccessFile.writeFrom(buffer);
  }

  Future<void> putBuffer(LByteBuffer buffer) async {
    await randomAccessFile.writeFrom(buffer._data);
  }

  Future<void> putInt32(int value, [Endian endian = Endian.big]) async {
    var bytes = ByteConversionUtilities.bytesFromInt32(value, endian: endian);
    await randomAccessFile.writeFrom(bytes);
  }

  Future<void> putDouble64(double value, [Endian endian = Endian.big]) async {
    var bytes =
        ByteConversionUtilities.bytesFromDouble64(value, endian: endian);
    await randomAccessFile.writeFrom(bytes);
  }
}
