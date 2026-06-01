import 'dart:io';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/update_profile_model.dart';
import 'package:fit_app/widgets/profile_image_picker.dart';
import 'package:fit_app/models/certification_model.dart';

class CoachInfoScreen extends StatefulWidget {
  const CoachInfoScreen({super.key});

  @override
  State<CoachInfoScreen> createState() => _CoachInfoScreenState();
}

class _CoachInfoScreenState extends State<CoachInfoScreen> {
  final TextEditingController _bioController = TextEditingController();
  int _yearsOfExperience = 5;
  final List<String> _selectedSpecializations = ['HIIT', 'Crossfit'];
  final List<String> _specializations = ['HIIT', 'Strength', 'Yoga', 'Crossfit'];
  int _bioLength = 0;
  bool _isUploadingCert = false;
  bool _isLoading = false;
  
  final List<CertificationModel> _certifications = [];

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCertification() async {
    if (_isUploadingCert) return;
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploadingCert = true;
        });
        
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase() ?? '';
        final fileType = extension == 'pdf' ? 'pdf' : 'image';
        
        // Mock upload logic - save locally
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final savedFile = await file.copy('${directory.path}/$fileName');
        
        final cert = CertificationModel(
          title: result.files.single.name,
          issueDate: 'Issued ${DateTime.now().year}',
          fileUrl: savedFile.path,
          fileType: fileType,
          uploadedAt: DateTime.now().toIso8601String(),
        );

        setState(() {
          _certifications.add(cert);
          _isUploadingCert = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certification uploaded successfully!')),
        );
      } else {
        // User canceled the picker
      }
    } catch (e) {
      setState(() {
        _isUploadingCert = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading certification: $e')),
      );
    }
  }

  void _incrementYears() {
    setState(() {
      _yearsOfExperience++;
    });
  }

  void _decrementYears() {
    setState(() {
      if (_yearsOfExperience > 0) _yearsOfExperience--;
    });
  }

  void _toggleSpecialization(String spec) {
    setState(() {
      if (_selectedSpecializations.contains(spec)) {
        _selectedSpecializations.remove(spec);
      } else {
        _selectedSpecializations.add(spec);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Media Query to help with responsive sizing if needed
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard opens, might need handling if user types in bio
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: isSmallScreen ? 10 : 20),
              
              // Profile Photo Upload - Fixed height area
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        ProfileImagePicker(isCoach: true, radius: isSmallScreen ? 50.0 : 64.5),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload photo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2C2C2C), thickness: 1),
              
              // Expanded area for the form content to distribute space
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // About You
                    _buildSection(
                      title: 'About You',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Short Bio',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$_bioLength/300',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _bioLength >= 300 ? Colors.red : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: isSmallScreen ? 80 : 100, // Reduced height
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0FD3E)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _bioController,
                              maxLines: null,
                              maxLength: 300,
                              onChanged: (text) {
                                setState(() {
                                  _bioLength = text.length;
                                });
                                print("Bio text changed");
                                print(_bioLength);
                              },
                              buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Describe your coaching style...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6C737B),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Years of Experience
                    _buildSection(
                      title: 'Years Of Experience',
                      child: Row(
                        children: [
                          _buildIconButton(Icons.remove, _decrementYears),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFD0FD3E)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_yearsOfExperience Years',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildIconButton(Icons.add, _incrementYears),
                        ],
                      ),
                    ),

                    // Specializations
                    _buildSection(
                      title: 'Specializations',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._specializations.map((spec) => _buildChip(spec)),
                          _buildAddChip(),
                        ],
                      ),
                    ),

                    // Certifications
                    _buildSection(
                      title: 'Certifications',
                      isHeaderOnly: true,
                      trailing: GestureDetector(
                        onTap: _pickAndUploadCertification,
                        child: Row(
                          children: [
                            if (_isUploadingCert)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(color: Color(0xFFD0FD3E), strokeWidth: 2),
                              )
                            else
                              const Icon(Icons.add, color: Color(0xFFD0FD3E), size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              'Add New',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD0FD3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: _certifications.isEmpty
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F272D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'No certifications uploaded.',
                                style: TextStyle(
                                  color: Color(0xFF6C737B),
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : Column(
                              children: _certifications.map((cert) {
                                return GestureDetector(
                                  onTap: () {
                                    if (cert.fileUrl.isNotEmpty) {
                                      OpenFilex.open(cert.fileUrl);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1F272D),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFD0FD3E)),
                                            image: cert.fileType == 'image' && cert.fileUrl.isNotEmpty
                                                ? DecorationImage(
                                                    image: FileImage(File(cert.fileUrl)),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: cert.fileType != 'image'
                                              ? const Center(
                                                  child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cert.title,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                cert.issueDate,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF6C737B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    final bio = _bioController.text.trim();
                    if (bio.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bio is required')),
                      );
                      return;
                    }

                    if (_selectedSpecializations.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('At least 1 Specialty is required')),
                      );
                      return;
                    }

                    if (_yearsOfExperience <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Experience Years must be > 0')),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final coachService = CoachService();
                      await coachService.createCoachProfile(
                        bio: bio,
                        specialties: _selectedSpecializations,
                        experienceYears: _yearsOfExperience,
                        certifications: _certifications.map((c) => c.toJson()).toList(),
                      );
                      
                      // Success
                      await UserService().updateProfile(
                        UpdateProfileRequest(onboardingCompleted: true),
                      );

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/coach-home');
                    } catch (e) {
                      final errorStr = e.toString();
                      if (errorStr.contains('Profile already exists')) {
                         await UserService().updateProfile(
                           UpdateProfileRequest(onboardingCompleted: true),
                         );
                         if (!context.mounted) return;
                         Navigator.pushReplacementNamed(context, '/coach-home');
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(errorStr.replaceAll('Exception: ', ''))),
                         );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    disabledBackgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.5),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child, Widget? trailing, bool isHeaderOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        if (!isHeaderOnly) const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0FD3E)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildChip(String spec) {
    final isSelected = _selectedSpecializations.contains(spec);
    return GestureDetector(
      onTap: () => _toggleSpecialization(spec),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD0FD3E) : Colors.transparent,
          border: Border.all(color: const Color(0xFFD0FD3E)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              spec,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : const Color(0xFFF0F0F0),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0FD3E)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Color(0xFFD0FD3E), size: 14),
          Text(
            'Add',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD0FD3E),
            ),
          ),
        ],
      ),
    );
  }
}
