import 'package:flutter/material.dart';
import 'package:uniperks/auth/login_page.dart';
import 'package:uniperks/services/user_service.dart';
import 'package:uniperks/services/quiz_service.dart';
import 'package:uniperks/services/product_service.dart';
import 'package:uniperks/models/product.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedQuizModule = 'general_knowledge';

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
              Tab(icon: Icon(Icons.inventory), text: 'Products'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildUsersTab(),
            _buildQuizTab(),
            _buildProductsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final registeredUsers = UserService.getAllUsers();
    final quizModules = QuizService.getQuizModules();
    final totalProducts = ProductService.getAllProducts();
    
    // Calculate total questions across all modules
    int totalQuestions = 0;
    for (var module in quizModules) {
      totalQuestions += module.totalQuestions;
    }

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
                  const Icon(Icons.admin_panel_settings, size: 40, color: Colors.deepPurple),
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
                  'Quiz Modules',
                  '${quizModules.length}',
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Questions',
                  '$totalQuestions',
                  Icons.quiz,
                  Colors.orange,
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
            'Quiz Modules Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          // Changed from Expanded to Container with fixed height to make it scrollable within the SingleChildScrollView
          SizedBox(
            height: 300, // Fixed height for the quiz modules list
            child: ListView.builder(
              itemCount: quizModules.length,
              itemBuilder: (context, index) {
                final module = quizModules[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      module.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(module.title),
                    subtitle: Text('${module.totalQuestions} questions • ${module.coinsReward} total coins'),
                    trailing: Chip(
                      label: Text(module.category),
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
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
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    final registeredUsers = UserService.getAllUsers();

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
                  physics: const NeverScrollableScrollPhysics(), // Disable ListView scrolling since parent is scrollable
                  itemCount: registeredUsers.length,
                  itemBuilder: (context, index) {
                    final user = registeredUsers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user['username']!),
                        subtitle: Text(user['email']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user['username']!, index),
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
    final modules = QuizService.getQuizModules();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module Selection
          Row(
            children: [
              Expanded( // Wrap text in Expanded to prevent overflow
                child: Text(
                  'Quiz Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(),
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
                        Text(module.icon, style: const TextStyle(fontSize: 16)),
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
          _buildQuestionsList(),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final questions = QuizService.getQuestionsByModule(selectedQuizModule);
    final selectedModule = QuizService.getQuizModules().firstWhere((m) => m.id == selectedQuizModule);

    if (questions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedModule.icon,
                style: const TextStyle(fontSize: 64),
              ),
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
              question['question'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                  Text(' ${question['coins']} coins'),
                  const SizedBox(width: 16),
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  Text(' Answer: ${question['answers'][question['correctAnswer']]}'),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditQuestionDialog(question, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuestion(index),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Answer Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(question['answers'].length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Row(
                          children: [
                            Icon(
                              i == question['correctAnswer'] ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: i == question['correctAnswer'] ? Colors.green : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${String.fromCharCode(65 + i)}. ${question['answers'][i]}'),
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
    final products = ProductService.getAllProducts();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded( // Wrap text in Expanded to prevent overflow
                child: Text(
                  'Products (${products.length})',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(),
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
                        Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No products yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text('\$${product.price.toStringAsFixed(2)}'),
                                  if (product.discount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${product.discount}% OFF',
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(product.category),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditProductDialog(product, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product.name, index),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  // Dialog methods remain the same as they were already properly handled
  void _showAddQuestionDialog() {
    _showQuestionDialog();
  }

  void _showEditQuestionDialog(Map<String, dynamic> question, int index) {
    _showQuestionDialog(question: question, index: index);
  }

  void _showQuestionDialog({Map<String, dynamic>? question, int? index}) {
    final isEditing = question != null;
    final questionController = TextEditingController(text: question?['question'] ?? '');
    final coinsController = TextEditingController(text: question?['coins']?.toString() ?? '');
    final List<TextEditingController> answerControllers = List.generate(4, (i) => 
        TextEditingController(text: question?['answers']?[i] ?? ''));
    int correctAnswer = question?['correctAnswer'] ?? 0;
    String currentModule = selectedQuizModule;

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
                      items: QuizService.getQuizModules().map((module) => 
                        DropdownMenuItem(
                          value: module.id,
                          child: Row(
                            children: [
                              Text(module.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(module.title),
                            ],
                          ),
                        )
                      ).toList(),
                      onChanged: isEditing ? null : (value) {
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
                    TextField(
                      controller: coinsController,
                      decoration: const InputDecoration(
                        labelText: 'Coins Reward',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text('Answer Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: i,
                              groupValue: correctAnswer,
                              onChanged: (value) {
                                setDialogState(() {
                                  correctAnswer = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: answerControllers[i],
                                decoration: InputDecoration(
                                  labelText: 'Option ${String.fromCharCode(65 + i)}',
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
                  onPressed: () {
                    if (questionController.text.isNotEmpty &&
                        coinsController.text.isNotEmpty &&
                        answerControllers.every((controller) => controller.text.isNotEmpty)) {
                      final newQuestion = {
                        'question': questionController.text,
                        'answers': answerControllers.map((c) => c.text).toList(),
                        'correctAnswer': correctAnswer,
                        'coins': int.tryParse(coinsController.text) ?? 0,
                      };

                      if (isEditing && index != null) {
                        QuizService.updateQuestion(selectedQuizModule, index, newQuestion);
                      } else {
                        QuizService.addQuestion(newQuestion, currentModule);
                      }

                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
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
              onPressed: () {
                UserService.removeUser(index);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuestion(int index) {
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
              onPressed: () {
                QuizService.removeQuestion(selectedQuizModule, index);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productName, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "$productName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ProductService.removeProduct(index);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog() {
    _showProductDialog();
  }

  void _showEditProductDialog(Product product, int index) {
    _showProductDialog(product: product, index: index);
  }

  void _showProductDialog({Product? product, int? index}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final discountController = TextEditingController(text: product?.discount.toString() ?? '0');
    String selectedCategory = product?.category ?? 'Clothing';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
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
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ProductService.getCategories()
                          .where((category) => category != 'All')
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      final newProduct = Product(
                        id: product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        imageUrl: product?.imageUrl ?? 'https://via.placeholder.com/200x200?text=${nameController.text}',
                        category: selectedCategory,
                        discount: int.tryParse(discountController.text) ?? 0,
                      );

                      if (isEditing && index != null) {
                        ProductService.updateProduct(index, newProduct);
                      } else {
                        ProductService.addProduct(newProduct);
                      }

                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}