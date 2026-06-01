import 'package:flutter/material.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/my_client_model.dart';
import 'package:fit_app/models/pending_request_model.dart';
import 'package:fit_app/screens/coach/clients/ClientDetailsScreen.dart';
import 'package:fit_app/widgets/StartConversationModal.dart';
import 'package:intl/intl.dart';

class CoachClientsScreen extends StatefulWidget {
  const CoachClientsScreen({super.key});

  @override
  State<CoachClientsScreen> createState() => _CoachClientsScreenState();
}

class _CoachClientsScreenState extends State<CoachClientsScreen> {
  final CoachService _coachService = CoachService();
  
  String _selectedTab = 'my_clients';
  String _searchQuery = '';
  String _selectedFilter = 'All';
  
  List<MyClientModel> _myClients = [];
  List<PendingRequestModel> _pendingRequests = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clients = await _coachService.getMyClients();
      final requests = await _coachService.getPendingRequests();
      
      if (mounted) {
        setState(() {
          _myClients = clients;
          _pendingRequests = requests;
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

  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
      _errorMessage = null;
    });
  }

  List<dynamic> _getFilteredItems() {
    if (_selectedTab == 'my_clients') {
      return _myClients.where((client) {
        final matchesSearch = client.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _selectedFilter == 'All' || 
                             (client.fitnessGoal?.toLowerCase() == _selectedFilter.toLowerCase());
        return matchesSearch && matchesFilter;
      }).toList();
    } else {
      return _pendingRequests.where((req) {
        return req.client.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 16),
            if (_selectedTab == 'my_clients') _buildFilterChips(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: const Color(0xFFD0FD3E),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
                  : _errorMessage != null
                    ? _buildErrorState()
                    : _buildList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Client Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD0FD3E)),
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F272D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search clients...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Weight Loss', 'Muscle Gain', 'Beginner'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: const Color(0xFFD0FD3E),
              backgroundColor: const Color(0xFF1F272D),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1F272D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabItem('My Clients', 'my_clients'),
            _buildTabItem('Requests', 'pending_requests'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, String tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(tab),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD0FD3E) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = _getFilteredItems();
    if (items.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is MyClientModel) {
          return _buildClientCard(item);
        } else {
          return _buildRequestCard(item as PendingRequestModel);
        }
      },
    );
  }

  Widget _buildClientCard(MyClientModel client) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: client.imageUrl != null 
                  ? NetworkImage(client.imageUrl!) 
                  : const AssetImage('lib/assets/images/profile/user_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.fullName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.fitnessGoal ?? 'General Fitness',
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(client.subscriptionStatus?.toUpperCase() ?? 'ACTIVE'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Height', '${client.height ?? '-'} cm'),
              _buildMetric('Weight', '${client.weight ?? '-'} kg'),
              _buildMetric('Level', client.fitnessLevel ?? 'Beginner'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final bool? wasRemoved = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailsScreen(clientId: client.clientId),
                      ),
                    );
                    
                    if (wasRemoved == true && mounted) {
                      _fetchData(); // Refresh the list
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD0FD3E),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => StartConversationModal(
                        recipientId: client.userId.isNotEmpty ? client.userId : client.clientId,
                        recipientName: client.fullName,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(PendingRequestModel request) {
    final client = request.client;
    String initials = '';
    if (client.firstName.isNotEmpty) initials += client.firstName[0].toUpperCase();
    if (client.lastName.isNotEmpty) initials += client.lastName[0].toUpperCase();
    if (initials.isEmpty) initials = '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
                child: Text(
                  initials,
                  style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.fullName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Request sent: ${DateFormat('MMM dd').format(DateTime.parse(request.createdAt))}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, color: Colors.grey[700], size: 64),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 'my_clients' ? 'No active clients yet' : 'No pending requests',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (_selectedTab == 'my_clients')
            TextButton(
              onPressed: () => _onTabSelected('pending_requests'),
              child: const Text('View Pending Requests', style: TextStyle(color: Color(0xFFD0FD3E))),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
