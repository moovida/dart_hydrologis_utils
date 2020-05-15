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

const LINESYMBOLIZER = "LineSymbolizer";
const TEXTSYMBOLIZER = "TextSymbolizer";

const STROKE = "Stroke";
const FILL = "Fill";
const LABEL = "Label";
const FONT = "Font";
const HALO = "Halo";
const RADIUS = "Radius";
const CSS_PARAMETER = "CssParameter";
const SVG_PARAMETER = "SvgParameter";
const PROPERTY_NAME = "PropertyName";

const NAME_ATTRIBUTE = "name";

const DEF_NSP = '*';

class SldObject {
  List<Rule> rules = [];

  xml.XmlDocument document;

  SldObject(this.document);

  SldObject.fromString(String xmlString) : this(xml.parse(xmlString.trim()));

  SldObject.fromFile(File xmlFile)
      : this.fromString(FileUtilities.readFile(xmlFile.path));

  void parse() {
    var root = document.findElements(STYLEDLAYERDESCRIPTOR, namespace: DEF_NSP);
    if (root == null || root.isEmpty) {
      throw ArgumentError("The file doesn't seem to be an SLD file.");
    } else {
      var featureTypeStyleList =
          document.findAllElements(FEATURETYPESTYLE, namespace: DEF_NSP);
      // we read just the first
      if (featureTypeStyleList.isNotEmpty) {
        var featureTypeStyle = featureTypeStyleList.toList()[0];
        var allRules =
            featureTypeStyle.findAllElements(RULE, namespace: DEF_NSP);
        if (allRules.length == 1) {
          Rule rule = Rule(allRules.first);
          rules.add(rule);
        } else if (allRules.length > 1) {
          // thematic?
          var filterElements =
              allRules.first.findElements(FILTER, namespace: DEF_NSP);
        }
      }
    }
  }
}

class Rule {
  List<LineSymbolizer> lineSymbolizers = [];
  List<TextSymbolizer> textSymbolizers = [];

  Rule(xml.XmlElement xmlElement) {
    var lineSymbolizersList =
        xmlElement.findElements(LINESYMBOLIZER, namespace: DEF_NSP);
    for (var lineSymbolizer in lineSymbolizersList) {
      LineSymbolizer ls = LineSymbolizer(lineSymbolizer);
      lineSymbolizers.add(ls);
    }
    var textSymbolizersList =
        xmlElement.findElements(TEXTSYMBOLIZER, namespace: DEF_NSP);
    for (var textSymbolizer in textSymbolizersList) {
      TextSymbolizer ts = TextSymbolizer(textSymbolizer);
      textSymbolizers.add(ts);
    }
  }
}

class LineSymbolizer {
  String colorHex = "#FF0000";
  double width = 1.0;

  LineSymbolizer(xml.XmlElement xmlElement) {
    var strokes = xmlElement.findElements(STROKE, namespace: DEF_NSP);
    if (strokes.isNotEmpty) {
      var stroke = strokes.first;
      var parameters = _getParamters(stroke);
      if (parameters.isNotEmpty) {
        for (var parameter in parameters) {
          var attrName = parameter.getAttribute(NAME_ATTRIBUTE);
          if (StringUtilities.equalsIgnoreCase(attrName, "stroke")) {
            colorHex = parameter.text;
          } else if (StringUtilities.equalsIgnoreCase(
              attrName, "stroke-width")) {
            width = double.parse(parameter.text);
          }
        }
      }
    }
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
        var nameAttr = parameter.getAttribute(NAME_ATTRIBUTE);
        if (nameAttr != null &&
            StringUtilities.equalsIgnoreCase(nameAttr, "font-size")) {
          size = double.parse(parameter.text);
        }
      }
    }

    textColor = _getFill(xmlElement);

    var halo = _findSingleElement(xmlElement, HALO);
    if (halo != null) {
      var radius = _findSingleElement(halo, RADIUS);
      if (radius != null) {
        haloSize = double.parse(radius.text);
      }

      haloColor = _getFill(halo);
    }
  }
}

/// COMMON METHODS
///

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

String _getFill(xml.XmlElement xmlElement) {
  var fill = _findSingleElement(xmlElement, FILL);
  if (fill != null) {
    var paramters = _getParamters(fill);
    for (var parameter in paramters) {
      var nameAttr = parameter.getAttribute(NAME_ATTRIBUTE);
      if (nameAttr != null &&
          StringUtilities.equalsIgnoreCase(nameAttr, "fill")) {
        return parameter.text;
      }
    }
  }
  return null;
}
