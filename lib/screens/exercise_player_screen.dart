import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import '../models/workout_models.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final Exercise exercise;
  final int currentIndex;
  final int totalExercises;

  const ExercisePlayerScreen({
    super.key,
    required this.exercise,
    required this.currentIndex,
    required this.totalExercises,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  double _progress = 0.3; // Mock progress
  bool _isPlaying = false;
  final double _playbackSpeed = 1.0;

  // Default instructions if exercise doesn't have them
  List<String> get _howToSteps => widget.exercise.howToSteps.isNotEmpty
      ? widget.exercise.howToSteps
      : [
          'Lorem ipsum dolor sit amet consectetur.',
          'Lorem ipsum dolor sit amet consectetur.',
          'Lorem ipsum dolor sit amet consectetur.',
        ];

  List<String> get _keyTips => widget.exercise.keyTips.isNotEmpty
      ? widget.exercise.keyTips
      : [
          'Lorem ipsum dolor sit amet consectetur.',
          'Lorem ipsum dolor sit amet consectetur.',
          'Lorem ipsum dolor sit amet consectetur.',
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppConstants.iconBack,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppConstants.iconPrev,
                            colorFilter: const ColorFilter.mode(
                              AppConstants.textSecondary,
                              BlendMode.srcIn,
                            ),
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.currentIndex + 1}/${widget.totalExercises}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            AppConstants.iconNext,
                            colorFilter: const ColorFilter.mode(
                              AppConstants.textSecondary,
                              BlendMode.srcIn,
                            ),
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Exercise Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Video Player Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Video placeholder with illustration
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        child: Image.asset(
                          widget.exercise.thumbnailImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // Center Controls (Prev, Play/Pause, Next)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Prev
                          GestureDetector(
                            onTap: () {
                              // Handle prev
                            },
                            child: SvgPicture.asset(
                              AppConstants.iconPrev,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(width: 24),
                          
                          // Play/Pause
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  _isPlaying ? AppConstants.iconPause : AppConstants.iconPlay,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 24),
                          
                          // Next
                          GestureDetector(
                            onTap: () {
                              // Handle next
                            },
                            child: SvgPicture.asset(
                              AppConstants.iconNext,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Video Controls at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // Volume
                            Icon(
                              Icons.volume_up,
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Progress Bar
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: AppConstants.primaryColor,
                                  inactiveTrackColor: Colors.grey.shade700,
                                  thumbColor: AppConstants.primaryColor,
                                ),
                                child: Slider(
                                  value: _progress,
                                  onChanged: (value) {
                                    setState(() {
                                      _progress = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            
                            // Time
                            const Text(
                              '21:00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Speed
                            Text(
                              '1 X',
                              style: TextStyle(
                                color: AppConstants.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Fullscreen
                            SvgPicture.asset(
                              AppConstants.iconFullscreen,
                              colorFilter: const ColorFilter.mode(
                                AppConstants.textSecondary,
                                BlendMode.srcIn,
                              ),
                              width: 16,
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions & Tips
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // How to do section
                    const Text(
                      'How to do',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_howToSteps.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _howToSteps[index],
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Key tips section
                    const Text(
                      'Key tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_keyTips.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppConstants.primaryColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _keyTips[index],
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
