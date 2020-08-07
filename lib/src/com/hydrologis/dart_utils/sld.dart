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

  /// Apply the passed [ftsAndRuleFunction] to each rule found.
  ///
  /// The function will have [FeatureTypeStyle] and [Rule] as parameters.
  void applyForEachRule(Function ftsAndRuleFunction) {
    featureTypeStyles.forEach((fts) {
      fts.rules.forEach((rule) {
        ftsAndRuleFunction(fts, rule);
      });
    });
  }

  /// Return the complete ordered list of rules, divided by [FeatureTypeStyle].
  List<List<Rule>> getAllRules() {
    List<List<Rule>> allRules = [];
    featureTypeStyles.forEach((fts) {
      allRules.add(fts.rules);
    });
    return allRules;
  }

  /// Get the first available [TextStyle].
  ///
  /// If [addIfNotExists] is true, then a new style is added to the first rule.
  TextStyle getFirstTextStyle(bool addIfNotExists) {
    var allRules = getAllRules();
    var firstRule;
    var hasOne = false;
    for (var rules in allRules) {
      for (var rule in rules) {
        firstRule ??= rule;
        hasOne = true;
        if (rule.textSymbolizers.isNotEmpty) {
          return rule.textSymbolizers[0].style;
        }
      }
    }
    if (addIfNotExists && hasOne) {
      var textStyle = TextStyle();
      firstRule.addTextStyle(textStyle);
      return textStyle;
    } else {
      return null;
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

  /// Add a new FTS with given [ftsName].
  SldObjectBuilder addFeatureTypeStyle(String ftsName) {
    _commitRule();
    _commitFeatureTypeStyle();
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

  void _commitFeatureTypeStyle() {
    if (currentFeatureTypeStyleBuild != null) {
      // add it to document
      userStyleNode.children.add(currentFeatureTypeStyleBuild);
      currentFeatureTypeStyleBuild = null;
      currentRuleBuild = null;
    }
  }

  /// Add a new Rule using the [ruleName].
  SldObjectBuilder addRule(String ruleName) {
    _commitRule();
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

  void _commitRule() {
    if (currentRuleBuild != null) {
      // add it to fts
      currentFeatureTypeStyleBuild.firstElementChild.children
          .add(currentRuleBuild);
      currentRuleBuild = null;
    }
  }

  /// Add a new point symbolizer using the [style] object.
  SldObjectBuilder addPointSymbolizer(PointStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makePointStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  /// Add a new line symbolizer using the [style] object.
  SldObjectBuilder addLineSymbolizer(LineStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makeLineStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  /// Add a new polygon symbolizer using the [style] object.
  SldObjectBuilder addPolygonSymbolizer(PolygonStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makePolygonStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  /// Add a new text symbolizer using the [style] object.
  SldObjectBuilder addTextSymbolizer(TextStyle style) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makeTextStyleBuildFragment(style);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  /// Add a filter to the rule.
  SldObjectBuilder addFilter(Filter filter) {
    if (currentRuleBuild != null) {
      xml.XmlDocumentFragment build = makeFilterBuildFragment(filter);
      currentRuleBuild.firstElementChild.children.add(build);
    }
    return this;
  }

  /// Build the SLD string from the current object.
  String build() {
    _commitRule();
    _commitFeatureTypeStyle();
    var xmlString = document.toXmlString(pretty: true, indent: "  ");
    return xmlString;
  }

  /// Build a SLD String from an existing tree starting from a list of [featureTypeStyles].
  static String buildFromFeatureTypeStyles(
      List<FeatureTypeStyle> featureTypeStyles) {
    var builder = SldObjectBuilder("style");
    featureTypeStyles.forEach((fts) {
      builder.addFeatureTypeStyle(fts.name);
      fts.rules.forEach((rule) {
        builder.addRule(rule.name);

        if (rule.filter != null) {
          builder.addFilter(rule.filter);
        }
        rule.pointSymbolizers.forEach((ps) {
          builder.addPointSymbolizer(ps.style);
        });
        rule.lineSymbolizers.forEach((ls) {
          builder.addLineSymbolizer(ls.style);
        });
        rule.polygonSymbolizers.forEach((ps) {
          builder.addPolygonSymbolizer(ps.style);
        });
        rule.textSymbolizers.forEach((ts) {
          builder.addTextSymbolizer(ts.style);
        });
      });
    });
    String sldString = builder.build();
    return sldString;
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
