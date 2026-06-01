import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class AssetTestScreen extends StatefulWidget {
  const AssetTestScreen({super.key});

  @override
  State<AssetTestScreen> createState() => _AssetTestScreenState();
}

class _AssetTestScreenState extends State<AssetTestScreen> {
  String _log = "Initializing...";
  List<String> _assetsFound = [];

  @override
  void initState() {
    super.initState();
    _checkAssets();
  }

  Future<void> _checkAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final icons = manifestMap.keys
          .where((key) => key.contains('lib/assets/icons/'))
          .toList();

      setState(() {
        _assetsFound = icons;
        _log = "Found ${icons.length} icons in AssetManifest.json";
      });
    } catch (e) {
      setState(() {
        _log = "Error loading manifest: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asset Debugger")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_log, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _assetsFound.length,
              itemBuilder: (context, index) {
                final path = _assetsFound[index];
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: SvgPicture.asset(
                      path, 
                      width: 24, 
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      placeholderBuilder: (_) => const Icon(Icons.error, color: Colors.red),
                    ),
                    title: Text(path, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
