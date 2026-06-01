import 'package:fit_app/models/onboarding_data.dart';
import 'package:fit_app/screens/BuildGoalScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildYourProfileScreen extends StatefulWidget {
  const BuildYourProfileScreen({super.key});

  @override
  State<BuildYourProfileScreen> createState() => _BuildYourProfileScreenState();
}

class _BuildYourProfileScreenState extends State<BuildYourProfileScreen> {
  // Will be populated from route arguments (passed by OTPVerificationScreen)
  late final OnboardingData _data;

  String? selectedGender;
  String? selectedDOB;
  String? selectedWeight; // display string e.g. "70 kg"
  String? selectedHeight; // display string e.g. "175 cm"
  int _weightKg = 60;
  int _heightCm = 170;

  static const Color limeGreen = Color(0xFFCDFF00);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _data = (args?['onboardingData'] as OnboardingData?) ?? OnboardingData();
  }

  Widget _buildSelectionField({
    required String hint,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint,
              style: TextStyle(
                color: value != null ? Colors.white : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showCustomModal({
    required BuildContext context,
    required String title,
    required Widget child,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: child),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: limeGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: limeGreen, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSave();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: limeGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenderPicker() {
    String tempGender = selectedGender ?? 'Male';
    final List<String> genders = ['Male', 'Female'];
    _showCustomModal(
      context: context,
      title: 'Gender',
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        child: CupertinoPicker(
          itemExtent: 40,
          selectionOverlay: Container(
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: limeGreen, width: 1.0),
              ),
            ),
          ),
          scrollController: FixedExtentScrollController(
            initialItem: genders.contains(tempGender)
                ? genders.indexOf(tempGender)
                : 0,
          ),
          onSelectedItemChanged: (i) => tempGender = genders[i],
          children: genders.map((g) => Center(child: Text(g))).toList(),
        ),
      ),
      onSave: () => setState(() => selectedGender = tempGender),
    );
  }

  void _showDatePicker() {
    int selDay = 1;
    String selMonth = 'Jan';
    int selYear = 2000;
    final days = List.generate(31, (i) => i + 1);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final years = List.generate(100, (i) => 2024 - i);

    _showCustomModal(
      context: context,
      title: 'Date Of Birth',
      child: Row(
        children: [
          Expanded(
            child: _buildCupertinoScroll(
              items: months,
              initialItem: months.indexOf(selMonth),
              onChanged: (i) => selMonth = months[i],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCupertinoScroll(
              items: days.map((e) => e.toString()).toList(),
              initialItem: days.indexOf(selDay),
              onChanged: (i) => selDay = days[i],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCupertinoScroll(
              items: years.map((e) => e.toString()).toList(),
              initialItem: years.indexOf(selYear),
              onChanged: (i) => selYear = years[i],
            ),
          ),
        ],
      ),
      onSave: () => setState(() => selectedDOB = '$selMonth $selDay, $selYear'),
    );
  }

  void _showWeightPicker() {
    int tempVal = _weightKg;
    String tempUnit = 'kg';
    final weights = List.generate(150, (i) => 30 + i);
    final units = ['kg', 'lbs'];

    _showCustomModal(
      context: context,
      title: 'Current Weight',
      child: Row(
        children: [
          Expanded(
            child: _buildCupertinoScroll(
              items: weights.map((e) => e.toString()).toList(),
              initialItem: weights.indexOf(tempVal),
              onChanged: (i) => tempVal = weights[i],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildCupertinoScroll(
              items: units,
              initialItem: units.indexOf(tempUnit),
              onChanged: (i) => tempUnit = units[i],
            ),
          ),
        ],
      ),
      onSave: () {
        setState(() {
          _weightKg = tempUnit == 'lbs' ? (tempVal / 2.205).round() : tempVal;
          selectedWeight = '$tempVal $tempUnit';
        });
      },
    );
  }

  void _showHeightPicker() {
    int tempVal = _heightCm;
    String tempUnit = 'cm';
    final heights = List.generate(120, (i) => 100 + i);
    final units = ['cm', 'ft'];

    _showCustomModal(
      context: context,
      title: 'Height',
      child: Row(
        children: [
          Expanded(
            child: _buildCupertinoScroll(
              items: heights.map((e) => e.toString()).toList(),
              initialItem: heights.indexOf(tempVal),
              onChanged: (i) => tempVal = heights[i],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildCupertinoScroll(
              items: units,
              initialItem: units.indexOf(tempUnit),
              onChanged: (i) => tempUnit = units[i],
            ),
          ),
        ],
      ),
      onSave: () {
        setState(() {
          _heightCm = tempUnit == 'ft' ? (tempVal * 30.48).round() : tempVal;
          selectedHeight = '$tempVal $tempUnit';
        });
      },
    );
  }

  Widget _buildCupertinoScroll({
    required List<String> items,
    required int initialItem,
    required Function(int) onChanged,
  }) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      child: CupertinoPicker(
        itemExtent: 40,
        selectionOverlay: Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: limeGreen, width: 1.0),
            ),
          ),
        ),
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        onSelectedItemChanged: onChanged,
        children: items.map((e) => Center(child: Text(e))).toList(),
      ),
    );
  }

  void _onNext() {
    // Save collected data into the shared OnboardingData object
    _data.gender = selectedGender;
    _data.dateOfBirth = selectedDOB;
    _data.weightKg = _weightKg;
    _data.heightCm = _heightCm;

    print(
      '[Onboarding] Step 1 data — gender: ${_data.gender}, DOB: ${_data.dateOfBirth}, '
      'weight: ${_data.weightKg} kg, height: ${_data.heightCm} cm',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildGoalScreen(onboardingData: _data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Build Your Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tailor your experience',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    decoration: BoxDecoration(
                      color: limeGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '1/7',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildSelectionField(
                hint: 'Gender',
                value: selectedGender,
                onTap: _showGenderPicker,
              ),
              const SizedBox(height: 16),
              _buildSelectionField(
                hint: 'Date of Birth',
                value: selectedDOB,
                onTap: _showDatePicker,
              ),
              const SizedBox(height: 16),
              _buildSelectionField(
                hint: 'Current Weight',
                value: selectedWeight,
                onTap: _showWeightPicker,
              ),
              const SizedBox(height: 16),
              _buildSelectionField(
                hint: 'Height',
                value: selectedHeight,
                onTap: _showHeightPicker,
              ),
              const Spacer(flex: 2),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: limeGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
