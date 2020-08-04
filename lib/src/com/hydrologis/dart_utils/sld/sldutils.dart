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

class WktMarkers {
  static const SQUARE = WktMarkers._("square");
  static const CIRCLE = WktMarkers._("circle");
  static const TRIANGLE = WktMarkers._("triangle");
  static const STAR = WktMarkers._("star");
  static const CROSS = WktMarkers._("cross");
  static const X = WktMarkers._("x");

  static List<WktMarkers> get values =>
      [SQUARE, CIRCLE, TRIANGLE, STAR, CROSS, X];

  final String name;

  const WktMarkers._(this.name);

  static WktMarkers forName(String wktName) {
    wktName = wktName.toLowerCase();
    for (var value in values) {
      if (wktName == value.name) {
        return value;
      }
    }
    throw ArgumentError("No marker available for name: $wktName");
  }
}

const STYLEDLAYERDESCRIPTOR = "StyledLayerDescriptor";
const USERLAYER = "UserLayer";
const USERSTYLE = "UserStyle";
const USERSTYLE_NAME = "Name";
const FEATURETYPESTYLE_NAME = "Name";
const FEATURETYPESTYLE = "FeatureTypeStyle";
const RULE = "Rule";
const RULE_NAME = "Name";

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
const SLD_NSP = 'sld';
const OGC_NSP = 'ogc';
const GML_NSP = 'gml';

const uri = 'http://www.opengis.net/sld';
const uriSld = 'http://www.opengis.net/sld';
const uriGml = 'http://www.opengis.net/gml';
const uriOgc = 'http://www.opengis.net/ogc';
const allNamespaces = {
  uriSld: SLD_NSP,
  uriOgc: OGC_NSP,
  uriGml: GML_NSP,
};

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

xml.XmlDocumentFragment makeTextStyleBuildFragment(TextStyle style) {
  xml.XmlBuilder builder = xml.XmlBuilder();
  builder.namespace(uriSld, SLD_NSP);
  builder.namespace(uriOgc, OGC_NSP);
  builder.element(TEXTSYMBOLIZER, namespace: uriSld, nest: () {
    // label
    builder.element(LABEL, namespace: uriSld, nest: () {
      builder.element(PROPERTY_NAME, namespace: uriOgc, nest: () {
        builder.text(style.labelName);
      });
    });

    // font
    builder.element(FONT, namespace: uriSld, nest: () {
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FONT_SIZE);
        builder.text(style.size);
      });
    });

    // color
    builder.element(FILL, namespace: uriSld, nest: () {
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL);
        builder.text(style.textColor);
      });
    });

    // halo
    builder.element(HALO, namespace: uriSld, nest: () {
      builder.element(RADIUS, namespace: uriSld, nest: () {
        builder.text(style.haloSize);
      });
      builder.element(FILL, namespace: uriSld, nest: () {
        builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
          builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL);
          builder.text(style.haloColor);
        });
      });
    });
  });
  var build = builder.buildFragment();
  return build;
}

xml.XmlDocumentFragment makePolygonStyleBuildFragment(PolygonStyle style) {
  xml.XmlBuilder builder = xml.XmlBuilder();
  builder.namespace(uriSld, SLD_NSP);

  builder.element(POLYGONSYMBOLIZER, namespace: uriSld, nest: () {
    // fill
    builder.element(FILL, namespace: uriSld, nest: () {
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL);
        builder.text(style.fillColorHex);
      });
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL_OPACITY);
        builder.text(style.fillOpacity);
      });
    });
    // stroke
    builder.element(STROKE, namespace: uriSld, nest: () {
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE);
        builder.text(style.strokeColorHex);
      });
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_OPACITY);
        builder.text(style.strokeOpacity);
      });
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_WIDTH);
        builder.text(style.strokeWidth);
      });
    });
  });
  var build = builder.buildFragment();
  return build;
}

xml.XmlDocumentFragment makeLineStyleBuildFragment(LineStyle style) {
  xml.XmlBuilder builder = xml.XmlBuilder();
  builder.namespace(uriSld, SLD_NSP);

  builder.element(LINESYMBOLIZER, namespace: uriSld, nest: () {
    builder.element(STROKE, namespace: uriSld, nest: () {
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE);
        builder.text(style.strokeColorHex);
      });
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_OPACITY);
        builder.text(style.strokeOpacity);
      });
      builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
        builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_WIDTH);
        builder.text(style.strokeWidth);
      });
    });
  });
  var build = builder.buildFragment();
  return build;
}

xml.XmlDocumentFragment makePointStyleBuildFragment(PointStyle style) {
  xml.XmlBuilder builder = xml.XmlBuilder();
  builder.namespace(uriSld, SLD_NSP);
  builder.element(POINTSYMBOLIZER, namespace: uriSld, nest: () {
    style.markerName ??= WktMarkers.CIRCLE.name;
    builder.element(GRAPHIC, namespace: uriSld, nest: () {
      // marker size
      builder.element(SIZE, namespace: uriSld, nest: () {
        builder.text(style.markerSize);
      });
      // marker
      builder.element(MARK, namespace: uriSld, nest: () {
        // shape
        builder.element(WELLKNOWNNAME, namespace: uriSld, nest: () {
          builder.text(style.markerName);
        });

        // fill
        builder.element(FILL, namespace: uriSld, nest: () {
          builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
            builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL);
            builder.text(style.fillColorHex);
          });
          builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
            builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_FILL_OPACITY);
            builder.text(style.fillOpacity);
          });
        });
        // stroke
        builder.element(STROKE, namespace: uriSld, nest: () {
          builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
            builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE);
            builder.text(style.strokeColorHex);
          });
          builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
            builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_OPACITY);
            builder.text(style.strokeOpacity);
          });
          builder.element(CSS_PARAMETER, namespace: uriSld, nest: () {
            builder.attribute(ATTRIBUTE_NAME, ATTRIBUTE_STROKE_WIDTH);
            builder.text(style.strokeWidth);
          });
        });
      });
    });
  });
  var build = builder.buildFragment();
  return build;
}

class Filter {
  /// A filter attribute holding unique values.
  var uniqueValueKey;
  var uniqueValueValue;
}

/// Default styles
class DefaultSlds {
  static String simplePointSld() {
    PointStyle ps = PointStyle();
    return SldObjectBuilder("simplepoint")
        .addFeatureTypeStyle("fts")
        .addRule("rule")
        .addPointSymbolizer(ps)
        .build();
  }

  static String simpleLineSld() {
    LineStyle ls = LineStyle();
    return SldObjectBuilder("simpleline")
        .addFeatureTypeStyle("fts")
        .addRule("rule")
        .addLineSymbolizer(ls)
        .build();
  }

  static String simplePolygonSld() {
    PolygonStyle ps = PolygonStyle();
    return SldObjectBuilder("simplepolygon")
        .addFeatureTypeStyle("fts")
        .addRule("rule")
        .addPolygonSymbolizer(ps)
        .build();
  }
}
