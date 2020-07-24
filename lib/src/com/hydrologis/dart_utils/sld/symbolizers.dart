part of dart_hydrologis_utils;

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

class PolygonSymbolizer {
  PolygonStyle style = PolygonStyle();

  PolygonSymbolizer(xml.XmlElement xmlElement) {
    _getStroke(xmlElement, style);
    _getFill(xmlElement, style);
  }
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
