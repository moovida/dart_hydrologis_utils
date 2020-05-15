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
const CSS_PARAMETER = "CssParameter";
const SVG_PARAMETER = "SvgParameter";

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
  }
}

class LineSymbolizer {
  String colorHex = "#FF0000";
  double width = 1.0;

  LineSymbolizer(xml.XmlElement xmlElement) {
    var strokes = xmlElement.findElements(STROKE, namespace: DEF_NSP);
    if (strokes.isNotEmpty) {
      var stroke = strokes.first;
      var parameters = stroke.findElements(CSS_PARAMETER, namespace: DEF_NSP);
      if (parameters.isEmpty) {
        parameters = stroke.findElements(SVG_PARAMETER, namespace: DEF_NSP);
      }
      if (parameters.isNotEmpty) {
        for (var parameter in parameters) {
          var attrName = parameter.getAttribute("name");
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

class TextSymbolizer {}
