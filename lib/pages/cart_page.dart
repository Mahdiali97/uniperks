import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/user_coins_service.dart';
import '../services/voucher_service.dart';
import '../widgets/floating_reward_badge.dart';

class CartPage extends StatefulWidget {
  final String username;

  const CartPage({super.key, required this.username});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<FloatingRewardBadgeOverlayState> _overlayKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FloatingRewardBadgeOverlay(
      key: _overlayKey,
      child: FutureBuilder<List<CartItem>>(
        future: CartService.getCartItems(widget.username),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartSnapshot.hasError) {
            return Center(child: Text('Error: ${cartSnapshot.error}'));
          }

          final cartItems = cartSnapshot.data ?? [];

          return FutureBuilder<Map<String, dynamic>?>(
            future: CartService.getCartVoucher(widget.username),
            builder: (context, voucherSnapshot) {
              if (voucherSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cartVoucher = voucherSnapshot.data;

              if (cartItems.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add some products to get started',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final itemsCount = cartItems.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );

              // Calculate totals (cart-level voucher applied to entire subtotal)
              final subtotal = cartItems.fold<double>(
                0,
                (sum, item) => sum + (item.totalPrice),
              );

              final voucherDiscount = cartVoucher?['voucher_discount'] as int?;
              final totalVoucherSavings =
                  voucherDiscount != null && voucherDiscount > 0
                  ? subtotal * (voucherDiscount / 100)
                  : 0.0;
              final finalTotal = subtotal - totalVoucherSavings;

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartItems[index];
                          return _buildCartItem(cartItem);
                        },
                      ),
                    ),
                  ),
                  _buildCheckoutSection(
                    subtotal,
                    finalTotal,
                    totalVoucherSavings,
                    itemsCount,
                    cartVoucher,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: cartItem.product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        cartItem.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cartItem.product.category,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  // Pricing
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RM${cartItem.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                        ],
                      ),
                      if (cartItem.product.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'RM ${cartItem.product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quantity and Remove
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (cartItem.product.id == null) return;
                                    if (cartItem.quantity > 1) {
                                      await CartService.updateQuantity(
                                        widget.username,
                                        cartItem.product.id!,
                                        cartItem.quantity - 1,
                                      );
                                    } else {
                                      await CartService.removeFromCart(
                                        widget.username,
                                        cartItem.product.id!,
                                      );
                                    }
                                    if (mounted) setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (cartItem.product.id == null) return;
                                    await CartService.updateQuantity(
                                      widget.username,
                                      cartItem.product.id!,
                                      cartItem.quantity + 1,
                                    );
                                    if (mounted) setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          if (cartItem.product.id == null) return;
                          await CartService.removeFromCart(
                            widget.username,
                            cartItem.product.id!,
                          );
                          if (mounted) setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('REMOVE'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(
    double subtotal,
    double finalTotal,
    double totalVoucherSavings,
    int itemsCount,
    Map<String, dynamic>? cartVoucher,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Applied voucher display (if any)
            if (cartVoucher != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_offer,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cartVoucher['voucher_title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cartVoucher['voucher_discount']}% off',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await CartService.removeVoucherFromCart(
                          widget.username,
                        );
                        if (mounted) setState(() {});
                      },
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _pickVoucherForCart(),
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Apply Voucher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F7FA),
                    foregroundColor: const Color(0xFF0066CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  'RM${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            if (totalVoucherSavings > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Voucher Discount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '-RM${totalVoucherSavings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total for $itemsCount item(s)',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  'RM${finalTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066CC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _proceedToCheckout(finalTotal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout(double totalPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Amount: RM${totalPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              const Text(
                'This is a demo checkout. In a real app, you would integrate with a payment gateway.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Simulate successful purchase
                final coinsEarned = (totalPrice * 0.1).round();
                await CartService.clearCart(widget.username);
                await UserCoinsService.addCoins(
                  widget.username,
                  coinsEarned,
                ); // 10% cashback in coins
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});

                // Show floating reward badge for cashback
                _overlayKey.currentState?.showRewardBadge(
                  RewardBadgeConfig(
                    icon: Icons.card_giftcard,
                    label: '🎉 Cashback!\n+$coinsEarned coins',
                    mainColor: Colors.green,
                    accentColor: Colors.lightGreen,
                    size: RewardBadgeSize.large,
                    sparkleCount: 15,
                    displayDuration: const Duration(milliseconds: 2500),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Purchase successful! You earned $coinsEarned coins!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0066CC),
              ),
              child: const Text('Complete Purchase'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickVoucherForCart() async {
    // Fetch user's active redeemed vouchers - any voucher can be used for the entire cart
    final all = await VoucherService.getActiveRedeemedVouchers(widget.username);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        if (all.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_offer, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No available vouchers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You haven\'t redeemed any vouchers yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 400,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apply Voucher to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 Terms & Conditions:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Only ONE voucher per purchase\n• Applies to entire cart\n• Discount applied to subtotal\n• Cannot combine vouchers',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: all.length,
                itemBuilder: (context, i) {
                  final rv = all[i];
                  return ListTile(
                    leading: const Icon(
                      Icons.local_offer,
                      color: Color(0xFF0066CC),
                    ),
                    title: Text(rv.voucherTitle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${rv.voucherCategory}'),
                        Text(
                          'Expires: ${rv.expiresAt.day}/${rv.expiresAt.month}/${rv.expiresAt.year}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    onTap: () async {
                      // Apply voucher to entire cart
                      await CartService.applyVoucherToCart(widget.username, rv);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Applied: ${rv.voucherTitle}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
