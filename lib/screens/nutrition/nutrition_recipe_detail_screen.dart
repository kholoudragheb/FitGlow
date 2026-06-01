import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/nutrition_styles.dart';
import 'package:fit_app/services/user_service.dart';

class NutritionRecipeDetailScreen extends StatefulWidget {
  final String mealId;

  const NutritionRecipeDetailScreen({
    super.key, 
    this.mealId = '6988b87467cb2d1a565e2972',
  });

  @override
  State<NutritionRecipeDetailScreen> createState() => _NutritionRecipeDetailScreenState();
}

class _NutritionRecipeDetailScreenState extends State<NutritionRecipeDetailScreen> {
  bool _isSaved = false;
  bool _isSaving = false;
  final UserService _userService = UserService();

  Future<void> _toggleSaveMeal() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isSaved) {
        await _userService.unsaveMeal(widget.mealId);
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal removed from saved')),
          );
        }
      } else {
        await _userService.saveMeal(widget.mealId);
        if (mounted) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal saved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
        } else if (e.toString().toLowerCase().contains('already saved') || e.toString().contains('409')) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal already saved')),
          );
        } else if (e.toString().toLowerCase().contains('not found') || e.toString().contains('404')) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal not found in saved list')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update meal status: $e')),
          );
        }
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
      backgroundColor: NutritionColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTitleSection(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                _buildMacrosSection(),
                const SizedBox(height: 24),
                _buildIngredientsSection(),
                const SizedBox(height: 24),
                _buildPreparationSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: NutritionColors.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
           icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSaved ? const Color(0xFFC7F432).withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isSaving 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : SvgPicture.asset(
                    _isSaved ? 'lib/assets/images/profile/ic_saved.svg' : 'lib/assets/icons/nutrition/icon_save.svg', 
                    colorFilter: ColorFilter.mode(
                      _isSaved ? const Color(0xFFC7F432) : Colors.white, 
                      BlendMode.srcIn
                    ),
                    width: 20,
                    height: 20,
                  ),
          ),
          onPressed: _toggleSaveMeal,
        ),
      ],
      title: const Text('Meal', style: NutritionTextStyles.subTitle),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/images/nutrition/nutrition_yogurt_1.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    NutritionColors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Center(
      child: Text(
        'Yogurt with Oats and Blueberry',
        style: NutritionTextStyles.title,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem('lib/assets/icons/nutrition/icon_timer_medium.svg', '10 min'),
        _buildVerticalDivider(),
        _buildStatItem('lib/assets/icons/nutrition/icon_fruit_bowl.svg', 'Snack'),
        _buildVerticalDivider(),
        _buildStatItem('lib/assets/icons/nutrition/icon_chef_hat.svg', 'Easy'),
      ],
    );
  }

  Widget _buildStatItem(String iconPath, String label) {
    return Column(
      children: [
        SvgPicture.asset(iconPath, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        const SizedBox(height: 4),
        Text(label, style: NutritionTextStyles.body),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: NutritionColors.textGrey,
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: NutritionTextStyles.subTitle),
        const SizedBox(height: 8),
        Text(
          'Lorem ipsum dolor sit amet consectetur. Consectetur eget egestas in elementum urna aliquam sed senectus egestas.',
          style: NutritionTextStyles.body.copyWith(color: NutritionColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildMacrosSection() {
    return Column(
      children: [
        const Text('Macros', style: NutritionTextStyles.subTitle),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMacroCard('Kcal', '500', NutritionColors.primary),
            _buildMacroCard('Protein', '5g', NutritionColors.primary),
            _buildMacroCard('Fat', '40g', NutritionColors.primary),
            _buildMacroCard('Carbs', '30g', NutritionColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, String value, Color valueColor) {
    return Container(
      width: 76, 
      height: 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NutritionColors.textGrey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: NutritionTextStyles.caption.copyWith(color: NutritionColors.textWhite)),
          Text(value, style: NutritionTextStyles.body.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutritionColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingredients', style: NutritionTextStyles.subTitle),
          const SizedBox(height: 16),
          _buildIngredientItem('Yogurt', '200g'),
          _buildIngredientItem('Strawberry', '200g'),
          _buildIngredientItem('Blueberry', '200g'),
          _buildIngredientItem('Oats', '200g'),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Show More (3 More)',
              style: NutritionTextStyles.caption.copyWith(color: NutritionColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: NutritionTextStyles.body),
              Text(amount, style: NutritionTextStyles.body.copyWith(color: NutritionColors.textGrey)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: NutritionColors.textGrey, height: 1),
        ],
      ),
    );
  }

  Widget _buildPreparationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutritionColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preparation', style: NutritionTextStyles.subTitle),
          const SizedBox(height: 16),
          _buildPreparationStep('lib/assets/icons/nutrition/icon_number_1_filled.svg', 'Lorem ipsum dolor sit amet consectetur.'),
          _buildPreparationStep('lib/assets/icons/nutrition/icon_number_2_filled.svg', 'Lorem ipsum dolor sit amet consectetur.'),
          _buildPreparationStep('lib/assets/icons/nutrition/icon_number_3_filled.svg', 'Lorem ipsum dolor sit amet consectetur.'),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Show More (3 More)',
              style: NutritionTextStyles.caption.copyWith(color: NutritionColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationStep(String iconPath, String text) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: NutritionTextStyles.body.copyWith(color: NutritionColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }
}
