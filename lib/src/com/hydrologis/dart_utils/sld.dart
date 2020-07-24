part of dart_hydrologis_utils;

enum Types {
  STROKE_WIDTH,
  STROKE_COLOR,
  STROKE_OPACITY,
  FILL_COLOR,
  FILL_OPACITY,
  TEXT_LABEL_FIELD,
  TEXT_LABEL_SIZE,
  TEXT_LABEL_COLOR,
  TEXT_LABEL_HALO_SIZE,
  TEXT_LABEL_HALO_COLOR,
  MARKER_NAME,
  MARKER_SIZE,
}

const STYLEDLAYERDESCRIPTOR = "StyledLayerDescriptor";
const FEATURETYPESTYLE = "FeatureTypeStyle";
const RULE = "Rule";

const FILTER = "Filter";
const PROPERTY_IS_EQUAL_TO = "PropertyIsEqualTo";
const LITERAL = "Literal";

const LINESYMBOLIZER = "LineSymbolizer";
const POINTSYMBOLIZER = "PointSymbolizer";
const POLYGONSYMBOLIZER = "PolygonSymbolizer";
const TEXTSYMBOLIZER = "TextSymbolizer";

const STROKE = "Stroke";
const FILL = "Fill";
const LABEL = "Label";
const SIZE = "Size";
const FONT = "Font";
const HALO = "Halo";
const RADIUS = "Radius";
const GRAPHIC = "Graphic";
const MARK = "Mark";
const WELLKNOWNNAME = "WellKnownName";
const CSS_PARAMETER = "CssParameter";
const SVG_PARAMETER = "SvgParameter";
const PROPERTY_NAME = "PropertyName";

const ATTRIBUTE_NAME = "name";
const ATTRIBUTE_STROKE = "stroke";
const ATTRIBUTE_FILL = "fill";
const ATTRIBUTE_FILL_OPACITY = "fill-opacity";
const ATTRIBUTE_STROKE_WIDTH = "stroke-width";
const ATTRIBUTE_STROKE_OPACITY = "stroke-opacity";
const ATTRIBUTE_FONT_SIZE = "font-size";

const DEF_NSP = '*';

/// An SLD file parser.
///
/// Once parsed, the list of FeatureTypeStyle can be accessed through [featureTypeStyles].
class SldObjectParser {
  xml.XmlDocument document;

  List<FeatureTypeStyle> featureTypeStyles = [];

  SldObjectParser(this.document);

  SldObjectParser.fromString(String xmlString)
      : this(xml.XmlDocument.parse(xmlString.trim()));

  SldObjectParser.fromFile(File xmlFile)
      : this.fromString(FileUtilities.readFile(xmlFile.path));

  /// Parse the SLD xml.
  void parse() {
    var root = document.findElements(STYLEDLAYERDESCRIPTOR, namespace: DEF_NSP);
    if (root == null || root.isEmpty) {
      throw ArgumentError("The file doesn't seem to be an SLD file.");
    } else {
      var featureTypeStyleList =
          document.findAllElements(FEATURETYPESTYLE, namespace: DEF_NSP);
      // we read just the first
      for (var featureTypeStyle in featureTypeStyleList) {
        FeatureTypeStyle fts = FeatureTypeStyle(featureTypeStyle);
        featureTypeStyles.add(fts);
      }
    }
  }
}

class FeatureTypeStyle {
  List<Rule> rules = [];

  FeatureTypeStyle(xml.XmlElement xmlElement) {
    var allRules = xmlElement.findAllElements(RULE, namespace: DEF_NSP);
    for (var r in allRules) {
      Rule rule = Rule(r);
      rules.add(rule);
    }
  }
}

class Rule {
  List<PointSymbolizer> pointSymbolizers = [];
  List<LineSymbolizer> lineSymbolizers = [];
  List<PolygonSymbolizer> polygonSymbolizers = [];
  List<TextSymbolizer> textSymbolizers = [];
  Filter filter;

  Rule(xml.XmlElement xmlElement) {
    var pointSymbolizersList =
        xmlElement.findElements(POINTSYMBOLIZER, namespace: DEF_NSP);
    for (var pointSymbolizer in pointSymbolizersList) {
      PointSymbolizer ps = PointSymbolizer(pointSymbolizer);
      pointSymbolizers.add(ps);
    }
    var lineSymbolizersList =
        xmlElement.findElements(LINESYMBOLIZER, namespace: DEF_NSP);
    for (var lineSymbolizer in lineSymbolizersList) {
      LineSymbolizer ls = LineSymbolizer(lineSymbolizer);
      lineSymbolizers.add(ls);
    }
    var polygonSymbolizersList =
        xmlElement.findElements(POLYGONSYMBOLIZER, namespace: DEF_NSP);
    for (var polygonSymbolizer in polygonSymbolizersList) {
      PolygonSymbolizer ls = PolygonSymbolizer(polygonSymbolizer);
      polygonSymbolizers.add(ls);
    }
    var textSymbolizersList =
        xmlElement.findElements(TEXTSYMBOLIZER, namespace: DEF_NSP);
    for (var textSymbolizer in textSymbolizersList) {
      TextSymbolizer ts = TextSymbolizer(textSymbolizer);
      textSymbolizers.add(ts);
    }

    // find filters
    var filtersList = xmlElement.findElements(FILTER, namespace: DEF_NSP);
    if (filtersList != null && filtersList.isNotEmpty) {
      filter = Filter();
      filtersList.forEach((element) {
        // check unique filter, right now only a simple is supported
        var pEquals = _findSingleElement(element, PROPERTY_IS_EQUAL_TO);
        if (pEquals != null) {
          var pName = _findSingleElement(pEquals, PROPERTY_NAME);
          var literal = _findSingleElement(pEquals, LITERAL);
          if (pName != null && literal != null) {
            var fieldName = pName.text;
            var fieldValue = literal.text;
            filter.uniqueValueKey = fieldName;
            filter.uniqueValueValue = fieldValue;
          }
        }
      });
    }
  }
}

/// Default point style class.
class PointStyle {
  String markerName = "Circle";
  double markerSize = 5;
  String fillColorHex = "#000000";
  double fillOpacity = 1.0;
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;
}

class PointSymbolizer {
  PointStyle style = PointStyle();

  PointSymbolizer(xml.XmlElement xmlElement) {
    var graphicElem = _findSingleElement(xmlElement, GRAPHIC);
    if (graphicElem != null) {
      var sizeElem = _findSingleElement(graphicElem, SIZE);
      if (sizeElem != null) {
        style.markerSize = double.parse(sizeElem.text);
      }
      var markElem = _findSingleElement(graphicElem, MARK);
      if (markElem != null) {
        var wkNameElem = _findSingleElement(markElem, WELLKNOWNNAME);
        if (wkNameElem != null) {
          style.markerName = wkNameElem.text;
        }
        _getFill(markElem, style);
        _getStroke(markElem, style);
      }
    }
  }
}

/// Default polygon style class.
class PolygonStyle {
  String fillColorHex = "#000000";
  double fillOpacity = 1.0;
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;
}

class PolygonSymbolizer {
  PolygonStyle style = PolygonStyle();

  PolygonSymbolizer(xml.XmlElement xmlElement) {
    _getStroke(xmlElement, style);
    _getFill(xmlElement, style);
  }
}

/// Default line style class
class LineStyle {
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;
}

class LineSymbolizer {
  LineStyle style = LineStyle();

  LineSymbolizer(xml.XmlElement xmlElement) {
    _getStroke(xmlElement, style);
  }
}

class TextSymbolizer {
  String labelName = " - nv - ";
  String textColor = "#000000";
  double size = 12;
  double haloSize = 1.0;
  String haloColor = "#FFFFFF";

  TextSymbolizer(xml.XmlElement xmlElement) {
    var label = _findSingleElement(xmlElement, LABEL);
    if (label != null) {
      var labelNameElem = _findSingleElement(label, PROPERTY_NAME);
      if (labelNameElem != null) {
        labelName = labelNameElem.text;
      }
    }

    var font = _findSingleElement(xmlElement, FONT);
    if (font != null) {
      var paramters = _getParamters(font);
      for (var parameter in paramters) {
        var nameAttr = parameter.getAttribute(ATTRIBUTE_NAME);

        if (nameAttr != null &&
            StringUtilities.equalsIgnoreCase(nameAttr, ATTRIBUTE_FONT_SIZE)) {
          size = double.parse(parameter.text);
        }
      }
    }

    PolygonStyle dummyStyle = PolygonStyle();
    _getFill(xmlElement, dummyStyle);
    textColor = dummyStyle.fillColorHex;

    var halo = _findSingleElement(xmlElement, HALO);
    if (halo != null) {
      var radius = _findSingleElement(halo, RADIUS);
      if (radius != null) {
        haloSize = double.parse(radius.text);
      }

      PolygonStyle dummyStyle = PolygonStyle();
      _getFill(halo, dummyStyle);
      haloColor = dummyStyle.fillColorHex;
    }
  }
}

/// COMMON METHODS
///
void _getStroke(xml.XmlElement xmlElement, dynamic styleObject) {
  var strokes = xmlElement.findElements(STROKE, namespace: DEF_NSP);
  if (strokes.isNotEmpty) {
    var stroke = strokes.first;
    var parameters = _getParamters(stroke);
    if (parameters.isNotEmpty) {
      for (var parameter in parameters) {
        var attrName = parameter.getAttribute(ATTRIBUTE_NAME);

        if (StringUtilities.equalsIgnoreCase(attrName, ATTRIBUTE_STROKE)) {
          styleObject.strokeColorHex = parameter.text;
        } else if (StringUtilities.equalsIgnoreCase(
            attrName, ATTRIBUTE_STROKE_WIDTH)) {
          styleObject.strokeWidth = double.parse(parameter.text);
        } else if (StringUtilities.equalsIgnoreCase(
            attrName, ATTRIBUTE_STROKE_OPACITY)) {
          styleObject.strokeOpacity = double.parse(parameter.text);
        }
      }
    }
  }
}

Iterable<xml.XmlElement> _getParamters(xml.XmlElement element) {
  var parameters = element.findElements(CSS_PARAMETER, namespace: DEF_NSP);
  if (parameters.isEmpty) {
    parameters = element.findElements(SVG_PARAMETER, namespace: DEF_NSP);
  }
  return parameters;
}

xml.XmlElement _findSingleElement(xml.XmlElement element, String tag) {
  var label = element.findElements(tag, namespace: DEF_NSP);
  if (label.isNotEmpty) {
    return label.first;
  }
  return null;
}

void _getFill(xml.XmlElement xmlElement, dynamic styleObject) {
  var fill = _findSingleElement(xmlElement, FILL);
  if (fill != null) {
    var paramters = _getParamters(fill);
    for (var parameter in paramters) {
      var nameAttr = parameter.getAttribute(ATTRIBUTE_NAME);
      if (nameAttr != null &&
          StringUtilities.equalsIgnoreCase(nameAttr, ATTRIBUTE_FILL)) {
        styleObject.fillColorHex = parameter.text;
      } else if (nameAttr != null &&
          StringUtilities.equalsIgnoreCase(nameAttr, ATTRIBUTE_FILL_OPACITY)) {
        styleObject.fillOpacity = double.parse(parameter.text);
      }
    }
  }
}

class Filter {
  /// A filter attribute holding unique values.
  var uniqueValueKey;
  var uniqueValueValue;
}
