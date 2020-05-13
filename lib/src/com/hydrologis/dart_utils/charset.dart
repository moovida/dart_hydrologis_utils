part of dart_hydrologis_utils;

const UTF8 = "UTF-8";
const UTF16 = "UTF-16";

/// Abstract class for charset converters.
abstract class CharsetConverter {
  set charsetName(String charset);

  Future<String> decode(List<int> bytes);

  Future<List<int>> encode(String string);

  Future<List<String>> getAvailableCharsets();

  Future<bool> isSupported(String charset);
}

/// Dart's default charset converter, which does only utf-8 and utf-16.
class DefaultCharsetConverter extends CharsetConverter {
  bool do16 = false;

  @override
  Future<String> decode(List<int> bytes) => Future.value(do16
      ? String.fromCharCodes(bytes)
      : utf8.decode(bytes, allowMalformed: true));

  @override
  Future<List<int>> encode(String string) =>
      Future.value(do16 ? string.codeUnits : utf8.encode(string));

  @override
  Future<List<String>> getAvailableCharsets() => Future.value([UTF8, UTF16]);

  @override
  Future<bool> isSupported(String charset) {
    return Future.value(StringUtilities.equalsIgnoreCase(charset, UTF8) ||
        StringUtilities.equalsIgnoreCase(charset, UTF16));
  }

  @override
  set charsetName(String charset) {
    if (StringUtilities.equalsIgnoreCase(charset, UTF8)) {
      do16 = false;
    } else if (StringUtilities.equalsIgnoreCase(charset, UTF16)) {
      do16 = true;
    } else {
      throw ArgumentError(
          "Only $UTF8 and $UTF16 are supported by the default package. You can add your own CharsetConverter.");
    }
  }
}

/// Charset class, which can take other converters.
class Charset {
  static final Charset _singleton = Charset._internal();

  factory Charset() {
    return _singleton;
  }

  Charset._internal();

  CharsetConverter _charsetConverter = DefaultCharsetConverter();

  /// Set the coverter to use.
  set converter(CharsetConverter charsetConverter) {
    _charsetConverter = charsetConverter;
  }

  /// Set the [charsetName] to use.
  ///
  /// This must be supported by the current converter else an exception is thrown.
  Future<void> setCharsetEncoding(String charsetName) async {
    _charsetConverter.charsetName = charsetName;
  }

  /// Get the list of supported charsets
  Future<List<String>> getAvailableCharsets() async {
    return await _charsetConverter.getAvailableCharsets();
  }

  Future<bool> isSupported(String charEncoding) async {
    return await _charsetConverter.isSupported(charEncoding);
  }

  Future<String> decode(List<int> bytes) async {
    return await _charsetConverter.decode(bytes);
  }

  Future<List<int>> encode(String string) async {
    return await _charsetConverter.encode(string);
  }
}
