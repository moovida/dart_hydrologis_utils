import 'dart:io';

import 'package:image/image.dart';
import 'package:test/test.dart';
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';

void main() {
  group('SLD Reader tests', () {
    test('points_simple_circle_with_label', () async {
      var sldFile =
          File('./test/files/sld/points_simple_circle_with_label.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();
      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 1);
      expect(featureTypeStyles[0].name, "group0");

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 1);

      var pointSymbolizers = rules.first.pointSymbolizers;
      expect(pointSymbolizers.length, 1);
      expect(pointSymbolizers[0].style.markerName, WktMarkers.CIRCLE.name);
      expect(WktMarkers.forName(pointSymbolizers[0].style.markerName),
          WktMarkers.CIRCLE);
      expect(pointSymbolizers[0].style.markerSize, 15);
      expect(pointSymbolizers[0].style.strokeColorHex, "#00F900");
      expect(pointSymbolizers[0].style.strokeWidth, 2.0);
      expect(pointSymbolizers[0].style.strokeOpacity, 0.5);
      expect(pointSymbolizers[0].style.fillColorHex, "#ff0000");

      var textSymbolizers = rules.first.textSymbolizers;
      expect(textSymbolizers.length, 1);
      expect(textSymbolizers[0].style.labelName, "NAME");
      expect(textSymbolizers[0].style.size, 12.0);
      expect(textSymbolizers[0].style.textColor, "#000000");
    });
    test('lines_double_rule_like_road', () async {
      var sldFile = File('./test/files/sld/lines_double_rule_like_road.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();
      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 2);
      expect(featureTypeStyles[0].name, "line");
      expect(featureTypeStyles[0].rules[0].name, "line");
      expect(featureTypeStyles[1].name, "back line");
      expect(featureTypeStyles[1].rules[0].name, "back line");

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 1);
      var lineSymbolizers = rules.first.lineSymbolizers;
      expect(lineSymbolizers.length, 1);
      expect(lineSymbolizers[0].style.strokeColorHex, "#000000");
      expect(lineSymbolizers[0].style.strokeWidth, 9.0);

      rules = featureTypeStyles[1].rules;
      expect(rules.length, 1);
      lineSymbolizers = rules.first.lineSymbolizers;
      expect(lineSymbolizers.length, 1);
      expect(lineSymbolizers[0].style.strokeColorHex, "#8c8c8c");
      expect(lineSymbolizers[0].style.strokeWidth, 5.0);
    });
    test('lines_simple_with_labels', () async {
      var sldFile = File('./test/files/sld/lines_simple_with_labels.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();
      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 1);

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 1);

      var lineSymbolizers = rules.first.lineSymbolizers;
      expect(lineSymbolizers.length, 1);
      expect(lineSymbolizers[0].style.strokeColorHex, "#0432FF");
      expect(lineSymbolizers[0].style.strokeWidth, 2.0);

      var textSymbolizers = rules.first.textSymbolizers;
      expect(textSymbolizers.length, 1);
      expect(textSymbolizers[0].style.labelName, "name");
      expect(textSymbolizers[0].style.size, 12.0);
      expect(textSymbolizers[0].style.textColor, "#0432FF");
      expect(textSymbolizers[0].style.haloColor, "#FEFFFF");
      expect(textSymbolizers[0].style.haloSize, 1);
    });
    test('polygon_simple_with_labels', () async {
      var sldFile = File('./test/files/sld/polygon_simple_with_labels.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();
      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 1);

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 1);

      var lineSymbolizers = rules.first.lineSymbolizers;
      expect(lineSymbolizers.length, 0);

      var polygonSymbolizers = rules.first.polygonSymbolizers;
      expect(polygonSymbolizers.length, 1);

      expect(polygonSymbolizers[0].style.strokeColorHex, "#000000");
      expect(polygonSymbolizers[0].style.strokeWidth, 2.0);
      expect(polygonSymbolizers[0].style.strokeOpacity, 0.5);
      expect(polygonSymbolizers[0].style.fillColorHex, "#ff0000");
      expect(polygonSymbolizers[0].style.fillOpacity, 0.5);

      var textSymbolizers = rules.first.textSymbolizers;
      expect(textSymbolizers.length, 1);
      expect(textSymbolizers[0].style.labelName, "name");
      expect(textSymbolizers[0].style.size, 12.0);
      expect(textSymbolizers[0].style.textColor, "#000000");
    });
    test('polygon_simple_with_labels_qgis', () async {
      var sldFile =
          File('./test/files/sld/polygon_simple_with_labels_qgis.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();

      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 1);

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 2);

      var polygonSymbolizers = rules.first.polygonSymbolizers;
      expect(polygonSymbolizers.length, 1);

      expect(polygonSymbolizers[0].style.strokeColorHex, "#232323");
      expect(polygonSymbolizers[0].style.strokeWidth, 2.0);
      expect(polygonSymbolizers[0].style.fillColorHex, "#729b6f");

      var textSymbolizers = rules.last.textSymbolizers;
      expect(textSymbolizers.length, 1);
      expect(textSymbolizers[0].style.labelName, "NAME");
      expect(textSymbolizers[0].style.size, 25.0);
      expect(textSymbolizers[0].style.textColor, "#000000");
    });

    test('polygon_thematic_unique', () async {
      var sldFile = File('./test/files/sld/polygon_thematic_unique.sld');
      var sldObject = SldObjectParser.fromFile(sldFile);
      sldObject.parse();
      var featureTypeStyles = sldObject.featureTypeStyles;
      expect(featureTypeStyles.length, 1);

      var rules = featureTypeStyles[0].rules;
      expect(rules.length, 20);

      rules.forEach((rule) {
        var filter = rule.filter;
        var field = filter.uniqueValueKey;
        var value = filter.uniqueValueValue;
        expect(field, 'region');

        if (value == 'Abruzzo') {
          var style = rule.polygonSymbolizers.first.style;
          expect(style.fillColorHex, "#00BFBF");
          expect(style.fillOpacity, 0.5);
          expect(rule.name, 'rule01');
        } else if (value == 'Lombardia') {
          var style = rule.polygonSymbolizers.first.style;
          expect(style.fillColorHex, "#FFDF00");
          expect(style.fillOpacity, 0.5);
          expect(rule.name, 'rule10');
        } else if (value == 'Sardegna') {
          var style = rule.polygonSymbolizers.first.style;
          expect(style.fillColorHex, "#EF7F0F");
          expect(style.fillOpacity, 0.5);
          expect(rule.name, 'rule14');
        } else if (value == 'Trentino-Alto Adige') {
          var style = rule.polygonSymbolizers.first.style;
          expect(style.fillColorHex, "#BF7F3F");
          expect(style.fillOpacity, 0.5);
          expect(rule.name, 'rule17');
        }
      });
    });
  });
  group('SLD Writer tests', () {
    test('points_simple_with_label', () async {
      var sldFile =
          File('./test/files/sld/points_simple_circle_with_label.sld');
      var parser1 = SldObjectParser.fromFile(sldFile);
      parser1.parse();
      var pointStyle1 = parser1
          .featureTypeStyles.first.rules.first.pointSymbolizers.first.style;
      var textStyle1 = parser1
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;

      SldObjectBuilder builder = SldObjectBuilder("test");
      builder
          .addFeatureTypeStyle('group0')
          .addRule("rule 1")
          .addPointSymbolizer(pointStyle1)
          .addTextSymbolizer(textStyle1);
      var sldXml = builder.build();

      var parser2 = SldObjectParser.fromString(sldXml);
      parser2.parse();
      var pointStyle2 = parser2
          .featureTypeStyles.first.rules.first.pointSymbolizers.first.style;
      expect(pointStyle1 == pointStyle2, true);
      var textStyle2 = parser2
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
      expect(textStyle1 == textStyle2, true);
    });
    test('lines_simple_with_labels', () async {
      var sldFile = File('./test/files/sld/lines_simple_with_labels.sld');
      var parser1 = SldObjectParser.fromFile(sldFile);
      parser1.parse();
      var lineStyle1 = parser1
          .featureTypeStyles.first.rules.first.lineSymbolizers.first.style;
      var textStyle1 = parser1
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;

      SldObjectBuilder builder = SldObjectBuilder("test");
      builder
          .addFeatureTypeStyle('group0')
          .addRule("rule 1")
          .addLineSymbolizer(lineStyle1)
          .addTextSymbolizer(textStyle1);
      var sldXml = builder.build();

      var parser2 = SldObjectParser.fromString(sldXml);
      parser2.parse();
      var lineStyle2 = parser2
          .featureTypeStyles.first.rules.first.lineSymbolizers.first.style;
      expect(lineStyle1 == lineStyle2, true);
      var textStyle2 = parser2
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
      expect(textStyle1 == textStyle2, true);
    });
    test('polygon_simple_with_labels', () async {
      var sldFile = File('./test/files/sld/polygon_simple_with_labels.sld');
      var parser1 = SldObjectParser.fromFile(sldFile);
      parser1.parse();
      var polygonStyle1 = parser1
          .featureTypeStyles.first.rules.first.polygonSymbolizers.first.style;
      var textStyle1 = parser1
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;

      SldObjectBuilder builder = SldObjectBuilder("test");
      builder
          .addFeatureTypeStyle('group0')
          .addRule("rule 1")
          .addPolygonSymbolizer(polygonStyle1)
          .addTextSymbolizer(textStyle1);
      var sldXml = builder.build();

      var parser2 = SldObjectParser.fromString(sldXml);
      parser2.parse();
      var polygonStyle2 = parser2
          .featureTypeStyles.first.rules.first.polygonSymbolizers.first.style;
      expect(polygonStyle1 == polygonStyle2, true);
      var textStyle2 = parser2
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
      expect(textStyle1 == textStyle2, true);
    });
    test('lines_double_rule_like_road', () async {
      var sldFile = File('./test/files/sld/lines_double_rule_like_road.sld');
      var parser1 = SldObjectParser.fromFile(sldFile);
      parser1.parse();
      var lineStyle11 =
          parser1.featureTypeStyles[0].rules.first.lineSymbolizers.first.style;
      var lineStyle12 =
          parser1.featureTypeStyles[1].rules.first.lineSymbolizers.first.style;

      SldObjectBuilder builder = SldObjectBuilder("test");
      builder
          .addFeatureTypeStyle('line')
          .addRule("line")
          .addLineSymbolizer(lineStyle11)
          .addFeatureTypeStyle('black line')
          .addRule("black line")
          .addLineSymbolizer(lineStyle12);
      var sldXml = builder.build();

      var parser2 = SldObjectParser.fromString(sldXml);
      parser2.parse();
      var lineStyle21 =
          parser2.featureTypeStyles[0].rules.first.lineSymbolizers.first.style;
      var lineStyle22 =
          parser2.featureTypeStyles[1].rules.first.lineSymbolizers.first.style;

      expect(lineStyle11 == lineStyle21, true);
      expect(lineStyle12 == lineStyle22, true);
    });
    test('test defaults', () async {
      var defaultPointSld = DefaultSlds.simplePointSld();
      var parser = SldObjectParser.fromString(defaultPointSld);
      parser.parse();
      var pointStyle =
          parser.featureTypeStyles[0].rules.first.pointSymbolizers.first.style;
      expect(pointStyle == PointStyle(), true);

      var defaultLineSld = DefaultSlds.simpleLineSld();
      parser = SldObjectParser.fromString(defaultLineSld);
      parser.parse();
      var lineStyle =
          parser.featureTypeStyles[0].rules.first.lineSymbolizers.first.style;
      expect(lineStyle == LineStyle(), true);

      var defaultPolygonSld = DefaultSlds.simplePolygonSld();
      parser = SldObjectParser.fromString(defaultPolygonSld);
      parser.parse();
      var polygonStyle = parser
          .featureTypeStyles[0].rules.first.polygonSymbolizers.first.style;
      expect(polygonStyle == PolygonStyle(), true);
    });
    test('test build from fts', () async {
      var sldFile = File('./test/files/sld/polygon_thematic_unique.sld');
      var parser1 = SldObjectParser.fromFile(sldFile);
      parser1.parse();
      var fts1 = parser1.featureTypeStyles;

      var sldString = SldObjectBuilder.buildFromFeatureTypeStyles(fts1);

      var parser2 = SldObjectParser.fromString(sldString);
      parser2.parse();
      var fts2 = parser2.featureTypeStyles;

      expect(fts1.length, fts2.length);
      for (var i = 0; i < fts1.length; i++) {
        var rules1 = fts1[i].rules;
        var rules2 = fts2[i].rules;
        expect(rules1.length, rules2.length);

        for (var j = 0; j < rules1.length; j++) {
          var rule1 = rules1[j];
          var rule2 = rules2[j];
          expect(
              rule1.polygonSymbolizers.length, rule2.polygonSymbolizers.length);
          expect(rule1.lineSymbolizers.length, rule2.lineSymbolizers.length);
          expect(rule1.pointSymbolizers.length, rule2.pointSymbolizers.length);
          expect(rule1.textSymbolizers.length, rule2.textSymbolizers.length);

          if (rule1.filter != null) {
            expect(rule2.filter != null, true);

            expect(rule1.filter.uniqueValueKey, rule2.filter.uniqueValueKey);
            expect(
                rule1.filter.uniqueValueValue, rule2.filter.uniqueValueValue);
          }
        }
      }
    });
  });
  group('SLD modify tests', () {
    test('test add/remove textstyle', () async {
      var defaultPointSld = DefaultSlds.simplePointSld();
      var parser = SldObjectParser.fromString(defaultPointSld);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.textSymbolizers.length, 0);

      // add text style inside rule
      var rule = parser.featureTypeStyles.first.rules.first;
      var textStyle = TextStyle();
      rule.addTextStyle(textStyle);

      expect(
          parser.featureTypeStyles.first.rules.first.textSymbolizers.length, 1);

      // generate new sld xml and reparse it
      var sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();
      expect(
          parser.featureTypeStyles.first.rules.first.textSymbolizers.length, 1);

      // get the rule of the new sld
      var actual = parser
          .featureTypeStyles.first.rules.first.textSymbolizers.first.style;
      var matcher = TextStyle();
      expect(actual == matcher, true);

      // remove teh text from teh style again
      rule = parser.featureTypeStyles.first.rules.first;
      rule.removeTextStyle(textStyle);

      expect(
          parser.featureTypeStyles.first.rules.first.textSymbolizers.length, 0);

      // generate new sld xml and reparse it
      sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.textSymbolizers.length, 0);
    });

    test('test add/remove pointstyle', () async {
      var defaultPointSld = DefaultSlds.simplePointSld();
      var parser = SldObjectParser.fromString(defaultPointSld);
      parser.parse();

      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          1);

      var rule = parser.featureTypeStyles.first.rules.first;
      var pointStyle = PointStyle();
      rule.addPointStyle(pointStyle);

      // before conversion to XML
      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          2);

      // after conversion to XML
      var sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();
      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          2);

      rule = parser.featureTypeStyles.first.rules.first;
      rule.removePointStyle(pointStyle);

      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          1);

      // generate new sld xml and reparse it
      sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();
      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          1);
    });
    test('test add/remove linestyle', () async {
      var defaultPointSld = DefaultSlds.simplePointSld();
      var parser = SldObjectParser.fromString(defaultPointSld);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.lineSymbolizers.length, 0);

      var rule = parser.featureTypeStyles.first.rules.first;
      var lineStyle = LineStyle();
      rule.addLineStyle(lineStyle);
      expect(
          parser.featureTypeStyles.first.rules.first.lineSymbolizers.length, 1);

      var sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();
      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          1);
      expect(
          parser.featureTypeStyles.first.rules.first.lineSymbolizers.length, 1);

      rule = parser.featureTypeStyles.first.rules.first;
      rule.removeLineStyle(lineStyle);
      expect(
          parser.featureTypeStyles.first.rules.first.lineSymbolizers.length, 0);

      // generate new sld xml and reparse it
      sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.lineSymbolizers.length, 0);
    });
    test('test add/remove polygonstyle', () async {
      var defaultPointSld = DefaultSlds.simplePointSld();
      var parser = SldObjectParser.fromString(defaultPointSld);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.polygonSymbolizers.length,
          0);

      var rule = parser.featureTypeStyles.first.rules.first;
      var polygonStyle = PolygonStyle();
      rule.addPolygonStyle(polygonStyle);

      expect(
          parser.featureTypeStyles.first.rules.first.polygonSymbolizers.length,
          1);

      var sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();
      expect(parser.featureTypeStyles.first.rules.first.pointSymbolizers.length,
          1);
      expect(
          parser.featureTypeStyles.first.rules.first.polygonSymbolizers.length,
          1);

      rule = parser.featureTypeStyles.first.rules.first;
      rule.removePolygonStyle(polygonStyle);

      expect(
          parser.featureTypeStyles.first.rules.first.polygonSymbolizers.length,
          0);

      // generate new sld xml and reparse it
      sldString = parser.toSldString();
      parser = SldObjectParser.fromString(sldString);
      parser.parse();

      expect(
          parser.featureTypeStyles.first.rules.first.polygonSymbolizers.length,
          0);
    });
  });

  group('Files tests', () {
    test('bytes check', () async {
      var chineseShp = File('./test/files/chinese_poly.shp');
      var reader = FileReaderRandom(chineseShp);
      try {
        var buffer = LByteBuffer(1024, doSigned: true);
        int r = buffer.remaining;
        while (buffer.remaining > 0 && r != -1) {
          r = await reader.readIntoBuffer(buffer);
        }
        buffer.flip();
        for (var i = 0; i < chinShpBytes.length; i++) {
          var byte = buffer.getByte();
          expect(byte, chinShpBytes[i],
              reason: "$byte is not ${chinShpBytes[i]}");
        }
      } finally {
        reader?.close();
      }
    });
  });
  group('Charset tests', () {
    // test strings taken from; http://kermitproject.org/utf8.html
    test('russian utf8', () async {
      await checkUtf8("russian", "На берегу пустынных волн");
    });
    test('milanese utf8', () async {
      await checkUtf8(
          "milanese", "Sôn bôn de magnà el véder, el me fa minga mal.");
    });
    test('turkish utf8', () async {
      await checkUtf8("turkish", "جام ييه بلورم بڭا ضررى طوقونمز");
    });
    test('japanese utf8', () async {
      await checkUtf8("japanese", "私はガラスを食べられます。それは私を傷つけません。");
    });
    test('korean utf8', () async {
      await checkUtf8("korean", "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요");
    });
    test('thai utf8', () async {
      await checkUtf8("thai", "ฉันกินกระจกได้ แต่มันไม่ทำให้ฉันเจ็บ");
    });
    test('chinese utf8', () async {
      await checkUtf8("chinese", "我能吞下玻璃而不伤身体。");
    });
  });

  group('utils tests', () {
    test('time formatter', () async {
      expect(StringUtilities.formatMeters(90.8), "91 m");
      expect(StringUtilities.formatMeters(90.3), "90 m");
      expect(StringUtilities.formatMeters(1000), "1.0 km");
      expect(StringUtilities.formatMeters(12500), "12.5 km");

      expect(StringUtilities.formatDurationMillis(1000), "1 sec");
      expect(StringUtilities.formatDurationMillis(100000), "1 min, 40 sec");
      expect(StringUtilities.formatDurationMillis(10000000), "2 h, 46 min");
    });
  });
  group('image tests', () {
    test('color to alpha', () async {
      var imgfile = File('./test/files/img/blackred2x2.png');

      var bytes = ImageUtilities.bytesFromImageFile(imgfile.path);
      var newBytes = ImageUtilities.colorToAlpha(bytes, 0, 0, 0);

      var newImage = decodeImage(newBytes);
      var newPixels = newImage.getBytes(format: Format.rgba);

      //check changed alpha
      expect(newPixels[3], 0);
      expect(newPixels[7], 255);
      expect(newPixels[11], 255);
      expect(newPixels[15], 0);
    });

    test('color to alpha gimp', () async {
      var imgfile = File('./test/files/img/colors4x4.png');

      var bytes = ImageUtilities.bytesFromImageFile(imgfile.path);

      var image = decodeImage(bytes);
      ImageUtilities.colorToAlphaBlend(image, 0, 0, 0);

      var newImageBytes = encodePng(image);

      var bytesString = newImageBytes.join(",");
      expect(bytesString, c2aExpected);
    });
  });

  group('singleband image tests', () {
    test('dtm test', () async {
      var imgfile = File('./test/files/singleband/dtm_test.tiff');
      var bytes = ImageUtilities.bytesFromImageFile(imgfile.path);

      var image = TiffDecoder().decodeHdrImage(bytes);
      expect(image.width, 10);
      expect(image.height, 8);

      for (var row = 0; row < image.height; row++) {
        for (var col = 0; col < image.width; col++) {
          var redValue = image.red.getFloat(col, row);
          if (redValue == -10000.0) {
            // the image library doesn't read the novalue properly
            // for now ignore it
            continue;
          }
          expect(redValue, expectedSingleBandData[row][col]);
        }
      }
      var float32list = image.toFloatRgba();
      var cols = image.width;
      for (var row = 0; row < image.height; row++) {
        for (var col = 0; col < cols; col++) {
          var index = row * cols * 4 + col * 4;
          var value = float32list[index];
          if (value == -10000.0) {
            // the image library doesn't read the novalue properly
            // for now ignore it
            continue;
          }
          expect(value, expectedSingleBandData[row][col]);
        }
      }
    });
  });
}

Future<void> checkUtf8(String testFile, String match) async {
  var charsetFile = File('./test/files/charsets/$testFile');
  List<int> bytes = FileUtilities.readFileBytes(charsetFile.path);

  var charsetUtf8 = Charset();
  var string = await charsetUtf8.decode(bytes);
  expect(string, match);
}

var expectedSingleBandData = [
  [
    800.0,
    900.0,
    1000.0,
    1000.0,
    1200.0,
    1250.0,
    1300.0,
    1350.0,
    1450.0,
    1500.0
  ],
  [
    600.0,
    -9999.0,
    750.0,
    850.0,
    860.0,
    900.0,
    1000.0,
    1200.0,
    1250.0,
    1500.0
  ], //
  [500.0, 550.0, 700.0, 750.0, 800.0, 850.0, 900.0, 1000.0, 1100.0, 1500.0], //
  [400.0, 410.0, 650.0, 700.0, 750.0, 800.0, 850.0, 490.0, 450.0, 1500.0], //
  [450.0, 550.0, 430.0, 500.0, 600.0, 700.0, 800.0, 500.0, 450.0, 1500.0], //
  [500.0, 600.0, 700.0, 750.0, 760.0, 770.0, 850.0, 1000.0, 1150.0, 1500.0], //
  [600.0, 700.0, 750.0, 800.0, 780.0, 790.0, 1000.0, 1100.0, 1250.0, 1500.0], //
  [
    800.0,
    910.0,
    980.0,
    1001.0,
    1150.0,
    1200.0,
    1250.0,
    1300.0,
    1450.0,
    1500.0
  ], //
];

var c2aExpected =
    "137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,4,0,0,0,4,8,6,0,0,0,169,241,158,126,0,0,1,133,105,67,67,80,73,67,67,32,112,114,111,102,105,108,101,0,0,40,145,125,145,59,72,195,80,20,134,255,182,74,85,42,29,236,32,210,33,67,117,178,32,190,112,212,42,20,161,66,168,21,90,117,48,185,233,11,154,52,36,41,46,142,130,107,193,193,199,98,213,193,197,89,87,7,87,65,16,124,128,56,57,58,41,186,72,137,231,38,133,22,49,30,184,220,143,255,158,255,231,222,115,1,127,163,194,84,179,107,12,80,53,203,72,39,19,66,54,183,42,4,95,209,11,31,194,136,98,74,98,166,62,39,138,41,120,214,215,61,245,82,221,197,121,150,119,223,159,213,175,228,77,6,248,4,226,89,166,27,22,241,6,241,244,166,165,115,222,39,142,176,146,164,16,159,19,143,26,116,65,226,71,174,203,46,191,113,46,58,236,231,153,17,35,147,158,39,142,16,11,197,14,150,59,152,149,12,149,120,146,56,166,168,26,229,251,179,46,43,156,183,56,171,149,26,107,221,147,191,48,148,215,86,150,185,78,43,138,36,22,177,4,17,2,100,212,80,70,5,22,226,180,107,164,152,72,211,121,194,195,63,228,248,69,114,201,228,42,131,145,99,1,85,168,144,28,63,248,31,252,158,173,89,152,24,119,147,66,9,160,251,197,182,63,134,129,224,46,208,172,219,246,247,177,109,55,79,128,192,51,112,165,181,253,213,6,48,243,73,122,189,173,197,142,128,240,54,112,113,221,214,228,61,224,114,7,24,124,210,37,67,114,164,0,45,127,161,0,188,159,209,55,229,128,129,91,160,111,205,157,91,235,28,167,15,64,134,102,149,186,1,14,14,129,145,34,101,175,123,188,187,167,115,110,255,246,180,230,247,3,114,163,114,167,239,222,189,64,0,0,0,41,73,68,65,84,120,1,99,97,248,207,32,197,192,200,240,236,63,3,131,47,3,16,176,128,56,12,72,128,229,63,16,128,24,140,140,80,1,6,52,0,0,117,26,8,66,140,45,32,143,0,0,0,0,73,69,78,68,174,66,96,130";

var chinShpBytes = [
  0, 0, 39, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 3, -90, -24, 3, 0, 0, 5, 0, 0, 0, -45, -101, 30, 20, -94, 63, 94, 64, 0, //
  0, 0, 32, 78, -67, 69, 64, 0, 0, 0, -128, -91, -30, 96, 64, -8, -21, -110, //
  23, -103, -18, 74, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, //
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2, -128, 5, 0, 0,
  0,
  0, //
  0, 0, -32, -53, 75, 94, 64, 0, 0, 0, 32, 78, -67, 69, 64, 0, 0, 0, -128, -91,
  -30, //
  96, 64, 0, 0, 0, 0, -1, -58, 74, 64, 1, 0, 0, 0, 77, 0, 0, 0, 0, 0, 0, 0, 0,
  0, //
  0, -96, 66, 95, 94, 64, 0, 0, 0, 64, -108, -86, 74, 64, 0, 0, 0, -32, 37, -31,
  94, //
  64, 0, 0, 0, 0, -1, -58, 74, 64, 0, 0, 0, -32, -57, 54, 95, 64, 0, 0, 0, 0,
  -53, //
  -116, 74, 64, 0, 0, 0, 32, -75, 103, 95, 64, 0, 0, 0, -32, -99, -120, 74, 64,
  0, 0, //
  0, 96, 95, -93, 95, 64, 0, 0, 0, -128, -126, 16, 74, 64, 0, 0, 0, -96, 23,
  -99, 95, //
  64, 0, 0, 0, -32, -112, -7, 73, 64, 0, 0, 0, -96, -119, -76, 95, 64, 0, 0, 0,
  -64, //
  -39, -94, 73, 64, 0, 0, 0, -32, 48, -66, 95, 64, 0, 0, 0, -64, -51, -88, 73,
  64, 0, //
  0, 0, -64, 94, -70, 95, 64, 0, 0, 0, 0, -106, -120, 73, 64, 0, 0, 0, -96, 89,
  -26, //
  95, 64, 0, 0, 0, 64, -29, 26, 73, 64, 0, 0, 0, -64, -12, -31, 95, 64, 0, 0, 0,
  -96, //
  111, -23, 72, 64, 0, 0, 0, -32, 82, -13, 95, 64, 0, 0, 0, -96, 80, -53, 72,
  64, 0, //
  0, 0, 32, -115, 48, 96, 64, 0, 0, 0, -64, -85, -74, 72, 64, 0, 0, 0, -96, -29,
  70, //
  96, 64, 0, 0, 0, 96, 89, 111, 72, 64, 0, 0, 0, -128, 83, 85, 96, 64, 0, 0, 0,
  -32, 71, //
  112,
  72,
  64,
  0,
  0,
  0,
  -32,
  -26,
  80,
  96,
  64,
  0,
  0,
  0,
  -32,
  -14,
  78,
  72,
  64,
  0,
  0,
  0,
  96,
  -86,
  90,
  96,
  64,
  0,
  0,
  0,
  -64,
  24,
  39,
  72,
  64,
  0,
  0,
  0,
  -32,
  23,
  85,
  96,
  64,
  0,
  0,
  0,
  32,
  -47,
  12,
  72,
  64,
  0,
  0,
  0,
  -32,
  -38,
  95,
  96,
  64,
  0,
  0,
  0,
  96,
  99,
  -39,
  71,
  64,
  0,
  0,
  0,
  96,
  54,
  -111,
  96,
  64,
  0,
  0,
  0,
  32,
  -6,
  -34,
  71,
  64,
  0,
  0,
  0,
  -64,
  -76,
  -92,
  96,
  64,
  0,
  0,
  0,
  -64,
  20,
  14,
  72,
  64,
  0,
  0,
  0,
  -128,
  -91,
  -30,
  96,
  64,
  0,
  0,
  0,
  64,
  -102,
  52,
  72,
  64,
  0,
  0,
  0,
  -128,
  108,
  -43,
  96,
  64,
  0,
  0,
  0,
  -96,
  -91,
  30,
  72,
  64,
  0,
  0,
  0,
  96,
  -50,
  -47,
  96,
  64,
  0,
  0,
  0,
  0,
  -5,
  -3,
  71,
  64,
  0,
  0,
  0,
  0,
  -49,
  -40,
  96,
  64,
  0,
  0,
  0,
  -32,
  -125,
  -36,
  71,
  64,
  0,
  0,
  0,
  -32,
  -121,
  -59,
  96,
  64,
  0,
  0,
  0,
  64,
  56,
  -87,
  71,
  64,
  0,
  0,
  0,
  32,
  74,
  -67,
  96,
  64,
  0,
  0,
  0,
  32,
  -61,
  33,
  71,
  64,
  0,
  0,
  0,
  0,
  -74,
  -91,
  96,
  64,
  0,
  0,
  0,
  -128,
  -93,
  -65,
  70,
  64,
  0,
  0,
  0,
  -128,
  7,
  -92,
  96,
  64,
  0,
  0,
  0,
  -128,
  -40,
  -113,
  70,
  64,
  0,
  0,
  0,
  32,
  54,
  124,
  96,
  64,
  0,
  0,
  0,
  -32,
  103,
  -85,
  70,
  64,
  0,
  0,
  0,
  64,
  91,
  111,
  96,
  64,
  0,
  0,
  0,
  0,
  120,
  123,
  70,
  64,
  0,
  0,
  0,
  96,
  -110,
  94,
  96,
  64,
  0,
  0,
  0,
  0,
  54,
  109,
  70,
  64,
  0,
  0,
  0,
  0,
  94,
  105,
  96,
  64,
  0,
  0,
  0,
  32,
  78,
  -67,
  69,
  64,
  0,
  0,
  0,
  -64,
  -115,
  80,
  96,
  64,
  0,
  0,
  0,
  64,
  -26,
  -49,
  69,
  64,
  0,
  0,
  0,
  -96,
  77,
  75,
  96,
  64,
  0,
  0,
  0,
  -32,
  -82,
  5,
  70,
  64,
  0,
  0,
  0,
  32,
  15,
  66,
  96,
  64,
  0,
  0,
  0,
  32,
  -16,
  -22,
  69,
  64,
  0,
  0,
  0,
  -96,
  5,
  62,
  96,
  64,
  0,
  0,
  0,
  0,
  -57,
  3,
  70,
  64,
  0,
  0,
  0,
  0,
  96,
  39,
  96,
  64,
  0,
  0,
  0,
  0,
  67,
  -25,
  69,
  64,
  0,
  0,
  0,
  -32,
  61,
  39,
  96,
  64,
  0,
  0,
  0,
  -64,
  -103,
  -52,
  69,
  64,
  0,
  0,
  0,
  -128,
  -88,
  28,
  96,
  64,
  0,
  0,
  0,
  0,
  35,
  -59,
  69,
  64,
  0,
  0,
  0,
  -32,
  -127,
  11,
  96,
  64,
  0,
  0,
  0,
  96,
  26,
  65,
  70,
  64,
  0,
  0,
  0,
  -32,
  126,
  1,
  96,
  64,
  0,
  0,
  0,
  -96,
  84,
  44,
  70,
  64,
  0,
  0,
  0,
  0,
  20,
  3,
  96,
  64,
  0,
  0,
  0,
  64,
  -49,
  16,
  70,
  64,
  0,
  0,
  0,
  -64,
  -41,
  -15,
  95,
  64,
  0,
  0,
  0,
  96,
  3,
  9,
  70,
  64,
  0,
  0,
  0,
  -32,
  86,
  -34,
  95,
  64,
  0,
  0,
  0,
  -128,
  -1,
  50,
  70,
  64,
  0,
  0,
  0,
  96,
  -39,
  -29,
  95,
  64,
  0,
  0,
  0,
  96,
  41,
  70,
  70,
  64,
  0,
  0,
  0,
  32,
  -48,
  -62,
  95,
  64,
  0,
  0,
  0,
  -32,
  96,
  72,
  70,
  64,
  0,
  0,
  0,
  -128,
  -28,
  -68,
  95,
  64,
  0,
  0,
  0,
  0,
  95,
  -110,
  70,
  64,
  0,
  0,
  0,
  -64,
  122,
  125,
  95,
  64,
  0,
  0,
  0,
  -96,
  75,
  -107,
  70,
  64,
  0,
  0,
  0,
  -64,
  7,
  108,
  95,
  64,
  0,
  0,
  0,
  0,
  -5,
  -64,
  70,
  64,
  0,
  0,
  0,
  -32,
  59,
  25,
  95,
  64,
  0,
  0,
  0,
  64,
  63,
  -72,
  70,
  64,
  0,
  0,
  0,
  0,
  126,
  0,
  95,
  64,
  0,
  0,
  0,
  -96,
  -16,
  -33,
  70,
  64,
  0,
  0,
  0,
  -96,
  3,
  -3,
  94,
  64,
  0,
  0,
  0,
  -96,
  103,
  36,
  71,
  64,
  0,
  0,
  0,
  96,
  -14,
  -54,
  94,
  64,
  0,
  0,
  0,
  64,
  -109,
  31,
  71,
  64,
  0,
  0,
  0,
  -32
];
