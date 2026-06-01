import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fit_app/providers/subscription_provider.dart';
import 'package:fit_app/screens/profile/edit_personal_info_screen.dart';
import 'package:fit_app/screens/profile/saved_items_screen.dart';
import 'package:fit_app/screens/profile/progress_chart_screen.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/utils/token_storage.dart';
import 'package:fit_app/services/auth_service.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/user_model.dart';
import 'package:fit_app/screens/client/MyRequestsScreen.dart';
import 'package:fit_app/widgets/profile_image_picker.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  bool _notificationEnabled = true;
  bool _isLoading = true;
  UserModel? _user;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Refresh subscription status whenever profile screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().refresh();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _userService.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              _buildProfilePhoto(),
              const SizedBox(height: 12),
              Text(
                _isLoading ? 'Loading...' : '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: StoreColors.textWhite,
                ),
              ),
              const SizedBox(height: 32),

              // Metrics Row
              _isLoading 
                  ? const CircularProgressIndicator(color: StoreColors.primary)
                  : _buildMetricsRow(),
              const SizedBox(height: 32),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildMenuItem(
                      iconPath: 'lib/assets/images/profile/ic_edit_profile.svg',
                      title: 'Edit Personal info',
                      onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPersonalInfoScreen()));
                        if (result == true) {
                          _loadProfile();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      iconPath: 'lib/assets/images/profile/ic_saved.svg',
                      title: 'Saved',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedItemsScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      iconPath: 'lib/assets/images/profile/ic_chart.svg',
                      title: 'Progress chart',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressChartScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItemWithBadge(
                      iconPath: 'lib/assets/images/profile/ic_subscription.svg',
                      title: 'Subscription plan',
                      onTap: () {
                        // Navigate to Subscription
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      iconPath: 'lib/assets/images/profile/ic_chart.svg',
                      title: 'My Requests',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyRequestsScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationItem(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return const ProfileImagePicker(
      isCoach: false,
      radius: 50.0,
    );
  }



  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricItem('lib/assets/images/profile/ic_calendar_green.svg', '20 Year'), // Age usually separate or calculated
            _buildVerticalDivider(),
            _buildMetricItem('lib/assets/images/profile/ic_weight.svg', '${_user?.weight ?? '--'} kG'),
            _buildVerticalDivider(),
            _buildMetricItem('lib/assets/images/profile/ic_height.svg', '${_user?.height ?? '--'} CM'),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 55,
      color: const Color(0xFF5C5C5C),
    );
  }

  Widget _buildMetricItem(String iconPath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(StoreColors.primary, BlendMode.srcIn),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: StoreColors.textWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required String iconPath, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF5C5C5C)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(StoreColors.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: StoreColors.textWhite,
              ),
            ),
            const Spacer(),
            const RotatedBox(
              quarterTurns: 1,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Color(0xFF5C5C5C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Same as _buildMenuItem but shows a subscription status pill.
  Widget _buildMenuItemWithBadge({required String iconPath, required String title, required VoidCallback onTap}) {
    final subStatus = context.watch<SubscriptionProvider>().status.subscriptionStatus;
    final isActive = subStatus == 'active';
    final badgeColor = isActive ? StoreColors.primary : Colors.redAccent;
    final badgeLabel = isActive ? 'Active' : subStatus == 'canceled' ? 'Canceled' : 'None';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF5C5C5C)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(StoreColors.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: StoreColors.textWhite,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF5C5C5C)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNotificationItem() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5C5C5C)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'lib/assets/images/profile/ic_notification_bell_green.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(StoreColors.primary, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          const Text(
            'Notification',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: StoreColors.textWhite,
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: _notificationEnabled,
              activeTrackColor: StoreColors.primary,
              inactiveTrackColor: const Color(0xFFC4C4C4).withValues(alpha: 0.2),
              onChanged: (bool value) {
                setState(() {
                  _notificationEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        // Optional: show a loading indicator here
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: StoreColors.primary),
          ),
        );

        final authService = AuthService();
        final response = await authService.logout();

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Regardless of success/failure of the API, clear tokens and exit
        await TokenStorage.clearAll();
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Logged out.'),
            backgroundColor: response.isSuccess ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Push user back to login safely
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE93636).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/images/profile/ic_logout.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFFE93636), BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFFE93636),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
