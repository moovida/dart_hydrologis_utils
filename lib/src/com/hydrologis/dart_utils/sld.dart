part of dart_hydrologis_utils;

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

/// An SLD string builder.
class SldObjectBuilder {
  xml.XmlDocument document;
  var userStyleNode;
  var currentFeatureTypeStyleBuild;
  var currentRuleBuild;
  SldObjectBuilder(String name) {
    var builder = xml.XmlBuilder();
    builder.declaration(version: "1.0", encoding: 'UTF-8');

    builder.element(STYLEDLAYERDESCRIPTOR, namespaces: allNamespaces, nest: () {
      builder.attribute("xmlns", uri);
      builder.attribute("version", "1.0.0");
      builder.element(USERLAYER, namespace: uriSld, nest: () {
        builder.element(USERSTYLE, namespace: uriSld, nest: () {
          builder.element(USERSTYLE_NAME, namespace: uriSld, nest: () {
            builder.text(name);
          });
        });
      });
    });

    document = builder.buildDocument();
    document.children.forEach((childNode) {
      if (childNode is xml.XmlElement) {
        var userStyleNodeList =
            childNode.findAllElements(USERSTYLE, namespace: DEF_NSP);
        if (userStyleNodeList.isNotEmpty) {
          userStyleNode = userStyleNodeList.first;
        }
      }
    });
  }

  SldObjectBuilder addFeatureTypeStyle(String ftsName) {
    commitFeatureTypeStyle();
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.namespace(uriSld, SLD_NSP);
    builder.element(FEATURETYPESTYLE, namespace: uriSld, nest: () {
      builder.element(USERSTYLE_NAME, namespace: uriSld, nest: () {
        builder.text(ftsName);
      });
    });
    var build = builder.buildFragment();
    currentFeatureTypeStyleBuild = build;
    return this;
  }

  void commitFeatureTypeStyle() {
    if (currentFeatureTypeStyleBuild != null) {
      // add it to document
      userStyleNode.children.add(currentFeatureTypeStyleBuild);
      currentFeatureTypeStyleBuild = null;
      currentRuleBuild = null;
    }
  }

  SldObjectBuilder addRule(String ruleName) {
    commitRule();
    if (currentFeatureTypeStyleBuild != null) {
      xml.XmlBuilder builder = xml.XmlBuilder();
      builder.namespace(uriSld, SLD_NSP);
      builder.element(RULE, namespace: uriSld, nest: () {
        builder.element(USERSTYLE_NAME, namespace: uriSld, nest: () {
          builder.text(ruleName);
        });
      });
      var build = builder.buildFragment();
      currentRuleBuild = build;
    }
    return this;
  }

  void commitRule() {
    if (currentRuleBuild != null) {
      // add it to fts
      currentFeatureTypeStyleBuild.firstElementChild.children
          .add(currentRuleBuild);
      currentRuleBuild = null;
    }
  }

  SldObjectBuilder addPointSymbolizer(PointStyle style) {
    if (currentRuleBuild != null) {
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
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  SldObjectBuilder addLineSymbolizer(LineStyle style) {
    if (currentRuleBuild != null) {
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
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  SldObjectBuilder addTextSymbolizer(TextStyle style) {
    if (currentRuleBuild != null) {
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
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  String build() {
    commitRule();
    commitFeatureTypeStyle();
    var xmlString = document.toXmlString(pretty: true, indent: "  ");
    return xmlString;
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
