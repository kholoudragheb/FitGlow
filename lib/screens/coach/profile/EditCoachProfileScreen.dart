import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/certification_model.dart';
import 'package:fit_app/widgets/profile_image_picker.dart';

class EditCoachProfileScreen extends StatefulWidget {
  const EditCoachProfileScreen({super.key});

  @override
  State<EditCoachProfileScreen> createState() => _EditCoachProfileScreenState();
}

class _EditCoachProfileScreenState extends State<EditCoachProfileScreen> {
  final CoachService _coachService = CoachService();
  
  bool _isLoadingInitial = true;
  bool _isSaving = false;
  
  final TextEditingController _bioController = TextEditingController();
  int _yearsOfExperience = 5;
  List<String> _selectedSpecializations = [];
  final List<String> _specializations = ['HIIT', 'Strength Training', 'Yoga', 'Crossfit', 'Weight Loss', 'Bodybuilding'];
  List<CertificationModel> _certifications = [];
  
  int _bioLength = 0;
  bool _isUploadingCert = false;
  
  @override
  void initState() {
    super.initState();
    _fetchExistingProfile();
  }

  Future<void> _fetchExistingProfile() async {
    try {
      final profile = await _coachService.getMyCoachProfile();
      if (mounted) {
        setState(() {
          _bioController.text = profile.bio;
          _bioLength = profile.bio.length;
          _yearsOfExperience = profile.experienceYears > 0 ? profile.experienceYears : 5;
          _selectedSpecializations = List<String>.from(profile.specialties);
          _certifications = profile.certifications.map((c) => CertificationModel.parseString(c)).toList();
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load existing profile')),
        );
        Navigator.pop(context); // exit if we can't load data
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCertification() async {
    if (_isUploadingCert) return;
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploadingCert = true;
        });
        
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase() ?? '';
        final fileType = extension == 'pdf' ? 'pdf' : 'image';
        
        // Save locally as a mock upload
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
        // Canceled
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

  Future<void> _saveChanges() async {
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
      _isSaving = true;
    });

    try {
      final updatedProfile = await _coachService.updateCoachProfile(
        bio: bio,
        specialties: _selectedSpecializations,
        experienceYears: _yearsOfExperience,
        certifications: _certifications.map((c) => c.toJson()).toList(),
      );
      
      if (!mounted) return;
      // Pass the updated profile back so the previous screen can instantly refresh
      Navigator.pop(context, updatedProfile);
      
    } catch (e) {
      final errorStr = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorStr)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Coach Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingInitial 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Profile Image
                const Center(
                  child: ProfileImagePicker(isCoach: true, radius: 60),
                ),
                const SizedBox(height: 30),
                
                // Bio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bio',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      '$_bioLength/300',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: _bioLength >= 300 ? Colors.red : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F272D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 300,
                    onChanged: (text) {
                      setState(() {
                        _bioLength = text.length;
                      });
                      print("Bio text changed");
                      print(_bioLength);
                    },
                    buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Tell us about your experience...',
                      hintStyle: TextStyle(color: Color(0xFFA09D9D)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Specialties
                const Text(
                  'Specialties',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _specializations.map((spec) {
                    final isSelected = _selectedSpecializations.contains(spec);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSpecializations.remove(spec);
                          } else {
                            _selectedSpecializations.add(spec);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF1F272D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          spec,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Experience Years
                const Text(
                  'Years of Experience',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F272D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          if (_yearsOfExperience > 1) {
                            setState(() => _yearsOfExperience--);
                          }
                        },
                      ),
                      Text(
                        '$_yearsOfExperience Years',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() => _yearsOfExperience++);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Certifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Certifications',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
                    ),
                    GestureDetector(
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
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD0FD3E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _certifications.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F272D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No certifications uploaded.',
                          style: TextStyle(
                            color: Color(0xFFA09D9D),
                            fontFamily: 'Poppins',
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
                              margin: const EdgeInsets.only(bottom: 8),
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
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          cert.issueDate,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFA09D9D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _certifications.remove(cert);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0FD3E),
                      disabledBackgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF0C0C0C),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }
}
