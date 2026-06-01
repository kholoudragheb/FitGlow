import 'package:fit_app/core/constants.dart';
import 'package:fit_app/screens/coach_details_screen.dart';
import 'package:flutter/material.dart';
import '../models/coach_model.dart';
import '../services/coach_service.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CoachService _coachService = CoachService();
  
  List<Coach> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch all coaches to bypass the Koyeb server search regex bug
      final allCoaches = await _coachService.getCoaches();
      final filtered = allCoaches.where((c) {
        final fullName = "${c.firstName} ${c.lastName}".toLowerCase();
        final matchesName = fullName.contains(query.toLowerCase());
        final matchesSpec = c.specialties.any((s) => s.toLowerCase().contains(query.toLowerCase()));
        return matchesName || matchesSpec;
      }).toList();

      setState(() {
        _results = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Search Bar
            Padding(
              padding: AppConstants.defaultPadding,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search coaches...",
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: AppConstants.surfaceColor,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _searchController.text.isEmpty 
                  ? _buildEmptyState() 
                  : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Type to search for coaches...",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          "No coaches found matching your search.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final coach = _results[index];
        return _buildCoachResultItem(coach);
      },
    );
  }

  Widget _buildCoachResultItem(Coach coach) {
    final name = "${coach.firstName} ${coach.lastName}".trim();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailsScreen(coachId: coach.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[800],
              backgroundImage: (coach.avatarUrl != null && coach.avatarUrl!.isNotEmpty)
                  ? NetworkImage(coach.avatarUrl!)
                  : const AssetImage('lib/assets/images/profile/user_avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    coach.specialties.isNotEmpty ? coach.specialties.first : "Coach",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}
