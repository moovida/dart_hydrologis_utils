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

  /// Removes the given color as solid background from the image.
  static void colorToAlphaBlend(
      img.Image image, int redToHide, int greenToHide, int blueToHide) {
    Uint8List pixels = image.getBytes(format: img.Format.rgba);
    final length = pixels.lengthInBytes;
    for (var i = 0; i < length; i = i + 4) {
      c2a(pixels, i, redToHide, greenToHide, blueToHide);
    }
    // set the fact that it now has an alpha channel, else it will not work if prior rgb
    image.channels = img.Channels.rgba;
  }

  static void c2a(Uint8List pixels, int index, int redToHide, int greenToHide,
      int blueToHide) {
    int red = pixels[index];
    int green = pixels[index + 1];
    int blue = pixels[index + 2];
    double alpha = pixels[index + 3].toDouble();

    double a4 = alpha;

    double a1 = 0.0;
    if (red > redToHide) {
      a1 = (red - redToHide) / (255.0 - redToHide);
    } else if (red < redToHide) {
      a1 = (redToHide - red) / (redToHide);
    }
    double a2 = 0.0;
    if (green > greenToHide) {
      a2 = (green - greenToHide) / (255.0 - greenToHide);
    } else if (green < greenToHide) {
      a2 = (greenToHide - green) / (greenToHide);
    }
    double a3 = 0.0;
    if (blue > blueToHide) {
      a3 = (blue - blueToHide) / (255.0 - blueToHide);
    } else if (blue < blueToHide) {
      a3 = (blueToHide - blue) / (blueToHide);
    }

    if (a1 > a2) {
      if (a1 > a3) {
        alpha = a1;
      } else {
        alpha = a3;
      }
    } else {
      if (a2 > a3) {
        alpha = a2;
      } else {
        alpha = a3;
      }
    }

    alpha *= 255.0;

    if (alpha >= 1.0) {
      red = (255.0 * (red - redToHide) / alpha + redToHide).toInt();
      green = (255.0 * (green - greenToHide) / alpha + greenToHide).toInt();
      blue = (255.0 * (blue - blueToHide) / alpha + blueToHide).toInt();

      alpha *= a4 / 255.0;
    }
    pixels[index] = red;
    pixels[index + 1] = green;
    pixels[index + 2] = blue;
    pixels[index + 3] = alpha.toInt();
  }
}
