import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final candidates = [
    'assets/icon/app_icon_v3.png',
    'assets/icon/app_icon_v2.png',
    'assets/icon/app_icon.png'
  ];
  
  img.Image? image;
  String? selectedPath;
  
  for (final path in candidates) {
    print('Trying to load $path...');
    final file = File(path);
    if (!file.existsSync()) continue;
    image = img.decodeImage(file.readAsBytesSync());
    if (image != null) {
      selectedPath = path;
      print('Successfully decoded $path');
      break;
    }
  }
  
  if (image == null) {
    print('Failed to decode any icon image.');
    return;
  }
  
  final width = image.width;
  final height = image.height;
  print('Original size: $width x $height');
  
  // Scale down to 58% to fit perfectly inside adaptive icon safe zone
  final newW = (width * 0.58).toInt();
  final newH = (height * 0.58).toInt();
  print('Resizing logo to: $newW x $newH');
  
  final resized = img.copyResize(image, width: newW, height: newH, interpolation: img.Interpolation.cubic);
  
  // Create transparent canvas
  final canvas = img.Image(width: width, height: height, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
  
  // Paste resized image in the center
  final offsetX = (width - newW) ~/ 2;
  final offsetY = (height - newH) ~/ 2;
  
  img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
  
  final outPath = 'assets/icon/app_icon_adaptive_foreground.png';
  File(outPath).writeAsBytesSync(img.encodePng(canvas));
  print('Successfully generated adaptive icon foreground at: $outPath');
}
