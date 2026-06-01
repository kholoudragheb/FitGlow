import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/store/checkout_cubit.dart';
import '../../../logic/cubits/store/cart_cubit.dart';
import '../../../models/order_model.dart';
import '../../../models/cart_model.dart';
import '../../../services/store_service.dart';
import 'OrderSuccessScreen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckoutCubit(StoreService()),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 0,
          title: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              // Clear cart globally after success
              context.read<CartCubit>().fetchCart(); 
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderSuccessScreen(order: state.order)),
              );
            } else if (state is CheckoutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Shipping Address"),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, "Full Name", Icons.person_outline),
                  _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  _buildTextField(_streetController, "Street Address", Icons.location_on_outlined),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_cityController, "City", null)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_stateController, "State", null)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_zipController, "Zip Code", null, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_countryController, "Country", null)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Order Summary"),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData? icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: (val) => (val == null || val.isEmpty) ? "Field required" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Items Count", "${widget.cart.items.length}"),
          const SizedBox(height: 12),
          _buildSummaryRow("Total Price", "${widget.cart.totalPrice} EGP", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.white38, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: isTotal ? const Color(0xFFD0FD3E) : Colors.white, fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomActions() {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        final bool isLoading = state is CheckoutLoading;
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _onPlaceOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0FD3E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        );
      },
    );
  }

  void _onPlaceOrder(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final address = ShippingAddressModel(
        name: _nameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        country: _countryController.text,
        phone: _phoneController.text,
      );
      context.read<CheckoutCubit>().processCheckout(address);
    }
  }
}
