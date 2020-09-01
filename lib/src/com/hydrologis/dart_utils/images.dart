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

  /// Makes pixels of the image [bytes] transparent if color is defined as [r], [g], [b].
  ///
  /// The resulting bytes are encoded as pn.
  static Uint8List colorToAlpha(Uint8List bytes, int r, int g, int b) {
    final image = img.decodeImage(bytes);
    colorToAlphaImg(image, r, g, b);

    return img.encodePng(image);
  }

  /// Makes pixels of the [image] transparent if color is defined as [r], [g], [b].
  ///
  /// returns an image, yet to be encoded.
  static void colorToAlphaImg(img.Image image, int r, int g, int b) {
    var pixels = image.getBytes(format: img.Format.rgba);
    final length = pixels.lengthInBytes;
    for (var i = 0; i < length; i = i + 4) {
      if (pixels[i] == r && pixels[i + 1] == g && pixels[i + 2] == b) {
        pixels[i + 3] = 0;
      }
    }
    // set the fact that it now has an alpha channel, else it will not work if prior rgb
    image.channels = img.Channels.rgba;
  }
}
