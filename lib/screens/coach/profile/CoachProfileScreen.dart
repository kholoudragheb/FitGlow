import 'package:flutter/material.dart';
import 'NotificationPreferencesScreen.dart';
import 'PaymentSubscriptionScreen.dart';
import 'EditProfileScreen.dart';
import 'EditCoachProfileScreen.dart';
import 'package:fit_app/services/auth_service.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/coach_profile_model.dart';
import 'package:fit_app/utils/token_storage.dart';
import '../schedule/MyScheduleScreen.dart';
import '../schedule/CoachSessionsScreen.dart';
import 'package:fit_app/widgets/profile_image_picker.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final CoachService _coachService = CoachService();
  CoachProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String _coachName = 'Coach';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firstName = await TokenStorage.getUserFirstName();
      final lastName = await TokenStorage.getUserLastName();
      if (firstName != null && lastName != null && firstName.isNotEmpty) {
        _coachName = '$firstName $lastName'.trim();
      }

      final profile = await _coachService.getMyCoachProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      final errorStr = e.toString();
      setState(() {
        _isLoading = false;
        if (errorStr.contains('Profile not found')) {
          _errorMessage = 'Coach profile not found';
        } else if (errorStr.contains('Session expired') || errorStr.contains('Unauthorized')) {
          _errorMessage = 'Session expired. Please log in again.';
        } else {
          _errorMessage = 'Failed to load coach profile';
        }
      });
      
      if (!errorStr.contains('Profile not found')) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(_errorMessage!)),
           );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: const Color(0xFFD0FD3E),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
          : (_errorMessage == 'Coach profile not found' || _profile == null)
            ? _buildEmptyState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Profile Image
                    const ProfileImagePicker(isCoach: true, radius: 70.0),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _coachName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        if (_profile!.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Icon(Icons.verified, color: Colors.blue, size: 20),
                          ),
                      ],
                    ),
                    Text(
                      _profile!.specialties.isNotEmpty ? _profile!.specialties.first : 'Certified Personal Trainer',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFFA09D9D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Coach Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Experience', '${_profile!.experienceYears} Yrs'),
                        _buildStatColumn('Rating', _profile!.averageRating.toStringAsFixed(1)),
                        _buildStatColumn('Reviews', '${_profile!.totalReviews}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Bio
                    if (_profile!.bio.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _profile!.bio,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Specialties
                    if (_profile!.specialties.isNotEmpty) ...[
                       _buildSectionHeader('Specialties'),
                       const SizedBox(height: 12),
                       Align(
                         alignment: Alignment.centerLeft,
                         child: Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: _profile!.specialties.map((s) => Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: const Color(0xFF1F272D),
                               borderRadius: BorderRadius.circular(16),
                               border: Border.all(color: const Color(0xFF2C2C2C)),
                             ),
                             child: Text(
                               s,
                               style: const TextStyle(color: Colors.white, fontSize: 12),
                             ),
                           )).toList(),
                         ),
                       ),
                       const SizedBox(height: 32),
                    ],

            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: 12),
            _buildMenuCard([
              _buildMenuItem(
                context,
                Icons.work_outline,
                'Edit Coach Profile',
                const Color(0xFFD0FD3E),
                () async {
                  final updatedProfile = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditCoachProfileScreen()),
                  );
                  if (updatedProfile != null && updatedProfile is CoachProfileModel) {
                    setState(() {
                      _profile = updatedProfile;
                    });
                  }
                },
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.person_outline,
                'Edit Personal Information',
                const Color(0xFFD0FD3E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.payment_outlined,
                'Payment & Subscription',
                const Color(0xFFD0FD3E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentSubscriptionScreen()),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.calendar_today,
                'Manage Availability',
                const Color(0xFFD0FD3E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyScheduleScreen()),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.history,
                'My Sessions',
                const Color(0xFFD0FD3E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoachSessionsScreen()),
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            const SizedBox(height: 12),
            _buildMenuCard([
              _buildMenuItem(
                context,
                Icons.notifications_none,
                'Notification Preferences',
                const Color(0xFFD0FD3E),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.accessibility_new,
                'Terms & Conditions',
                const Color(0xFFD0FD3E),
                () {},
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1),
              _buildMenuItem(
                context,
                Icons.security_outlined,
                'Privacy & Policy',
                const Color(0xFFD0FD3E),
                () {},
              ),
            ]),

            const SizedBox(height: 48),

            // Log Out Button
            GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD0FD3E)),
                  ),
                );

                final authService = AuthService();
                final response = await authService.logout();

                if (context.mounted) {
                  Navigator.pop(context);
                }

                await TokenStorage.clearAll();
                
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message ?? 'Logged out.'),
                    backgroundColor: response.isSuccess ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F272D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Color(0xFFE53935), size: 18),
                    SizedBox(width: 12),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFFD0FD3E),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFFA09D9D),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Coach profile not found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/coach-info');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD0FD3E),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
