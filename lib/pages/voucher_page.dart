import 'package:flutter/material.dart';
import '../services/user_coins_service.dart';

class VoucherPage extends StatefulWidget {
  final String username;

  const VoucherPage({super.key, required this.username});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  List<Map<String, dynamic>> redeemedVouchers = [];

  @override
  Widget build(BuildContext context) {
    final userCoins = UserCoinsService.getCoins(widget.username);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Coins Display
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Your Coins: $userCoins',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          const TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Available Vouchers'),
              Tab(text: 'Redeemed'),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildAvailableVouchers(),
                _buildRedeemedVouchers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableVouchers() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Vouchers Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vouchers will appear here when they become available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How to earn coins:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Take quizzes to earn coins\n• Get 10% cashback on purchases\n• Check back regularly for new vouchers',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemedVouchers() {
    if (redeemedVouchers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Vouchers Redeemed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your redeemed vouchers will appear here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: redeemedVouchers.length,
      itemBuilder: (context, index) {
        final voucher = redeemedVouchers[index];
        final redemptionDate = voucher['redemptionDate'] as DateTime;
        final expiryDate = redemptionDate.add(Duration(days: voucher['validDays']));
        final isExpired = DateTime.now().isAfter(expiryDate);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Opacity(
            opacity: isExpired ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: voucher['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(voucher['category']),
                          color: voucher['color'],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher['title'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              voucher['category'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: voucher['color'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isExpired ? 'Expired' : 'Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    voucher['description'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redeemed: ${_formatDate(redemptionDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Expires: ${_formatDate(expiryDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isExpired ? Colors.red : Colors.grey[600],
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Stationery':
        return Icons.edit;
      case 'Clothing':
        return Icons.checkroom;
      case 'Food & Drink':
        return Icons.local_cafe;
      case 'Books':
        return Icons.menu_book;
      case 'Recreation':
        return Icons.fitness_center;
      default:
        return Icons.card_giftcard;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}