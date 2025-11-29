import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class AnalyticsService {
  static final _supabase = Supabase.instance.client;

  // Get total revenue
  static Future<double> getTotalRevenue() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('total_amount')
          .eq('status', 'paid');

      double total = 0;
      for (var row in data) {
        total += (row['total_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Get Total Revenue Error: $e');
      return 0;
    }
  }

  // Get total orders count
  static Future<int> getTotalOrders() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'paid');
      return (data as List).length;
    } catch (e) {
      print('Get Total Orders Error: $e');
      return 0;
    }
  }

  // Get revenue by date (for charts)
  static Future<Map<String, double>> getRevenueByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = await _supabase
          .from('orders')
          .select('total_amount, created_at')
          .eq('status', 'paid')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);

      Map<String, double> revenueByDate = {};
      for (var row in data) {
        final date = DateTime.parse(row['created_at'] as String);
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final amount = (row['total_amount'] as num).toDouble();
        revenueByDate[dateKey] = (revenueByDate[dateKey] ?? 0) + amount;
      }
      return revenueByDate;
    } catch (e) {
      print('Get Revenue By Date Error: $e');
      return {};
    }
  }

  // Get top customers
  static Future<List<Map<String, dynamic>>> getTopCustomers({
    int limit = 5,
  }) async {
    try {
      final data = await _supabase
          .from('orders')
          .select('username, total_amount')
          .eq('status', 'paid');

      Map<String, double> customerSpending = {};
      for (var row in data) {
        final username = row['username'] as String;
        final amount = (row['total_amount'] as num).toDouble();
        customerSpending[username] = (customerSpending[username] ?? 0) + amount;
      }

      var sortedCustomers = customerSpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCustomers
          .take(limit)
          .map((e) => {'username': e.key, 'total_spent': e.value})
          .toList();
    } catch (e) {
      print('Get Top Customers Error: $e');
      return [];
    }
  }

  // Get top products
  static Future<List<Map<String, dynamic>>> getTopProducts({
    int limit = 5,
  }) async {
    try {
      final data = await _supabase
          .from('order_items')
          .select('product_name, quantity, line_total');

      Map<String, Map<String, dynamic>> productStats = {};
      for (var row in data) {
        final name = row['product_name'] as String;
        final qty = row['quantity'] as int;
        final revenue = (row['line_total'] as num).toDouble();

        if (!productStats.containsKey(name)) {
          productStats[name] = {'sold': 0, 'revenue': 0.0};
        }
        productStats[name]!['sold'] = productStats[name]!['sold'] + qty;
        productStats[name]!['revenue'] =
            productStats[name]!['revenue'] + revenue;
      }

      var sortedProducts = productStats.entries.toList()
        ..sort(
          (a, b) => (b.value['sold'] as int).compareTo(a.value['sold'] as int),
        );

      return sortedProducts
          .take(limit)
          .map(
            (e) => {
              'product_name': e.key,
              'units_sold': e.value['sold'],
              'revenue': e.value['revenue'],
            },
          )
          .toList();
    } catch (e) {
      print('Get Top Products Error: $e');
      return [];
    }
  }

  // Get orders by delivery method
  static Future<Map<String, int>> getOrdersByDeliveryMethod() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('delivery_method')
          .eq('status', 'paid');

      Map<String, int> counts = {'Self Pickup': 0, 'Delivery': 0, 'Unknown': 0};

      for (var row in data) {
        final method = row['delivery_method'] as String?;
        if (method == 'self_pickup') {
          counts['Self Pickup'] = counts['Self Pickup']! + 1;
        } else if (method == 'delivery') {
          counts['Delivery'] = counts['Delivery']! + 1;
        } else {
          counts['Unknown'] = counts['Unknown']! + 1;
        }
      }

      return counts;
    } catch (e) {
      print('Get Orders By Delivery Method Error: $e');
      return {'Self Pickup': 0, 'Delivery': 0, 'Unknown': 0};
    }
  }

  // Get recent orders
  static Future<List<Order>> getRecentOrders({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('orders')
          .select()
          .eq('status', 'paid')
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Get Recent Orders Error: $e');
      return [];
    }
  }

  // Get orders count by month (last 6 months)
  static Future<Map<String, int>> getOrdersByMonth() async {
    try {
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final data = await _supabase
          .from('orders')
          .select('created_at')
          .eq('status', 'paid')
          .gte('created_at', sixMonthsAgo.toIso8601String())
          .order('created_at', ascending: true);

      Map<String, int> ordersByMonth = {};
      for (var row in data) {
        final date = DateTime.parse(row['created_at'] as String);
        final monthKey = '${_getMonthName(date.month)} ${date.year}';
        ordersByMonth[monthKey] = (ordersByMonth[monthKey] ?? 0) + 1;
      }

      return ordersByMonth;
    } catch (e) {
      print('Get Orders By Month Error: $e');
      return {};
    }
  }

  // Get average order value
  static Future<double> getAverageOrderValue() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('total_amount')
          .eq('status', 'paid');

      if (data.isEmpty) return 0;

      double total = 0;
      for (var row in data) {
        total += (row['total_amount'] as num).toDouble();
      }
      return total / data.length;
    } catch (e) {
      print('Get Average Order Value Error: $e');
      return 0;
    }
  }

  // Helper function to get month name
  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Get voucher usage statistics
  static Future<Map<String, dynamic>> getVoucherStats() async {
    try {
      final ordersWithVouchers = await _supabase
          .from('orders')
          .select('voucher_id, discount_amount')
          .not('voucher_id', 'is', null)
          .eq('status', 'paid');

      final totalOrders = await getTotalOrders();
      final voucherUsageCount = ordersWithVouchers.length;

      double totalDiscounts = 0;
      for (var row in ordersWithVouchers) {
        totalDiscounts += (row['discount_amount'] as num).toDouble();
      }

      return {
        'voucher_usage_count': voucherUsageCount,
        'voucher_usage_percentage': totalOrders > 0
            ? (voucherUsageCount / totalOrders * 100).toStringAsFixed(1)
            : '0.0',
        'total_discounts_given': totalDiscounts,
      };
    } catch (e) {
      print('Get Voucher Stats Error: $e');
      return {
        'voucher_usage_count': 0,
        'voucher_usage_percentage': '0.0',
        'total_discounts_given': 0.0,
      };
    }
  }
}
