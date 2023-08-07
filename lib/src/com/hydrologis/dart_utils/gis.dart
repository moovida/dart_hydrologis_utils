part of dart_hydrologis_utils;

//  Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
//  Use of this source code is governed by a BSD 3 license that can be
//  found in the LICENSE file.

/// A simple feature containing a geometry and a set of attributes,
/// marked by an unique id.
class Feature {
  Geometry? geometry;

  int? fid;

  Map<String, dynamic> attributes = {};

  @override
  String toString() {
    String attr = "";
    attributes.forEach((k, v) {
      attr += "\n\t--> $k: ${v.toString()}";
    });

    return "fid: $fid:\n\tgeom: ${geometry.toString()},\n\tattributes:$attr";
  }
}

/// A collection of features.
class FeatureCollection {
  /// The list of features
  List<Feature> features = [];

  /// This can optionally be used to identify record sources
  /// in case of mixed data sources (ex. merging together
  /// QueryResults from different queries.
  List<String>? ids;

  String? geomName;
}

/// Class representing a geometry_columns record.
class GeometryColumn {
  // VARIABLES
  late String tableName;
  late String geometryColumnName;

  /// The type, as compatible with [EGeometryType].
  late EGeometryType geometryType;
  late int coordinatesDimension;
  late int srid;
  late int isSpatialIndexEnabled;
}

class GeometryUtilities {
  /// Create a polygon of the supplied [env].
  ///
  /// In case of [makeCircle] set to true, a buffer of half the width
  /// of the [env] is created in the center point.
  static Geometry fromEnvelope(Envelope env, {bool makeCircle = false}) {
    double w = env.getMinX();
    double e = env.getMaxX();
    double s = env.getMinY();
    double n = env.getMaxY();

    if (makeCircle) {
      var centre = env.centre();
      var point = GeometryFactory.defaultPrecision().createPoint(centre);
      var buffer = point.buffer(env.getWidth() / 2.0);
      return buffer;
    }
    return GeometryFactory.defaultPrecision().createPolygonFromCoords([
      Coordinate(w, s),
      Coordinate(w, n),
      Coordinate(e, n),
      Coordinate(e, s),
      Coordinate(w, s),
    ]);
  }
}
