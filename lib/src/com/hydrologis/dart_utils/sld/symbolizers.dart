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
          try {
            style.markerName = WktMarkers.forName(wkNameElem.text).name;
          } catch (e) {
            // assume it is a custom marked, the endsystem will take care of
            style.markerName = wkNameElem.text;
          }
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
  TextStyle style = TextStyle();

  TextSymbolizer(xml.XmlElement xmlElement) {
    var label = _findSingleElement(xmlElement, LABEL);
    if (label != null) {
      var labelNameElem = _findSingleElement(label, PROPERTY_NAME);
      if (labelNameElem != null) {
        style.labelName = labelNameElem.text;
      }
    }

    var font = _findSingleElement(xmlElement, FONT);
    if (font != null) {
      var paramters = _getParamters(font);
      for (var parameter in paramters) {
        var nameAttr = parameter.getAttribute(ATTRIBUTE_NAME);

        if (nameAttr != null &&
            StringUtilities.equalsIgnoreCase(nameAttr, ATTRIBUTE_FONT_SIZE)) {
          style.size = double.parse(parameter.text);
        }
      }
    }

    PolygonStyle dummyStyle = PolygonStyle();
    _getFill(xmlElement, dummyStyle);
    style.textColor = dummyStyle.fillColorHex;

    var halo = _findSingleElement(xmlElement, HALO);
    if (halo != null) {
      var radius = _findSingleElement(halo, RADIUS);
      if (radius != null) {
        style.haloSize = double.parse(radius.text);
      }

      PolygonStyle dummyStyle = PolygonStyle();
      _getFill(halo, dummyStyle);
      style.haloColor = dummyStyle.fillColorHex;
    }
  }
}
