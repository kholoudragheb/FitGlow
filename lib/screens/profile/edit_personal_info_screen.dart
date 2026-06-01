import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/user_model.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedDateOfBirth;
  String? _selectedWeight;
  String? _selectedHeight;
  String? _selectedGender;
  String? _selectedFitnessGoal;
  String? _selectedFitnessLevel;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final UserService _userService = UserService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = await _userService.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = '${user.firstName} ${user.lastName}';
          _emailController.text = user.email;
          _selectedWeight = user.weight != null ? '${user.weight} Kg' : null;
          _selectedHeight = user.height != null ? '${user.height} cm' : null;
          _selectedGender = user.gender;
          _selectedFitnessGoal = user.fitnessGoal;
          _selectedFitnessLevel = user.fitnessLevel;
        });
      }
    } catch (e) {
      print('Error loading initial profile data: $e');
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _selectedGender == null || _selectedGender!.isEmpty ||
        _selectedHeight == null || _selectedHeight!.isEmpty ||
        _selectedWeight == null || _selectedWeight!.isEmpty ||
        _selectedFitnessGoal == null || _selectedFitnessGoal!.isEmpty ||
        _selectedFitnessLevel == null || _selectedFitnessLevel!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      int heightInt = 0;
      if (_selectedHeight != null) {
        final h = _selectedHeight!.replaceAll(' cm', '').replaceAll(' ft.in', '').trim();
        heightInt = double.tryParse(h)?.round() ?? 0;
      }

      int weightInt = 0;
      if (_selectedWeight != null) {
        final w = _selectedWeight!.replaceAll(' Kg', '').replaceAll(' lbs', '').trim();
        weightInt = double.tryParse(w)?.round() ?? 0;
      }

      await _userService.updateProfileFields(
        firstName: firstName,
        lastName: lastName,
        gender: _selectedGender!,
        height: heightInt,
        weight: weightInt,
        fitnessGoal: _selectedFitnessGoal!,
        fitnessLevel: _selectedFitnessLevel!,
        onboardingCompleted: _user?.onboardingCompleted ?? true,
      );

      if (!mounted) return;

      // Immediately fetch again as requested
      final freshUser = await _userService.getProfile();

      if (mounted) {
        setState(() {
          _user = freshUser;
        });
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
      } else if (e.toString().contains('400')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid data submitted. Check your fields.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
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
    return Scaffold(
      backgroundColor: StoreColors.background,
      appBar: AppBar(
        backgroundColor: StoreColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'lib/assets/images/profile/ic_back_arrow_square.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
        leadingWidth: 48,
        title: const Text(
          'Edit Personal info',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: StoreColors.textWhite,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _buildTextField(
                        label: 'Name',
                        hint: 'Enter new name',
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email',
                        hint: 'Enter new email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Password',
                        hint: 'Enter new Password',
                        controller: _passwordController,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildPickerField(
                        label: 'Date of Birth',
                        value: _selectedDateOfBirth,
                        onTap: () => _showDobPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerField(
                        label: 'Current Weight ',
                        value: _selectedWeight,
                        onTap: () => _showWeightPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerField(
                        label: 'Height ',
                        value: _selectedHeight,
                        onTap: () => _showHeightPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerField(
                        label: 'Gender',
                        value: _selectedGender,
                        onTap: () => _showGenderPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerField(
                        label: 'Fitness Goal',
                        value: _selectedFitnessGoal,
                        onTap: () => _showFitnessGoalPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerField(
                        label: 'Fitness Level',
                        value: _selectedFitnessLevel,
                        onTap: () => _showFitnessLevelPickerBottomSheet(context),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Save Button
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoreColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF0C0C0C),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: StoreColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: StoreColors.background,
            border: Border.all(color: const Color(0xFF6D6D6D)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: StoreColors.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF545454),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              isDense: true,
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: onTogglePassword,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'lib/assets/images/profile/ic_eye_hide.svg',
                          colorFilter: const ColorFilter.mode(Color(0xFF545454), BlendMode.srcIn),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({required String label, String? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: StoreColors.background,
          border: Border.all(color: const Color(0xFF6D6D6D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: value != null ? StoreColors.textWhite : const Color(0xFF5C5C5C),
              ),
            ),
            SvgPicture.asset(
              'lib/assets/images/profile/ic_dropdown_arrow.svg',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ==== BOTTOM SHEETS ====

  void _showGenderPickerBottomSheet(BuildContext context) {
    List<String> options = ['Male', 'Female'];
    int initialIndex = _selectedGender != null ? options.indexOf(_selectedGender!) : 0;
    if (initialIndex == -1) initialIndex = 0;
    String tempSelection = options[initialIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildPickerBottomSheetContent(
          title: 'Gender',
          pickerWidget: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              tempSelection = options[index];
            },
            children: options.map((e) => Center(child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
          ),
          onSave: () {
            setState(() {
              _selectedGender = tempSelection;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showFitnessGoalPickerBottomSheet(BuildContext context) {
    List<String> options = ['Gain Muscle', 'Lose Weight', 'Stay Fit'];
    int initialIndex = _selectedFitnessGoal != null ? options.indexOf(_selectedFitnessGoal!) : 0;
    if (initialIndex == -1) initialIndex = 0;
    String tempSelection = options[initialIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildPickerBottomSheetContent(
          title: 'Fitness Goal',
          pickerWidget: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              tempSelection = options[index];
            },
            children: options.map((e) => Center(child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
          ),
          onSave: () {
            setState(() {
              _selectedFitnessGoal = tempSelection;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showFitnessLevelPickerBottomSheet(BuildContext context) {
    List<String> options = ['Beginner', 'Intermediate', 'Advanced'];
    int initialIndex = _selectedFitnessLevel != null ? options.indexOf(_selectedFitnessLevel!) : 0;
    if (initialIndex == -1) initialIndex = 0;
    String tempSelection = options[initialIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildPickerBottomSheetContent(
          title: 'Fitness Level',
          pickerWidget: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              tempSelection = options[index];
            },
            children: options.map((e) => Center(child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
          ),
          onSave: () {
            setState(() {
              _selectedFitnessLevel = tempSelection;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showDobPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildPickerBottomSheetContent(
          title: 'Date Of Birth',
          pickerWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCupertinoPickerColumn(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], 2), // Mar
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(List.generate(31, (index) => '${index + 1}'), 2), // 3
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(List.generate(100, (index) => '${2000 + index}'), 4), // 2004
            ],
          ),
          onSave: () {
            setState(() {
              _selectedDateOfBirth = 'Mar 3, 2004'; // Mocked save
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showWeightPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildPickerBottomSheetContent(
          title: 'Current Weight',
          pickerWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCupertinoPickerColumn(List.generate(150, (index) => '${60 + index}'), 61), // 121
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(['.1', '.2', '.3', '.4', '.5', '.6', '.7', '.8', '.9', '.0'], 2), // .3
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(['Kg', 'lbs'], 0), // Kg
            ],
          ),
          onSave: () {
            setState(() {
              _selectedWeight = '121.3 Kg'; // Mocked save
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showHeightPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildPickerBottomSheetContent(
          title: 'Height',
          pickerWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // This mocks the design pattern based on Figma, for feet/inches or cm
              _buildCupertinoPickerColumn(['160', '161', '162', '163', '164', '165', '166', '167', '168', '169'], 5), // 165
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(['.0', '.1', '.2', '.3', '.4', '.5', '.6', '.7', '.8', '.9'], 2), // .2
              const SizedBox(width: 40),
              _buildCupertinoPickerColumn(['cm', 'ft.in'], 0), // cm
            ],
          ),
          onSave: () {
            setState(() {
              _selectedHeight = '165.2 cm';
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildPickerBottomSheetContent({
    required String title,
    required Widget pickerWidget,
    required VoidCallback onSave,
  }) {
    return Container(
      height: 332,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2C2E).withValues(alpha: 1),
            blurRadius: 8,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: StoreColors.textWhite,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight boundaries lines for the selected item in CupertinoPicker
                Positioned(
                  top: 71 + 30, // roughly center
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPickerHighlightLine(),
                        const SizedBox(width: 40),
                        _buildPickerHighlightLine(),
                        const SizedBox(width: 40),
                        _buildPickerHighlightLine(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 71 + 60, // roughly center bottom bound
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPickerHighlightLine(),
                        const SizedBox(width: 40),
                        _buildPickerHighlightLine(),
                        const SizedBox(width: 40),
                        _buildPickerHighlightLine(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: StoreColors.textWhite,
                    ),
                    child: pickerWidget,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: StoreColors.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: StoreColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoreColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF0C0C0C),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoPickerColumn(List<String> items, int initialIndex) {
    return SizedBox(
      width: 40,
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        selectionOverlay: const SizedBox.shrink(), // We draw custom highlight lines
        itemExtent: 30, // matches spacing roughly in design
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: (int index) {},
        children: List<Widget>.generate(items.length, (int index) {
          return Center(
            child: Text(
              items[index],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: StoreColors.textWhite, // We might want to use different color for unselected, but simple list works
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPickerHighlightLine() {
    return Container(
      width: 39,
      height: 1,
      color: StoreColors.primary, // Using primary color #D0FD3E for lines based on the design
    );
  }
}
