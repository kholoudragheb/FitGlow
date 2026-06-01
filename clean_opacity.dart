import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int count = 0;
  for (var file in files) {
    String content = file.readAsStringSync();
    if (content.contains('.withOpacity(')) {
      content = content.replaceAllMapped(RegExp(r'\.withOpacity\((.*?)\)'), (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      file.writeAsStringSync(content);
      count++;
    }
  }
  print('Fixed $count files');
}
