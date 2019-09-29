library identicon;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart';

class Identicon {
  int _rows;
  int _cols;

  Function(List<int>) _digest;

  List<int> _fg_colour;
  List<int> _bg_colour;

  Identicon({int rows = 6, int cols = 6}) {
    this._rows = rows;
    this._cols = cols;

    this._generate_colours();
    this._digest = md5.convert;
  }

  _generate_colours() {
    var colours_ok = false;

    while (!colours_ok) {
      this._fg_colour = this._get_pastel_colour();
      if (this._bg_colour == null) {
        this._bg_colour = this._get_pastel_colour(lighten: 80);

        var fg_lum = this._luminance(this._fg_colour) + 0.05;
        var bg_lum = this._luminance(this._bg_colour) + 0.05;
        if (fg_lum / bg_lum > 1.20) {
          colours_ok = true;
        }
      } else {
        colours_ok = true;
      }
    }
  }

  _get_image(String text, int width, int height, {int pad = 0}) {
    var hex_digest_byte_list = this._string_to_byte_list(text);
    var matrix = this._create_matrix(hex_digest_byte_list);
    return this._create_image(matrix, width, height, pad);
  }

  _get_pastel_colour({int lighten = 127}) {
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

  _string_to_byte_list(String data) {
    var bytes_length = 16;
    var hex_digest = this._digest(utf8.encode(data)).toString();

    return List<int>.generate(bytes_length, (int i) {
      return int.parse(hex_digest.substring(i * 2, i * 2 + 2),
          radix: bytes_length);
    });
  }

  _bit_is_one(int n, List<int> hash_bytes) {
    var scale = 16;
    return hash_bytes[n ~/ (scale / 2)] >>
                ((scale / 2) - ((n % (scale / 2)) + 1)).toInt() &
            1 ==
        1;
  }

  _create_image(List<List<bool>> matrix, int width, int height, int pad) {
    var image = Image.rgb(width + (pad * 2), height + (pad * 2));
    image.fill(
        Color.fromRgb(this._bg_colour[0], this._bg_colour[1], this._bg_colour[2]));

    var block_width = width ~/ this._cols;
    var block_height = height ~/ this._rows;

    for (int row = 0; row < matrix.length; row++) {
      for (int col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col]) {
          fillRect(
            image,
            pad + col * block_width,
            pad + row * block_height,
            pad + (col + 1) * block_width - 1,
            pad + (row + 1) * block_height - 1,
            Color.fromRgb(
                this._fg_colour[0], this._fg_colour[1], this._fg_colour[2]),
          );
        }
      }
    }
    return writePng(image);
  }

  _create_matrix(List<int> byte_list) {
    var cells = (this._rows * this._cols / 2 + this._cols % 2).toInt();
    var matrix =
        List.generate(this._rows, (_) => List.generate(this._cols, (_) => false));

    for (int n = 0; n < cells; n++) {
      if (this
          ._bit_is_one(n, byte_list.getRange(1, byte_list.length).toList())) {
        var x_row = n % this._rows;
        var y_col = n ~/ this._cols;
        matrix[x_row][this._cols - y_col - 1] = true;
        matrix[x_row][y_col] = true;
      }
    }
    return matrix;
  }

  Uint8List generate(String text, {int size = 36}) {
    return this._get_image(text, size, size, pad: (size * 0.1).toInt());
  }
}
