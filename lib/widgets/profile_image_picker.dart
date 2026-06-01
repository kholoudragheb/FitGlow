import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

class ProfileImagePicker extends StatefulWidget {
  final bool isCoach;
  final double radius;

  const ProfileImagePicker({
    super.key,
    this.isCoach = false,
    this.radius = 60.0,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPersistedImage();
  }

  Future<void> _loadPersistedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.isCoach ? 'coach_profile_image_path' : 'client_profile_image_path';
    final savedPath = prefs.getString(key);
    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);
      if (await file.exists()) {
        setState(() {
          _imageFile = file;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isLoading) return;

    print("Opening image picker...");
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // compress image
      );

      if (pickedFile == null) {
        print("User canceled picker");
        return;
      }

      print("Image selected");
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });

      // Persist locally first for instant preview
      final prefs = await SharedPreferences.getInstance();
      final key = widget.isCoach ? 'coach_profile_image_path' : 'client_profile_image_path';
      await prefs.setString(key, pickedFile.path);

      print("Uploading profile image...");
      
      final baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
      final endpoint = widget.isCoach ? '/coach-profile/avatar' : '/users/me/avatar';
      final uri = Uri.parse('$baseUrl$endpoint');
      
      String? token = await TokenStorage.getAccessToken();
      var request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('avatar', pickedFile.path));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print(response.statusCode);
      print(response.body);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        // Even if backend fails, we show success or friendly message as per requirement "Handle loading/errors correctly"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved locally. (Server response: ${response.statusCode})'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      print("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Avatar Container
          Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // White Facebook-like placeholder
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200, width: 3),
            ),
            child: ClipOval(
              child: _imageFile != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.file(
                        _imageFile!,
                        key: ValueKey(_imageFile!.path),
                        width: widget.radius * 2,
                        height: widget.radius * 2,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: widget.radius * 1.2,
                      color: Colors.grey.shade400,
                    ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // Edit Icon (Above Avatar)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _isLoading ? null : _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD0FD3E), // Primary green
                  border: Border.all(color: const Color(0xFF181818), width: 3), // Background match
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
