import 'package:flutter/material.dart';
import 'package:uniperks/auth/login_page.dart';
import 'package:uniperks/services/authz_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniperks/services/user_service.dart';
import 'package:uniperks/pages/admin_product_upload_page.dart';
import 'package:uniperks/services/quiz_service.dart';
import 'package:uniperks/services/product_service.dart';
import 'package:uniperks/services/voucher_service.dart';
import 'package:uniperks/models/product.dart';
import 'package:uniperks/models/voucher.dart';
import 'package:uniperks/models/quiz_question.dart';
import 'package:uniperks/models/quiz_module.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  String selectedQuizModule = 'general_knowledge';
  List<Map<String, dynamic>> registeredUsers = [];
  bool isLoading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _tabController = TabController(length: 5, vsync: this);
  }

  Future<void> _loadUsers() async {
    try {
      final users = await UserService.getAllUsers();
      // Filter out admin users (exclude users where role is 'admin')
      final nonAdminUsers = users.where((user) {
        final role = user['role'] as String?;
        return role != 'admin';
      }).toList();

      setState(() {
        registeredUsers = nonAdminUsers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) {
    // Also sign out Supabase session if any (admin auth)
    try {
      Supabase.instance.client.auth.signOut();
    } catch (_) {}
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supa = Supabase.instance.client;
    final isAdminAuthed = supa.auth.currentUser != null;

    // If not authenticated with Supabase, show simplified gate
    if (!isAdminAuthed) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: const Color(0xFF0066CC),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Admin sign-in required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in with your admin email and password on the login page.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => _logout(context),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<bool>(
      future: AuthzService.currentUserIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: const Text('Admin – Not authorized')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your account is not authorized as admin.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please contact the owner to grant admin role in the users table or sign in with a different account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          Supabase.instance.client.auth.signOut();
                        } catch (_) {}
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo/UniPerks.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF0066CC),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _logout(context),
                tooltip: 'Logout',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.people), text: 'Users'),
                Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
                Tab(icon: Icon(Icons.inventory), text: 'Products'),
                Tab(icon: Icon(Icons.card_giftcard), text: 'Vouchers'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildUsersTab(),
              _buildQuizTab(),
              _buildProductsTab(),
              _buildVouchersTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<List<Product>>(
      future: ProductService.getAllProducts(),
      builder: (context, snapshot) {
        final totalProducts = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Manage your UniPerks system'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'System Statistics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      '${registeredUsers.length}',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Products',
                      '${totalProducts.length}',
                      Icons.inventory,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📚 Quiz Management',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage quiz modules, add/edit/delete questions, and track question statistics.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Go to the "Quiz Management" tab to manage questions.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    // Use state variable loaded in initState
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registered Users (${registeredUsers.length})',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          registeredUsers.isEmpty
              ? SizedBox(
                  height: 200,
                  child: const Center(
                    child: Text(
                      'No users registered yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true, // Allow ListView to size itself
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable ListView scrolling since parent is scrollable
                  itemCount: registeredUsers.length,
                  itemBuilder: (context, index) {
                    final user = registeredUsers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user['username']!),
                        subtitle: Text(user['email']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteUser(user['username']!, index),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        QuizService.getQuizModules(),
        QuizService.getAllQuestions(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final modules = snapshot.data![0] as List<QuizModule>;
        final allQuestions = snapshot.data![1] as List<QuizQuestion>;

        // If no module selected or module doesn't exist, select first available
        if (modules.isNotEmpty) {
          final moduleExists = modules.any((m) => m.id == selectedQuizModule);
          if (!moduleExists) {
            selectedQuizModule = modules.first.id;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quiz Management',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddQuestionDialog(modules),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Module Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: modules.map((module) {
                    final isSelected = module.id == selectedQuizModule;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              module.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(module.title),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedQuizModule = module.id;
                          });
                        },
                        selectedColor: Colors.deepPurple.withOpacity(0.3),
                        checkmarkColor: Colors.deepPurple,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Questions List
              _buildQuestionsList(modules, allQuestions),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionsList(
    List<QuizModule> modules,
    List<QuizQuestion> allQuestions,
  ) {
    // Filter questions for selected module
    final questions = allQuestions
        .where((q) => q.moduleId == selectedQuizModule)
        .toList();
    final selectedModule = modules.firstWhere(
      (m) => m.id == selectedQuizModule,
      orElse: () => modules.first,
    );

    if (questions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(selectedModule.icon, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'No questions in ${selectedModule.title}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text('Add some questions to get started'),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Card(
          child: ExpansionTile(
            title: Text(
              question.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(' ${question.difficultyName}'),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: Colors.amber,
                  ),
                  Text(' ${question.coins} coins'),
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  Text(' Answer: ${question.answers[question.correctAnswer]}'),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditQuestionDialog(question, modules),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(question.id),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Answer Options:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(question.answers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Row(
                          children: [
                            Icon(
                              i == question.correctAnswer
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: i == question.correctAnswer
                                  ? Colors.green
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${String.fromCharCode(65 + i)}. ${question.answers[i]}',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return FutureBuilder<List<Product>>(
      future: ProductService.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Products (${products.length})',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openProductForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              products.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Add some products to get started'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: product.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        'RM ${product.price.toStringAsFixed(2)}',
                                      ),
                                      if (product.discount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${product.discount}% OFF',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(product.category),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _openProductForm(product: product),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProduct(product),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVouchersTab() {
    return FutureBuilder<List<Voucher>>(
      future: VoucherService.getAllVouchers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final vouchers = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vouchers (${vouchers.length})',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVoucherDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Voucher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              vouchers.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No vouchers yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Add some vouchers to get started'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        return _buildVoucherCard(voucher, index);
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard(Voucher voucher, int index) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0066CC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.card_giftcard, color: Color(0xFF0066CC)),
        ),
        title: Text(voucher.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              voucher.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text('${voucher.discount}% OFF'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text('${voucher.coinsRequired} coins'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                if (voucher.maxClaims != null)
                  FutureBuilder<int>(
                    future: VoucherService.getRedemptionCount(voucher.id),
                    builder: (context, snap) {
                      final claimed = snap.data ?? 0;
                      final remaining = (voucher.maxClaims! - claimed).clamp(
                        0,
                        voucher.maxClaims!,
                      );
                      return Chip(
                        label: Text(
                          'Remaining: $remaining / ${voucher.maxClaims}',
                        ),
                      );
                    },
                  ),
                Chip(
                  label: Text(
                    voucher.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: voucher.active ? Colors.green : Colors.red,
                    ),
                  ),
                  backgroundColor: voucher.active
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                voucher.active ? Icons.check_circle : Icons.cancel,
                color: voucher.active ? Colors.green : Colors.grey,
              ),
              onPressed: () async {
                await VoucherService.toggleVoucherActive(
                  voucher.id,
                  voucher.active,
                );
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditVoucherDialog(voucher),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteVoucher(voucher),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // Dialog methods remain the same as they were already properly handled
  void _showAddQuestionDialog(List modules) {
    _showQuestionDialog(modules: modules);
  }

  void _showEditQuestionDialog(QuizQuestion question, List modules) {
    _showQuestionDialog(modules: modules, question: question);
  }

  void _showQuestionDialog({required List modules, QuizQuestion? question}) {
    final isEditing = question != null;
    final questionController = TextEditingController(
      text: question?.question ?? '',
    );
    int difficulty = question?.difficulty ?? 1; // 1=Easy, 2=Medium, 3=Hard
    final List<TextEditingController> answerControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < (question?.answers.length ?? 0) ? question!.answers[i] : '',
      ),
    );
    int correctAnswer = question?.correctAnswer ?? 0;
    String currentModule = question?.moduleId ?? selectedQuizModule;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Question' : 'Add New Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Module Selection
                    DropdownButtonFormField<String>(
                      value: currentModule,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Module',
                        border: OutlineInputBorder(),
                      ),
                      items: modules
                          .map<DropdownMenuItem<String>>(
                            (module) => DropdownMenuItem<String>(
                              value: module.id,
                              child: Row(
                                children: [
                                  Text(
                                    module.icon,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(module.title),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? null
                          : (value) {
                              setDialogState(() {
                                currentModule = value!;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: questionController,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Difficulty Selector
                    DropdownButtonFormField<int>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Easy (1 coin)'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Medium (1 coin)'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Hard (2 coins)'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          difficulty = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Answer Options:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: correctAnswer,
                              onChanged: (val) {
                                setDialogState(() {
                                  correctAnswer = val!;
                                });
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: answerControllers[i],
                                decoration: InputDecoration(
                                  labelText:
                                      'Answer ${String.fromCharCode(65 + i)}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Basic validation
                    if (questionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter the question text'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final answers = answerControllers
                        .map((c) => c.text.trim())
                        .toList();
                    if (answers.any((a) => a.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill in all answer options A–D',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (correctAnswer < 0 || correctAnswer >= answers.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select the correct answer'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newQuestion = QuizQuestion(
                      id: question?.id ?? 0, // DB will set if adding
                      moduleId: currentModule,
                      question: questionController.text.trim(),
                      answers: answers,
                      correctAnswer: correctAnswer,
                      difficulty: difficulty,
                    );

                    bool success;
                    if (isEditing) {
                      success = await QuizService.updateQuestion(
                        question.id,
                        newQuestion,
                      );
                    } else {
                      success = await QuizService.addQuestion(newQuestion);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      if (success) {
                        setState(() {}); // Refresh the list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save question'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteUser(String username, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete $username?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await UserService.removeUser(username);
                await _loadUsers();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion(int questionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await QuizService.deleteQuestion(questionId);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    setState(() {}); // Refresh the list
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete question'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true && product.id != null) {
      final success = await ProductService.deleteProduct(product.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteVoucher(Voucher voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Voucher'),
          content: Text('Are you sure you want to delete "${voucher.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await VoucherService.deleteVoucher(voucher.id);
      setState(() {});
    }
  }

  void _showAddVoucherDialog() {
    _showVoucherDialog();
  }

  void _showEditVoucherDialog(Voucher voucher) {
    _showVoucherDialog(voucher: voucher);
  }

  void _showVoucherDialog({Voucher? voucher}) async {
    final isEditing = voucher != null;
    final titleController = TextEditingController(text: voucher?.title ?? '');
    final descriptionController = TextEditingController(
      text: voucher?.description ?? '',
    );
    final discountController = TextEditingController(
      text: voucher?.discount.toString() ?? '10',
    );
    final coinsRequiredController = TextEditingController(
      text: voucher?.coinsRequired.toString() ?? '100',
    );
    final validDaysController = TextEditingController(
      text: voucher?.validDays.toString() ?? '30',
    );
    final maxClaimsController = TextEditingController(
      text: voucher?.maxClaims?.toString() ?? '',
    );
    String selectedCategory = voucher?.category ?? 'General';

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Voucher' : 'Add New Voucher'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Voucher Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: coinsRequiredController,
                      decoration: const InputDecoration(
                        labelText: 'Coins Required',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: validDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Valid Days',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: maxClaimsController,
                      decoration: const InputDecoration(
                        labelText: 'Max Claims (optional)',
                        hintText: 'Leave empty for unlimited',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'General',
                                'Electronics',
                                'Food & Drink',
                                'Clothing',
                                'Stationery',
                                'Books',
                                'Recreation',
                                'Free Shipping',
                              ]
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Basic required fields validation
                    if (titleController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        discountController.text.trim().isEmpty ||
                        coinsRequiredController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validate numeric fields
                    final discount = int.tryParse(discountController.text);
                    final coins = int.tryParse(coinsRequiredController.text);
                    final validDays = int.tryParse(validDaysController.text);
                    if (discount == null ||
                        coins == null ||
                        validDays == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Discount, Coins and Valid Days must be integers',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validate max claims (optional but must be positive integer if provided)
                    final maxText = maxClaimsController.text.trim();
                    if (maxText.isNotEmpty) {
                      final maxVal = int.tryParse(maxText);
                      if (maxVal == null || maxVal <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Max Claims must be a positive integer',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }

                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final newVoucher = Voucher(
        id: voucher?.id ?? 0,
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        discount: int.tryParse(discountController.text) ?? 10,
        coinsRequired: int.tryParse(coinsRequiredController.text) ?? 100,
        validDays: int.tryParse(validDaysController.text) ?? 30,
        maxClaims: maxClaimsController.text.trim().isEmpty
            ? null
            : int.tryParse(maxClaimsController.text.trim()),
        active: voucher?.active ?? true,
        createdAt: voucher?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (isEditing) {
        success = await VoucherService.updateVoucher(voucher.id, newVoucher);
      } else {
        success = await VoucherService.addVoucher(newVoucher);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Voucher updated successfully'
                    : 'Voucher added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save voucher'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openProductForm({Product? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductUploadPage(product: product),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product == null
                ? 'Product added successfully'
                : 'Product updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
