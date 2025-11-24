import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/payment_service.dart';
import '../config/payment_config.dart';
import '../services/user_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Delivery method choices for the checkout flow.
enum DeliveryMethod { selfPickup, delivery }

class PaymentPage extends StatefulWidget {
  final double amount;
  final String username;
  final Function(String deliveryMethod)
  onPaymentSuccess; // Pass delivery method
  final VoidCallback onPaymentCancelled;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.username,
    required this.onPaymentSuccess,
    required this.onPaymentCancelled,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _cardFlipController;
  late AnimationController _successController;

  int _currentStep = 0;
  bool _isCardFlipped = false;
  bool _showConfetti = false;
  bool _isProcessing = false;

  // Form data
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final Color accentColor = const Color(0xFF0066CC);
  DeliveryMethod? _deliveryMethod; // null until chosen
  bool _deliveryConfirmed = false; // gates the rest of the UI
  static const LatLng _pickupCoords = LatLng(
    3.685897103310494,
    101.527674133427,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _prefillAddress();
  }

  void _showDeliveryMethodSheet() {
    if (_deliveryConfirmed || !mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Delivery Method',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DeliveryOptionCard(
                          label: 'Self Pickup',
                          icon: Icons.store_mall_directory,
                          selected:
                              _deliveryMethod == DeliveryMethod.selfPickup,
                          onTap: () => setModalState(
                            () => _deliveryMethod = DeliveryMethod.selfPickup,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DeliveryOptionCard(
                          label: 'Delivery',
                          icon: Icons.local_shipping_outlined,
                          selected: _deliveryMethod == DeliveryMethod.delivery,
                          onTap: () => setModalState(
                            () => _deliveryMethod = DeliveryMethod.delivery,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _deliveryMethod == DeliveryMethod.selfPickup
                        ? Column(
                            children: [
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 220,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      center: _pickupCoords,
                                      zoom: 15,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'uniperks',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _pickupCoords,
                                            width: 50,
                                            height: 50,
                                            child: const Icon(
                                              Icons.location_pin,
                                              size: 44,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pickup Location: ${_pickupCoords.latitude.toStringAsFixed(6)}, ${_pickupCoords.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _deliveryMethod == null
                          ? null
                          : () {
                              final goToStep =
                                  _deliveryMethod == DeliveryMethod.selfPickup
                                  ? 1
                                  : 0;
                              setState(() {
                                _deliveryConfirmed = true;
                                _currentStep = goToStep;
                              });
                              Navigator.pop(ctx);
                              // Jump to the appropriate step (skip address for self pickup)
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && _pageController.hasClients) {
                                  _pageController.jumpToPage(goToStep);
                                  _progressController.animateTo(
                                    goToStep / 2,
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                  );
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _deliveryMethod == DeliveryMethod.selfPickup
                            ? 'Confirm Self Pickup'
                            : 'Continue with Delivery',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _prefillAddress() async {
    try {
      final data = await UserService.getUserProfile(widget.username);
      if (data != null) {
        final addr = data['address_line'] as String?;
        final city = data['city'] as String?;
        final postal = data['postal_code'] as String?;
        if (addr != null &&
            addr.isNotEmpty &&
            _addressController.text.isEmpty) {
          _addressController.text = addr;
        }
        if (city != null && city.isNotEmpty && _cityController.text.isEmpty) {
          _cityController.text = city;
        }
        if (postal != null &&
            postal.isNotEmpty &&
            _zipController.text.isEmpty) {
          _zipController.text = postal;
        }
        setState(() {});
      }
    } catch (e) {
      // Silent failure; address optional
      debugPrint('Prefill address failed: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _cardFlipController.dispose();
    _successController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // Format card number (####-####-####-####)
  String _formatCardNumber(String value) {
    // Remove all non-digits and spaces
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    // Limit to 16 digits (standard card length)
    if (value.length > 16) value = value.substring(0, 16);

    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  // Format expiry date (MM/YY)
  String _formatExpiryDate(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(
        _currentStep / 2,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Process payment via Stripe PaymentSheet
      setState(() => _isProcessing = true);
      try {
        final ok = await PaymentService.payWithPaymentSheet(
          amount: widget.amount,
          currency: PaymentConfig.currency,
          username: widget.username,
          description: 'UniPerks purchase by ${widget.username}',
        );

        if (!mounted) return;

        if (ok) {
          setState(() {
            _isProcessing = false;
            _showConfetti = true;
          });
          _successController.forward();

          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            final deliveryMethodStr =
                _deliveryMethod == DeliveryMethod.selfPickup
                ? 'self_pickup'
                : 'delivery';
            widget.onPaymentSuccess(deliveryMethodStr);
          }
        } else {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    }
  }

  void _previousStep() {
    // If self pickup is selected and we are at the first actionable step (payment),
    // don't navigate back to the address step. Optionally, re-open delivery selection.
    if (_deliveryMethod == DeliveryMethod.selfPickup && _currentStep == 1) {
      setState(() => _deliveryConfirmed = false);
      _showDeliveryMethodSheet();
      return;
    }
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(
        _currentStep / 2,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _flipCard() {
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
    if (_isCardFlipped) {
      _cardFlipController.forward();
    } else {
      _cardFlipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and progress
                _buildHeader(),
                // Step indicator (hidden until delivery method confirmed)
                if (_deliveryConfirmed) _buildStepIndicator(),

                // Page view gated behind delivery confirmation
                Expanded(
                  child: _deliveryConfirmed
                      ? PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildAddressStep(),
                            _buildPaymentStep(),
                            _buildConfirmationStep(),
                          ],
                        )
                      : _buildDeliveryPendingPlaceholder(),
                ),

                // Bottom action buttons (hidden until confirmed)
                if (_deliveryConfirmed) _buildBottomActions(),
              ],
            ),
          ),

          // Confetti overlay
          if (_showConfetti)
            ConfettiOverlay(
              colors: const [
                Color(0xFF0066CC),
                Color(0xFF4CAF50),
                Color(0xFF4ECDC4),
                Color(0xFFFFA726),
                Color(0xFF7C4DFF),
              ],
              controller: _successController,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          if (_currentStep > 0 && !_showConfetti)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: GestureDetector(
                    onTap: _previousStep,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                );
              },
            )
          else
            GestureDetector(
              onTap: widget.onPaymentCancelled,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStepTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _showConfetti
                      ? 'Payment Complete!'
                      : _deliveryConfirmed
                      ? 'Step ${_currentStep + 1} of 3'
                      : 'Select delivery method to begin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    if (_showConfetti) return 'Success!';
    if (!_deliveryConfirmed) return 'Select Delivery Method';
    switch (_currentStep) {
      case 0:
        return 'Delivery Address';
      case 1:
        return 'Payment Method';
      case 2:
        return 'Review Order';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      double progress = 0.0;
                      if (index < _currentStep) {
                        progress = 1.0;
                      } else if (index == _currentStep) {
                        progress = 0.0;
                      }

                      return Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: progress > 0.5
                              ? accentColor
                              : Colors.grey[300],
                        ),
                      );
                    },
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTextField(
            controller: _addressController,
            label: 'Street Address',
            icon: Icons.home_outlined,
            delay: 100,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildAnimatedTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                  delay: 200,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _zipController,
                  label: 'ZIP',
                  icon: Icons.pin_outlined,
                  delay: 300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.info_outline,
            title: 'Free Delivery',
            subtitle: 'Estimated delivery: 2-3 business days',
            delay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Animated Credit Card
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _cardFlipController,
              builder: (context, child) {
                final angle = _cardFlipController.value * math.pi;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: angle < math.pi / 2
                      ? _buildCreditCardFront()
                      : Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _buildCreditCardBack(),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildAnimatedTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            icon: Icons.credit_card,
            delay: 100,
            keyboardType: TextInputType.number,
            maxLength: 19, // 16 digits + 3 spaces
            onChanged: (value) {
              final formatted = _formatCardNumber(value);
              if (formatted != value) {
                _cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
              setState(() {}); // Update card display
            },
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _cardNameController,
            label: 'Cardholder Name',
            icon: Icons.person_outline,
            delay: 200,
            onChanged: (value) => setState(() {}), // Update card display
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: _expiryController,
                  label: 'Expiry (MM/YY)',
                  icon: Icons.calendar_today,
                  delay: 300,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final formatted = _formatExpiryDate(value);
                    _expiryController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                    setState(() {}); // Update card display
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isCardFlipped) _flipCard();
                  },
                  child: _buildAnimatedTextField(
                    controller: _cvvController,
                    label: 'CVV',
                    icon: Icons.lock_outline,
                    delay: 400,
                    keyboardType: TextInputType.number,
                    obscureText: !_isCardFlipped,
                    maxLength: 4,
                    onChanged: (value) =>
                        setState(() {}), // Update card display
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardFront() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor, accentColor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Icon(Icons.contactless, color: Colors.white, size: 32),
            ],
          ),
          const Spacer(),
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cardNameController.text.isEmpty
                        ? 'YOUR NAME'
                        : _cardNameController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryController.text.isEmpty
                        ? 'MM/YY'
                        : _expiryController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardBack() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacity(0.7), accentColor],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(height: 45, color: Colors.black.withOpacity(0.6)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _cvvController.text.isEmpty ? '•••' : _cvvController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildSummaryCard(
            title: _deliveryMethod == DeliveryMethod.selfPickup
                ? 'Pickup Location'
                : 'Delivery Address',
            icon: _deliveryMethod == DeliveryMethod.selfPickup
                ? Icons.store_mall_directory
                : Icons.location_on,
            content: _deliveryMethod == DeliveryMethod.selfPickup
                ? 'Self Pickup at coordinates:\n${_pickupCoords.latitude.toStringAsFixed(6)}, ${_pickupCoords.longitude.toStringAsFixed(6)}'
                : (_addressController.text.isEmpty &&
                          _cityController.text.isEmpty
                      ? 'Standard Delivery\n${widget.username}'
                      : '${_addressController.text}\n${_cityController.text}${_zipController.text.isNotEmpty ? ", ${_zipController.text}" : ""}'),
            delay: 100,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Payment Method',
            icon: Icons.credit_card,
            content: _cardNumberController.text.isEmpty
                ? 'Card Payment'
                : () {
                    final digits = _cardNumberController.text.replaceAll(
                      ' ',
                      '',
                    );
                    return digits.length >= 4
                        ? '•••• •••• •••• ${digits.substring(digits.length - 4)}'
                        : 'Card Payment';
                  }(),
            delay: 200,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: 'Order Summary',
            icon: Icons.shopping_bag,
            content: 'Total Amount: RM${widget.amount.toStringAsFixed(2)}',
            delay: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                maxLength: maxLength,
                onChanged: onChanged,
                inputFormatters: keyboardType == TextInputType.number
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3142),
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(icon, color: accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  counterText: '',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required String content,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showConfetti ? _buildSuccessButton() : _buildContinueButton(),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _nextStep,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _currentStep == 2
                      ? 'Pay RM${widget.amount.toStringAsFixed(2)}'
                      : 'Continue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessButton() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_successController.value * 0.05),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 28 + (_successController.value * 4),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Placeholder content displayed before delivery method confirmation.
  Widget _buildDeliveryPendingPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delivery_dining, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Choose self pickup or delivery to begin checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showDeliveryMethodSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Select Delivery Method'),
          ),
        ],
      ),
    );
  }
}

/// Card used in the delivery method bottom sheet.
class _DeliveryOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryOptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF0066CC).withOpacity(0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF0066CC) : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: selected ? const Color(0xFF0066CC) : Colors.grey[700],
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF0066CC)
                        : const Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎊 Confetti Overlay Widget
class ConfettiOverlay extends StatelessWidget {
  final List<Color> colors;
  final AnimationController controller;

  const ConfettiOverlay({
    super.key,
    required this.colors,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              progress: controller.value,
              colors: colors,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// 🎨 Custom Painter for Confetti Animation
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.progress, required this.colors})
    : particles = List.generate(
        60,
        (index) => ConfettiParticle(
          color: colors[index % colors.length],
          index: index,
        ),
      );

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.paint(canvas, size, progress);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

/// 🎉 Individual Confetti Particle
class ConfettiParticle {
  final Color color;
  final int index;
  late final double startX;
  late final double velocityX;
  late final double velocityY;
  late final double rotation;
  late final double size;

  ConfettiParticle({required this.color, required this.index}) {
    final random = math.Random(index);
    startX = random.nextDouble();
    velocityX = (random.nextDouble() - 0.5) * 2;
    velocityY = random.nextDouble() * 2 + 1;
    rotation = random.nextDouble() * math.pi * 2;
    size = random.nextDouble() * 8 + 4;
  }

  void paint(Canvas canvas, Size size, double progress) {
    final x = size.width * startX + (velocityX * 100 * progress);
    final y = -20 + (velocityY * size.height * progress);

    final paint = Paint()
      ..color = color.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation + (progress * math.pi * 4));

    // Draw confetti shape (rectangle or circle)
    if (index % 3 == 0) {
      canvas.drawCircle(Offset.zero, this.size / 2, paint);
    } else {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: this.size,
          height: this.size * 1.5,
        ),
        paint,
      );
    }

    canvas.restore();
  }
}
