part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2023. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */

class TrendLine {
  List<dynamic> xyList;
  late double _slope;
  late double _yIntercept;

  TrendLine(this.xyList) {
    var a = 0.0;
    var b1 = 0.0;
    var b2 = 0.0;
    var c = 0.0;

    for (var i = 0; i < xyList.length; i++) {
      var x = xyList[i][0];
      var y = xyList[i][1];
      a = a + x * y;
      b1 += x;
      b2 += y;

      c += pow(x, 2);
    }
    a = 3 * a;
    var b = b1 * b2;
    c = 3 * c;
    var d = pow(b1, 2);

    _slope = (a - b) / (c - d);

    var e = b2;
    var f = _slope * b1;

    _yIntercept = (e - f) / xyList.length;
  }

  double get slope => _slope;

  double get yIntercept => _yIntercept;

  double getY(double x) {
    return _slope * x + _yIntercept;
  }
}

/// Applies a sliding average on linear geometries for smoothing.
///
/// <p>
/// See: http://grass.osgeo.org/wiki/V.generalize_tutorial
/// </p>
///
/// @author Andrea Antonello (www.hydrologis.com)
///
class FeatureSlidingAverage {
  final List<dynamic> xyList;

  FeatureSlidingAverage(this.xyList);

  List<dynamic>? smooth(int lookAhead, double slide) {
    double sc;
    List<dynamic> res = [];

    int n = xyList.length; // Points->n_points;
    int half = lookAhead ~/ 2;

    for (int j = 0; j < n; j++) {
      List<double> tmp = List.filled(2, 0.0);
      res.add(tmp);
    }

    if (lookAhead % 2 == 0) {
      throw ArgumentError(
          "Look ahead parameter must be odd, but you supplied: $lookAhead");
    }

    if (lookAhead >= n || lookAhead == 1) {
      return null;
    }

    sc = 1.0 / lookAhead;

    List<double> pCoord = List.filled(2, 0.0);
    List<double> sCoord = List.filled(2, 0.0);
    pointAssign(xyList, 0, pCoord);
    for (int i = 1; i < lookAhead; i++) {
      List<double> tmpCoord = List.filled(2, 0.0);
      pointAssign(xyList, i, tmpCoord);
      pointAdd(pCoord, tmpCoord, pCoord);
    }

    /* and calculate the average of remaining points */
    for (int i = half; i + half < n; i++) {
      List<double> tmpCoord = List.filled(2, 0.0);
      pointAssign(xyList, i, sCoord);
      pointScalar(sCoord, 1.0 - slide, sCoord);
      pointScalar(pCoord, sc * slide, tmpCoord);
      pointAdd(tmpCoord, sCoord, res[i]);
      if (i + half + 1 < n) {
        pointAssign(xyList, i - half, tmpCoord);
        pointSubtract(pCoord, tmpCoord, pCoord);
        pointAssign(xyList, i + half + 1, tmpCoord);
        pointAdd(pCoord, tmpCoord, pCoord);
      }
    }

    for (int i = 0; i < half; i++) {
      res[i][0] = xyList[i][0];
      res[i][1] = xyList[i][1];
    }
    for (int i = n - half - 1; i < n; i++) {
      res[i][0] = xyList[i][0];
      res[i][1] = xyList[i][1];
    }
    // for( Coordinate coordinate : res ) {
    //     if (coordinate.x == 0) {
    //         System.out.println();
    //     }
    // }
    // for( i = half; i + half < n; i++ ) {
    // coordinates[i].x = res.get(i).x;
    // coordinates[i].y = res.get(i).y;
    // coordinates[i].z = res.get(i).z;
    // }

    // return Points->n_points;

    return res;
  }

  void pointAssign(List<dynamic> coordinates, int index,
      List<double> newAssignedCoordinate) {
    dynamic coordinate = coordinates[index];
    newAssignedCoordinate[0] = coordinate[0];
    newAssignedCoordinate[1] = coordinate[1];
  }

  void pointAdd(List<double> a, List<double> b, List<double> res) {
    res[0] = a[0] + b[0];
    res[1] = a[1] + b[1];
  }

  void pointSubtract(List<double> a, List<double> b, List<double> res) {
    res[0] = a[0] - b[0];
    res[1] = a[1] - b[1];
  }

  void pointScalar(List<double> a, double k, List<double> res) {
    res[0] = a[0] * k;
    res[1] = a[1] * k;
  }
}
