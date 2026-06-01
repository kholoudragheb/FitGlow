import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fit_app/providers/subscription_provider.dart';
import 'package:fit_app/services/subscription_service.dart';

class PaymentSubscriptionScreen extends StatefulWidget {
  const PaymentSubscriptionScreen({super.key});

  @override
  State<PaymentSubscriptionScreen> createState() =>
      _PaymentSubscriptionScreenState();
}

class _PaymentSubscriptionScreenState extends State<PaymentSubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  bool _isCanceling = false;

  @override
  void initState() {
    super.initState();
    // Refresh from backend whenever this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().refresh();
    });
  }

  // ─── Confirmation dialog ───────────────────────────────────────────────────

  Future<void> _showCancelConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F272D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will lose access to premium features at the end of your billing period.',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFA09D9D),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Plan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFD0FD3E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelSubscription();
    }
  }

  // ─── API call ──────────────────────────────────────────────────────────────

  Future<void> _cancelSubscription() async {
    setState(() => _isCanceling = true);

    try {
      final result = await _subscriptionService.cancelSubscription();

      if (!mounted) return;

      // Optimistically update global state
      context.read<SubscriptionProvider>().markCanceled();
      // Then verify with backend
      context.read<SubscriptionProvider>().refresh();

      setState(() => _isCanceling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty
                ? result.message
                : 'Subscription canceled successfully',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: const Color(0xFF2C7A2C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCanceling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch the global provider — rebuilds automatically on status change
    final subProvider = context.watch<SubscriptionProvider>();
    final isCanceled = subProvider.isCanceled;
    final isLoading = subProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment & Subscription',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubscriptionStatusCard(subProvider),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Billing History',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBillingHistoryList(),
                  const SizedBox(height: 32),
                  if (!isCanceled) _buildCancelButton(),
                  if (isCanceled) _buildCanceledBanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Subscription Status Card ───────────────────────────────────────────────

  Widget _buildSubscriptionStatusCard(SubscriptionProvider provider) {
    final isCanceled = provider.isCanceled;
    final statusLabel = provider.status.subscriptionStatus;
    final displayLabel = statusLabel == 'active'
        ? 'Active'
        : statusLabel == 'canceled'
            ? 'Canceled'
            : 'No Subscription';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCanceled
              ? Colors.redAccent.withValues(alpha: 0.4)
              : const Color(0xFFD0FD3E).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCanceled
                  ? Colors.redAccent.withValues(alpha: 0.15)
                  : const Color(0xFFD0FD3E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCanceled ? Icons.cancel_outlined : Icons.verified_outlined,
              color: isCanceled ? Colors.redAccent : const Color(0xFFD0FD3E),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Status',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFA09D9D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCanceled
                        ? Colors.redAccent
                        : const Color(0xFFD0FD3E),
                  ),
                ),
                if (provider.status.subscriptionId != null)
                  Text(
                    'ID: ${provider.status.subscriptionId}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFFA09D9D),
                    ),
                  ),
              ],
            ),
          ),
          // Manual refresh button
          IconButton(
            onPressed: () => context.read<SubscriptionProvider>().refresh(),
            icon: const Icon(Icons.refresh, color: Color(0xFF5C5C5C), size: 20),
            tooltip: 'Refresh status',
          ),
        ],
      ),
    );
  }

  // ── Payment Method Card ────────────────────────────────────────────────────

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A343C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'VISA',
                    style: TextStyle(
                      color: Color(0xFFD0FD3E),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visa ending in 2027',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white)),
                    Text('Expires 08/27',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFFA09D9D))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 24),
          const Row(
            children: [
              Icon(Icons.add, color: Color(0xFFD0FD3E), size: 18),
              SizedBox(width: 12),
              Text('Add new payment method',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Billing History ────────────────────────────────────────────────────────

  Widget _buildBillingHistoryList() {
    final history = [
      {'date': 'June 2025', 'desc': 'Paid on 25 June 2025', 'amount': 'EGP1000'},
      {'date': 'May 2025', 'desc': 'Paid on 16 may 2025', 'amount': 'EGP1000'},
      {'date': 'April 2025', 'desc': 'Paid on 10 April 2025', 'amount': 'EGP1000'},
      {'date': 'June 2025', 'desc': 'Paid on 21 June 2025', 'amount': 'EGP1000'},
      {'date': 'July 2025', 'desc': 'Paid on 19 July 2025', 'amount': 'EGP1000'},
      {'date': 'April 2025', 'desc': 'Paid on 5 April 2025', 'amount': 'EGP1000'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Color(0xFF2C2C2C), height: 1),
        itemBuilder: (context, index) {
          final item = history[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['date']!,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white)),
                  Text(item['desc']!,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFFA09D9D))),
                ]),
                Text(item['amount']!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Cancel Button ──────────────────────────────────────────────────────────

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCanceling ? null : _showCancelConfirmation,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isCanceling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.redAccent))
            : const Text('Cancel Subscription',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Canceled Banner ────────────────────────────────────────────────────────

  Widget _buildCanceledBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your subscription has been canceled. You will retain access until the end of your current billing period.',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.redAccent,
                  fontSize: 12,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
