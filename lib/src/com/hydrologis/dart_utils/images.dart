part of dart_hydrologis_utils;
/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a BSD 3 license that can be
 * found in the LICENSE file.
 */

/// Image utilities
class ImageUtilities {
  static img.Image imageFromBytes(List<int> bytes) {
    img.Image image = img.decodeImage(bytes);
    return image;
  }

//  static void imageBytes2File(File file, List<int> bytes) {
//    IMG.Image img = imageFromBytes(bytes);
//
//    IMG.writeJpg(img)
//
//  }

  static List<int> bytesFromImageFile(String path) {
    File imgFile = File(path);
    return imgFile.readAsBytesSync();
  }

  static List<int> resizeImage(Uint8List bytes,
      {int newWidth = 100, int longestSizeTo}) {
    img.Image image = img.decodeImage(bytes);

    img.Image thumbnail;
    if (longestSizeTo != null) {
      if (image.width > image.height) {
        thumbnail = img.copyResize(
          image,
          width: longestSizeTo,
        );
      } else {
        thumbnail = img.copyResize(
          image,
          height: longestSizeTo,
        );
      }
    } else {
      thumbnail = img.copyResize(
        image,
        width: newWidth,
      );
    }
    var encodeJpg = img.encodeJpg(thumbnail);
    return encodeJpg;
  }
}
