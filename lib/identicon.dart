library identicon;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart';

var colourCache = Map<String, List<List<int>>>();

class Identicon {
  int _rows;
  int _cols;

  Function(List<int>) _digest;

  List<int> _fgColour;
  List<int> _bgColour;

  Identicon({int rows = 6, int cols = 6}) {
    this._rows = rows;
    this._cols = cols;

    this._digest = md5.convert;
  }

  _generateColours(String cacheKey) {
    var coloursOk = false;

    if (colourCache.containsKey(cacheKey)) {
      this._fgColour = colourCache[cacheKey][0];
      this._bgColour = colourCache[cacheKey][1];
    } else {
      while (!coloursOk) {
        this._fgColour = this._getPastelColour();
        if (this._bgColour == null) {
          this._bgColour = this._getPastelColour(lighten: 80);

          var fgLum = this._luminance(this._fgColour) + 0.05;
          var bgLum = this._luminance(this._bgColour) + 0.05;
          if (fgLum / bgLum > 1.20) {
            coloursOk = true;
          }
        } else {
          coloursOk = true;
        }
      }
      colourCache[cacheKey] = [this._fgColour, this._bgColour];
    }
  }

  _getPastelColour({int lighten = 127}) {
    var r = () => Random().nextInt(128) + lighten;
    return [r(), r(), r()];
  }

  _luminance(rgb) {
    var a = [];
    for (var v in rgb) {
      v = v / 255.0;
      var result = (v < 0.03928) ? v / 12.92 : pow(((v + 0.055) / 1.055), 2.4);
      a.add(result);
    }

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  _bitIsOne(int n, List<int> hashBytes) {
    var scale = 16;
    return hashBytes[n ~/ (scale / 2)] >>
        ((scale / 2) - ((n % (scale / 2)) + 1)).toInt() &
    1 ==
        1;
  }

  _createImage(List<List<bool>> matrix, int width, int height, int pad) {
    var image = Image.rgb(width + (pad * 2), height + (pad * 2));
    image.fill(Color.fromRgb(
        this._bgColour[0], this._bgColour[1], this._bgColour[2]));

    var blockWidth = width ~/ this._cols;
    var blockHeight = height ~/ this._rows;

    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col]) {
          fillRect(
            image,
            pad + col * blockWidth,
            pad + row * blockHeight,
            pad + (col + 1) * blockWidth - 1,
            pad + (row + 1) * blockHeight - 1,
            Color.fromRgb(
                this._fgColour[0], this._fgColour[1], this._fgColour[2]),
          );
        }
      }
    }
    return writePng(image);
  }

  _createMatrix(List<int> byteList) {
    var cells = (this._rows * this._cols / 2 + this._cols % 2).toInt();
    var matrix = List.generate(
        this._rows, (_) => List.generate(this._cols, (_) => false));

    for (int n = 0; n < cells; n++) {
      if (this
          ._bitIsOne(n, byteList.getRange(1, byteList.length).toList())) {
        var row = n % this._rows;
        var col = n ~/ this._cols;
        matrix[row][this._cols - col - 1] = true;
        matrix[row][col] = true;
      }
    }
    return matrix;
  }

  Uint8List generate(String text, {int size = 36}) {
    var bytesLength = 16;
    var hexDigest = this._digest(utf8.encode(text)).toString();

    var hexDigestByteList = List<int>.generate(bytesLength, (int i) {
      return int.parse(hexDigest.substring(i * 2, i * 2 + 2),
          radix: bytesLength);
    });

    this._generateColours(hexDigest);

    var matrix = this._createMatrix(hexDigestByteList);
    return this._createImage(matrix, size, size, (size * 0.1).toInt());
  }
}