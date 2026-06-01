import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fit_app/screens/coach/clients/CoachClientsScreen.dart';
import 'package:fit_app/screens/coach/chats/ChatsScreen.dart';
import 'package:fit_app/screens/coach/profile/CoachProfileScreen.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/user_model.dart';
import 'package:fit_app/models/pending_request_model.dart';
import 'package:fit_app/models/my_client_model.dart';
import 'package:fit_app/models/coach_stats_model.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/screens/coach/requests/PendingRequestsScreen.dart';
import 'package:fit_app/screens/coach/clients/ClientDetailsScreen.dart';
import 'package:fit_app/services/schedule_service.dart';
import 'package:fit_app/models/session_model.dart';
import 'package:fit_app/screens/coach/schedule/SessionDetailsScreen.dart';
import 'package:fit_app/screens/coach/schedule/CoachCalendarScreen.dart';
import 'package:fit_app/screens/coach/schedule/ScheduleAnalyticsScreen.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _CoachHomeContent(), // Extracted original content
    const CoachClientsScreen(),
    const ChatsScreen(), // Chats screen
    const CoachProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        height: 56, // Fixed height from Figma
        color: const Color(0xFF181818),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: _buildNavItem(
                Icons.home_filled,
                'Home',
                _selectedIndex == 0,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: _buildNavItem(
                Icons.people,
                'Clients',
                _selectedIndex == 1,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: _buildNavItem(
                Icons.chat_bubble_outline,
                'Chat',
                _selectedIndex == 2,
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(3),
              child: _buildNavItem(
                Icons.person_outline,
                'Profile',
                _selectedIndex == 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFFF0F0F0),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFD0FD3E)
                : const Color(0xFFF0F0F0),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CoachHomeContent extends StatefulWidget {
  const _CoachHomeContent();

  @override
  State<_CoachHomeContent> createState() => _CoachHomeContentState();
}

class _CoachHomeContentState extends State<_CoachHomeContent> {
  UserModel? _userProfile;
  List<PendingRequestModel> _pendingRequests = [];
  List<MyClientModel> _myClients = [];
  CoachStatsModel? _stats;
  List<SessionModel> _upcomingSessions = [];
  bool _isLoading = true;
  bool _isRequestsLoading = true;
  bool _isClientsLoading = true;
  bool _isStatsLoading = true;
  bool _isSessionsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchPendingRequests();
    _fetchMyClients();
    _fetchStats();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      final scheduleService = ScheduleService();
      final sessions = await scheduleService.getMySessions();
      if (mounted) {
        setState(() {
          // Filter for scheduled/confirmed sessions and sort by date
          _upcomingSessions = sessions.where((s) => 
            s.status.toLowerCase() == 'scheduled' || 
            s.status.toLowerCase() == 'confirmed' ||
            s.status.toLowerCase() == 'pending'
          ).toList();
          
          _upcomingSessions.sort((a, b) {
            final dateA = DateTime.tryParse(a.scheduledDate) ?? DateTime(1970);
            final dateB = DateTime.tryParse(b.scheduledDate) ?? DateTime(1970);
            return dateA.compareTo(dateB);
          });
          
          _isSessionsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching upcoming sessions: $e');
      if (mounted) {
        setState(() {
          _isSessionsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchStats() async {
    try {
      final coachService = CoachService();
      final stats = await coachService.getCoachStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching coach stats: $e');
      if (mounted) {
        setState(() {
          _isStatsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMyClients() async {
    try {
      final coachService = CoachService();
      final clients = await coachService.getMyClients();
      if (mounted) {
        setState(() {
          _myClients = clients;
          _isClientsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching my clients: $e');
      if (mounted) {
        setState(() {
          _isClientsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final coachService = CoachService();
      final requests = await coachService.getPendingRequests();
      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isRequestsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      if (mounted) {
        setState(() {
          _isRequestsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final userService = UserService();
      final profile = await userService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage(
                          'lib/assets/images/coaches/9e03314b6be949db4da5ca3cd5c60d680034189d.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isLoading ? 'Good morning...' : 'Good morning, ${_userProfile?.firstName ?? 'Coach'}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/coach-notifications');
                },
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0FD3E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Pending Requests Badge/Card
        if (!_isRequestsLoading && _pendingRequests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PendingRequestsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD0FD3E), Color(0xFF9EBF2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD0FD3E).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.black, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Client Requests',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'You have ${_pendingRequests.length} pending requests to review',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                  ],
                ),
              ),
            ),
          ),

        // Content ScrollView
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Date Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFD0FD3E),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM').format(DateTime.now()),
                            style: const TextStyle(
                              color: Color(0xFFF0F0F0),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A343C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CoachCalendarScreen()),
                              ),
                              child: _buildToggleOption('Month', false),
                            ),
                            _buildToggleOption('Week', true),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Calendar Strip
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        final today = DateTime.now();
                        final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
                        final dayDate = firstDayOfWeek.add(Duration(days: index));
                        final isSelected = dayDate.day == today.day && 
                                          dayDate.month == today.month && 
                                          dayDate.year == today.year;
                        
                        return _buildCalendarDay(
                          DateFormat('E').format(dayDate).substring(0, 2),
                          dayDate.day.toString(),
                          isSelected,
                          isGrey: dayDate.isBefore(DateTime(today.year, today.month, today.day)),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Upcoming Training Horizontal List
                  const Text(
                    'Upcoming Training',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: _isSessionsLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
                      : _upcomingSessions.isEmpty 
                        ? const Center(child: Text('No upcoming sessions', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _upcomingSessions.length,
                            itemBuilder: (context, index) {
                              final session = _upcomingSessions[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => SessionDetailsScreen(sessionId: session.id))
                                  );
                                  if (mounted) _fetchSessions();
                                },
                                child: _buildTrainingCard(
                                  session.title ?? 'Training Session',
                                  session.clientName ?? 'Client',
                                  session.startTime,
                                  session.sessionType,
                                  'lib/assets/images/profile/user_avatar.png',
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 24),
                  // My Clients Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My clients (${_myClients.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Clients tab in the parent CoachHomeScreen
                          // Since _CoachHomeContent is a child of CoachHomeScreen, we can't easily change the index here
                          // unless we pass a callback or use a more robust state management.
                          // For now, we'll just show the list.
                        },
                        child: const Text('See all', style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isClientsLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
                  else if (_myClients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No active clients yet', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ..._myClients.take(3).map((client) => GestureDetector(
                          onTap: () async {
                            final bool? wasRemoved = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientDetailsScreen(clientId: client.clientId),
                              ),
                            );
                            if (wasRemoved == true && mounted) {
                              _fetchMyClients();
                              _fetchStats();
                            }
                          },
                          child: _buildClientItem(
                            client.fullName,
                            'Recently active',
                            '${((client.weight ?? 0) / (client.height ?? 1) * 10).toStringAsFixed(0)}%', // Mock progress
                            (client.weight ?? 0) / 100, // Mock progress value
                            client.imageUrl ?? 'lib/assets/images/profile/user_avatar.png',
                          ),
                        )),

                  const SizedBox(height: 24),
                  // Weekly Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScheduleAnalyticsScreen()),
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isStatsLoading)
                    _buildStatsSkeleton()
                  else if (_stats == null)
                    const Center(child: Text('Failed to load stats', style: TextStyle(color: Colors.redAccent)))
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Clients',
                                '${_stats!.totalClients}',
                                Icons.people_alt_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Pending',
                                '${_stats!.pendingRequests}',
                                Icons.hourglass_empty,
                                isPending: _stats!.pendingRequests > 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Active This Week',
                                '${_stats!.activeClientsThisWeek}',
                                Icons.bolt,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Activity Rate',
                                '${_stats!.activityPercentage.toInt()}%',
                                Icons.analytics_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          'Average Progress',
                          '${_stats!.averageProgress.toInt()}%',
                          Icons.trending_up,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildToggleOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD0FD3E) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _buildCalendarDay(
    String day,
    String date,
    bool isSelected, {
    bool isGrey = false,
  }) {
    return Container(
      width: 49,
      height: 70, // Slightly taller container
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD0FD3E) : Colors.transparent,
        border: Border.all(color: const Color(0xFF2F2E2E)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0C0C0C)
                  : const Color(0xFFD0FD3E),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0C0C0C)
                  : (isGrey
                        ? const Color(0xFFB4AAAA)
                        : const Color(0xFFD0FD3E)),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTrainingCard(
    String title,
    String name,
    String time,
    String location,
    String imagePath,
  ) {
    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 66,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF0F0F0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD0FD3E)),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFFF0F0F0),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildClientItem(
    String name,
    String time,
    String progressText,
    double progress,
    String imagePath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text(
                            'Latest activity',
                            style: TextStyle(
                              color: Color(0xFF918C8C),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              time,
                              style: const TextStyle(
                                color: Color(0xFFD0FD3E),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            color: Color(0xFF918C8C),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          progressText,
                          style: const TextStyle(
                            color: Color(0xFFD0FD3E),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF79797B),
                  color: const Color(0xFFD0FD3E),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isPending = false, bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? const Color(0xFFD0FD3E).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              icon, 
              color: isPending ? const Color(0xFFD0FD3E) : Colors.white24, 
              size: 20
            ),
          ),
          if (isPending)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFD0FD3E), borderRadius: BorderRadius.circular(4)),
                child: const Text('NEW', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
