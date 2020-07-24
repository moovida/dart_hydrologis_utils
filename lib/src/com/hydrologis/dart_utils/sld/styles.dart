part of dart_hydrologis_utils;

/// Default point style class.
class PointStyle {
  String markerName = "Circle";
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
      other is PointStyle &&
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
      other is PointStyle &&
      other.fillColorHex == fillColorHex &&
      other.fillOpacity == fillOpacity &&
      other.strokeColorHex == strokeColorHex &&
      other.strokeWidth == strokeWidth &&
      other.strokeOpacity == strokeOpacity;

  @override
  int get hashCode => HashUtilities.hashObjects(
      [fillColorHex, fillOpacity, strokeColorHex, strokeWidth, strokeOpacity]);
}
