part of dart_hydrologis_utils;

/// Default point style class.
class PointStyle {
  String markerName = WktMarkers.CIRCLE.name;
  double markerSize = 5;
  String fillColorHex = "#000000";
  double fillOpacity = 1.0;
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;

  @override
  bool operator ==(Object other) =>
      other is PointStyle &&
      other.markerName == markerName &&
      other.markerSize == markerSize &&
      other.fillColorHex == fillColorHex &&
      other.fillOpacity == fillOpacity &&
      other.strokeColorHex == strokeColorHex &&
      other.strokeWidth == strokeWidth &&
      other.strokeOpacity == strokeOpacity;

  @override
  int get hashCode => HashUtilities.hashObjects([
        markerName,
        markerSize,
        fillColorHex,
        fillOpacity,
        strokeColorHex,
        strokeWidth,
        strokeOpacity
      ]);
}

/// Default line style class
class LineStyle {
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;

  @override
  bool operator ==(Object other) =>
      other is LineStyle &&
      other.strokeColorHex == strokeColorHex &&
      other.strokeWidth == strokeWidth &&
      other.strokeOpacity == strokeOpacity;

  @override
  int get hashCode =>
      HashUtilities.hashObjects([strokeColorHex, strokeWidth, strokeOpacity]);
}

/// Default polygon style class.
class PolygonStyle {
  String fillColorHex = "#000000";
  double fillOpacity = 1.0;
  String strokeColorHex = "#000000";
  double strokeWidth = 1.0;
  double strokeOpacity = 1.0;

  @override
  bool operator ==(Object other) =>
      other is PolygonStyle &&
      other.fillColorHex == fillColorHex &&
      other.fillOpacity == fillOpacity &&
      other.strokeColorHex == strokeColorHex &&
      other.strokeWidth == strokeWidth &&
      other.strokeOpacity == strokeOpacity;

  @override
  int get hashCode => HashUtilities.hashObjects(
      [fillColorHex, fillOpacity, strokeColorHex, strokeWidth, strokeOpacity]);
}

/// Default text style class.
class TextStyle {
  String labelName = "";
  String textColor = "#000000";
  double size = 12;
  double haloSize = 1.0;
  String haloColor = "#FFFFFF";

  @override
  bool operator ==(Object other) =>
      other is TextStyle &&
      other.labelName == labelName &&
      other.textColor == textColor &&
      other.size == size &&
      other.haloSize == haloSize &&
      other.haloColor == haloColor;

  @override
  int get hashCode => HashUtilities.hashObjects(
      [labelName, textColor, size, haloSize, haloColor]);
}
