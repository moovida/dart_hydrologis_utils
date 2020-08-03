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
      int index = 0;
      for (var featureTypeStyle in featureTypeStyleList) {
        FeatureTypeStyle fts = FeatureTypeStyle(index++, featureTypeStyle);
        featureTypeStyles.add(fts);
      }
    }
  }

  String toSldString() {
    var xmlString = document.toXmlString(pretty: true, indent: "  ");
    return xmlString;
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
    commitRule();
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
      xml.XmlDocumentFragment build = makePointStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  SldObjectBuilder addLineSymbolizer(LineStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makeLineStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  SldObjectBuilder addPolygonSymbolizer(PolygonStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makePolygonStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  SldObjectBuilder addTextSymbolizer(TextStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makeTextStyleBuildFragment(style);
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
  String name;
  final int index;

  FeatureTypeStyle(this.index, xml.XmlElement xmlElement) {
    var ftsName = _findSingleElement(xmlElement, FEATURETYPESTYLE_NAME);
    name = ftsName?.innerText ??= "FTS $index";
    var allRules = xmlElement.findAllElements(RULE, namespace: DEF_NSP);
    int rIndex = 0;
    for (var r in allRules) {
      Rule rule = Rule(rIndex++, r);
      rules.add(rule);
    }
  }
}

class Rule {
  xml.XmlElement ruleXmlElement;
  List<PointSymbolizer> pointSymbolizers = [];
  List<LineSymbolizer> lineSymbolizers = [];
  List<PolygonSymbolizer> polygonSymbolizers = [];
  List<TextSymbolizer> textSymbolizers = [];
  Filter filter;
  String name;
  final int index;

  Rule(this.index, this.ruleXmlElement) {
    var ruleName = _findSingleElement(ruleXmlElement, RULE_NAME);
    name = ruleName?.innerText ??= "Rule $index";
    var pointSymbolizersList =
        ruleXmlElement.findElements(POINTSYMBOLIZER, namespace: DEF_NSP);
    for (var pointSymbolizer in pointSymbolizersList) {
      PointSymbolizer ps = PointSymbolizer(pointSymbolizer);
      pointSymbolizers.add(ps);
    }
    var lineSymbolizersList =
        ruleXmlElement.findElements(LINESYMBOLIZER, namespace: DEF_NSP);
    for (var lineSymbolizer in lineSymbolizersList) {
      LineSymbolizer ls = LineSymbolizer(lineSymbolizer);
      lineSymbolizers.add(ls);
    }
    var polygonSymbolizersList =
        ruleXmlElement.findElements(POLYGONSYMBOLIZER, namespace: DEF_NSP);
    for (var polygonSymbolizer in polygonSymbolizersList) {
      PolygonSymbolizer ls = PolygonSymbolizer(polygonSymbolizer);
      polygonSymbolizers.add(ls);
    }
    var textSymbolizersList =
        ruleXmlElement.findElements(TEXTSYMBOLIZER, namespace: DEF_NSP);
    for (var textSymbolizer in textSymbolizersList) {
      TextSymbolizer ts = TextSymbolizer(textSymbolizer);
      textSymbolizers.add(ts);
    }

    // find filters
    var filtersList = ruleXmlElement.findElements(FILTER, namespace: DEF_NSP);
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

  /// Add a text[style] as symbolizer to the rule xml element.
  void addTextStyle(TextStyle style) {
    var textFragment = makeTextStyleBuildFragment(style);
    ruleXmlElement.children.add(textFragment);
    var tSym = TextSymbolizer(textFragment.children.first);
    textSymbolizers.add(tSym);
  }

  /// Remove a text symbolizer from the rule xml element.
  ///
  /// The remove, the [style] is used. The first equal to the style is removed.
  void removeTextStyle(TextStyle style) {
    bool removed = false;
    ruleXmlElement.children.removeWhere((element) {
      if (removed) {
        return false;
      }
      if (element.outerXml
          .toUpperCase()
          .contains(TEXTSYMBOLIZER.toUpperCase())) {
        var tmpSymbolizer = TextSymbolizer(element);
        if (style == tmpSymbolizer.style) {
          removed = true;
          bool removedSym = false;
          textSymbolizers.removeWhere((element) {
            if (removedSym) {
              return false;
            }
            removedSym = element.style == tmpSymbolizer.style;
            return removedSym;
          });
          return true;
        }
      }
      return false;
    });
  }

  /// Add a polygon[style] as symbolizer to the rule xml element.
  void addPolygonStyle(PolygonStyle style) {
    var polygonFragment = makePolygonStyleBuildFragment(style);
    ruleXmlElement.children.add(polygonFragment);
    var pSym = PolygonSymbolizer(polygonFragment.children.first);
    polygonSymbolizers.add(pSym);
  }

  /// Remove a polygon symbolizer from the rule xml element.
  ///
  /// The remove, the [style] is used. The first equal to the style is removed.
  void removePolygonStyle(PolygonStyle style) {
    bool removed = false;
    ruleXmlElement.children.removeWhere((element) {
      if (removed) {
        return false;
      }
      if (element.outerXml
          .toUpperCase()
          .contains(POLYGONSYMBOLIZER.toUpperCase())) {
        var tmpSymbolizer = PolygonSymbolizer(element);
        if (style == tmpSymbolizer.style) {
          removed = true;
          bool removedSym = false;
          polygonSymbolizers.removeWhere((element) {
            if (removedSym) {
              return false;
            }
            removedSym = element.style == tmpSymbolizer.style;
            return removedSym;
          });
          return true;
        }
      }
      return false;
    });
  }

  /// Add a line[style] as symbolizer to the rule xml element.
  void addLineStyle(LineStyle style) {
    var lineFragment = makeLineStyleBuildFragment(style);
    ruleXmlElement.children.add(lineFragment);
    var lSym = LineSymbolizer(lineFragment.children.first);
    lineSymbolizers.add(lSym);
  }

  /// Remove a line symbolizer from the rule xml element.
  ///
  /// The remove, the [style] is used. The first equal to the style is removed.
  void removeLineStyle(LineStyle style) {
    bool removed = false;
    ruleXmlElement.children.removeWhere((element) {
      if (removed) {
        return false;
      }
      if (element.outerXml
          .toUpperCase()
          .contains(LINESYMBOLIZER.toUpperCase())) {
        var tmpSymbolizer = LineSymbolizer(element);
        if (style == tmpSymbolizer.style) {
          removed = true;
          bool removedSym = false;
          lineSymbolizers.removeWhere((element) {
            if (removedSym) {
              return false;
            }
            removedSym = element.style == tmpSymbolizer.style;
            return removedSym;
          });
          return true;
        }
      }
      return false;
    });
  }

  /// Add a point[style] as symbolizer to the rule xml element.
  void addPointStyle(PointStyle style) {
    var pointFragment = makePointStyleBuildFragment(style);
    ruleXmlElement.children.add(pointFragment);
    var pSym = PointSymbolizer(pointFragment.children.first);
    pointSymbolizers.add(pSym);
  }

  /// Remove a point symbolizer from the rule xml element.
  ///
  /// The remove, the [style] is used. The first equal to the style is removed.
  void removePointStyle(PointStyle style) {
    bool removed = false;
    ruleXmlElement.children.removeWhere((element) {
      if (removed) {
        return false;
      }
      if (element.outerXml
          .toUpperCase()
          .contains(POINTSYMBOLIZER.toUpperCase())) {
        var tmpSymbolizer = PointSymbolizer(element);
        if (style == tmpSymbolizer.style) {
          removed = true;
          bool removedSym = false;
          pointSymbolizers.removeWhere((element) {
            if (removedSym) {
              return false;
            }
            removedSym = element.style == tmpSymbolizer.style;
            return removedSym;
          });

          return true;
        }
      }
      return false;
    });
  }
}
