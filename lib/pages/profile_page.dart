import 'package:flutter/material.dart';
import 'package:uniperks/services/user_service.dart';
import 'package:uniperks/services/user_coins_service.dart';
import 'package:uniperks/pages/edit_profile_simple.dart';
import 'package:uniperks/pages/purchase_history_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userProfile;
  int _coins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await UserService.getUserProfile(widget.username);
      final coins = await UserCoinsService.getCoins(widget.username);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _coins = coins;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load Profile Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfileSimplePage(username: widget.username),
                ),
              );

              if (result == true) {
                _loadProfile();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? const Center(child: Text('Failed to load profile'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066CC),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child:
                              _userProfile!['avatar_url'] != null &&
                                  _userProfile!['avatar_url']
                                      .toString()
                                      .isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _userProfile!['avatar_url'],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Text(
                                          widget.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 48,
                                            color: Color(0xFF0066CC),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  ),
                                )
                              : Text(
                                  widget.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Color(0xFF0066CC),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Username
                        Text(
                          _userProfile!['full_name'] ?? widget.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.username}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Coins Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Color(0xFFFFD700),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_coins Coins',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066CC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Purchase History Card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseHistoryPage(
                                  username: widget.username,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F7FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Color(0xFF0066CC),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Purchase History',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF424242),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'View your past orders',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF757575),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.email,
                          title: 'Email',
                          value: _userProfile!['email'] ?? 'Not set',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.phone,
                          title: 'Phone',
                          value: _userProfile!['phone'] ?? 'Not set',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.info_outline,
                          title: 'Bio',
                          value: _userProfile!['bio'] ?? 'No bio yet',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Address',
                          value: _buildAddress(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0066CC), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF424242),
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

  String _buildAddress() {
    final parts = <String>[];

    if (_userProfile!['address_line'] != null &&
        _userProfile!['address_line'].toString().isNotEmpty) {
      parts.add(_userProfile!['address_line']);
    }

    if (_userProfile!['city'] != null &&
        _userProfile!['city'].toString().isNotEmpty) {
      parts.add(_userProfile!['city']);
    }

    if (_userProfile!['postal_code'] != null &&
        _userProfile!['postal_code'].toString().isNotEmpty) {
      parts.add(_userProfile!['postal_code']);
    }

    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }
}
