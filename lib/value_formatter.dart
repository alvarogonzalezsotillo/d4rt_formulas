

import 'package:flutter/cupertino.dart';

String? formatOutput(dynamic result) {
  if (result == null) return null;

  // Try to parse as number to format with commas
  if (result is num) {
    var tooMuchPrecision = result.toStringAsPrecision(21);
    var parts = tooMuchPrecision.split("e");
    var exponent = parts.length > 1 ? "e${parts[1]}" : "";
    var endingWithZeroes = parts[0];
    while (endingWithZeroes.endsWith('0') && endingWithZeroes.contains('.')) {
      endingWithZeroes = endingWithZeroes.substring(0, endingWithZeroes.length - 1);
    }
    if( endingWithZeroes.endsWith(".") ){
      endingWithZeroes = endingWithZeroes.substring(0, endingWithZeroes.length -1 );
    }
    return endingWithZeroes + exponent;
  }

  // Otherwise return raw string
  return result.toString();
}
