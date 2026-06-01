import 'package:flutter/material.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/my_coach_model.dart';
import 'package:fit_app/screens/coach_details_screen.dart';
import 'package:fit_app/screens/coach/chats/ChatDetailScreen.dart';
import 'package:fit_app/screens/coaches_list_screen.dart';
import 'package:fit_app/services/chat_service.dart';
import 'package:fit_app/logic/cubits/chat/start_conversation_cubit.dart';
import 'package:fit_app/models/conversation_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/utils/image_utils.dart';

class MyCoachScreen extends StatefulWidget {
  const MyCoachScreen({super.key});

  @override
  State<MyCoachScreen> createState() => _MyCoachScreenState();
}

class _MyCoachScreenState extends State<MyCoachScreen> {
  final CoachService _coachService = CoachService();
  MyCoachModel? _myCoach;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyCoach();
  }

  Future<void> _fetchMyCoach() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coach = await _coachService.getMyCoach();
      if (mounted) {
        setState(() {
          _myCoach = coach;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Coach',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyCoach,
        color: StoreColors.primary,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _myCoach == null
                    ? _buildEmptyState()
                    : _buildCoachDetails(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: StoreColors.primary),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchMyCoach,
              style: ElevatedButton.styleFrom(backgroundColor: StoreColors.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No coach assigned yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have an assigned coach. Browse our elite trainers to find the perfect match for your goals!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoachesListScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StoreColors.primary,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Browse Coaches',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachDetails() {
    final coach = _myCoach!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: StoreColors.primary, width: 2),
                        image: ImageUtils.coachDecorationImage(
                          url: coach.imageUrl,
                          coachId: coach.id,
                        ),
                      ),
                    ),
                    if (coach.isVerified)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: StoreColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.black, size: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  coach.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      coach.averageRating.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ' (${coach.totalReviews} reviews)',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Experience', '${coach.experienceYears} Years'),
                    Container(width: 1, height: 30, color: Colors.white10),
                    _buildStatItem('Clients', 'Active'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'About Coach',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          Text(
            coach.bio ?? 'No bio provided.',
            style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Specialties',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coach.specialties.map((s) => _buildChip(s)).toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Certifications',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          ...coach.certifications.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: StoreColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(c, style: TextStyle(color: Colors.grey[300], fontSize: 14))),
              ],
            ),
          )),
          
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoachDetailsScreen(coachId: coach.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Full Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocProvider(
                  create: (context) => StartConversationCubit(ChatService()),
                  child: BlocConsumer<StartConversationCubit, StartConversationState>(
                    listener: (context, state) {
                      if (state is StartConversationSuccess) {
                        final otherUser = ParticipantModel(
                          id: coach.userId,
                          firstName: coach.firstName ?? '',
                          lastName: coach.lastName ?? '',
                          profileImage: coach.imageUrl,
                          role: 'Coach',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              conversationId: state.conversation.id,
                              otherUser: otherUser,
                            ),
                          ),
                        );
                      } else if (state is StartConversationError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
                        );
                      }
                    },
                    builder: (context, state) {
                      final bool isStarting = state is StartConversationLoading;
                      return ElevatedButton(
                        onPressed: isStarting
                            ? null
                            : () async {
                                // First check if conversation already exists to avoid 409
                                try {
                                  final chatService = ChatService();
                                  final conversations = await chatService.getConversations();
                                  final existing = conversations.firstWhere(
                                    (c) => c.participants.any((p) => p.id == coach.userId || p.id == coach.id),
                                  );
                                  
                                  if (!context.mounted) return;
                                  
                                  final otherUser = ParticipantModel(
                                    id: coach.userId,
                                    firstName: coach.firstName ?? '',
                                    lastName: coach.lastName ?? '',
                                    profileImage: coach.imageUrl,
                                    role: 'Coach',
                                  );
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailScreen(
                                        conversationId: existing.id,
                                        otherUser: otherUser,
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  // If not found, start a new one
                                  if (!context.mounted) return;
                                  context.read<StartConversationCubit>().startNewConversation(
                                    recipientId: coach.userId,
                                    initialMessage: "Hi Coach! I'm ready to start my journey.",
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoreColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isStarting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Chat with Coach', style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: StoreColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: StoreColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StoreColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: StoreColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
