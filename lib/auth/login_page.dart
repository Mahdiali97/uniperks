import 'package:flutter/material.dart';
import 'package:uniperks/auth/register_page.dart';
import 'package:uniperks/services/user_service.dart';
import 'package:uniperks/admin_dashboard.dart';
import 'package:uniperks/user_dashboard.dart';
import 'package:uniperks/widgets/animated_border_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberPreference();
    _checkSavedLogin();

    // Initialize default users in background (non-blocking)
    // This is low priority and doesn't delay UI rendering
    UserService.initializeDefaultUsers().catchError((e) {
      print('Background initialization error: $e');
    });
  }

  Future<void> _checkSavedLogin() async {
    // First decide if we should auto-login based on our own preference store
    final shouldAuto = await UserService.shouldAutoLogin();
    if (shouldAuto) {
      // Prefer Supabase session for admin accounts
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && mounted) {
          print('Auto-login via Supabase session (remember enabled)');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          });
          return;
        }
      } catch (_) {}

      final savedUser = await UserService.getSavedUser();
      if (savedUser != null && mounted) {
        print('Auto-login (remember enabled) for user: $savedUser');
        final role = await UserService.getUserRole(savedUser);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (role == 'admin' || UserService.isAdminUser(savedUser)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(username: savedUser),
              ),
            );
          }
        });
        return;
      }
    }

    // If NOT remembering but an active Supabase session exists, sign it out so login screen shows
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && !_rememberMe) {
        print('Supabase session present but remember disabled. Signing out.');
        await Supabase.instance.client.auth.signOut();
      }
    } catch (e) {
      print('Supabase signOut check error: $e');
    }
  }

  Future<void> _loadRememberPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      if (mounted) {
        setState(() => _rememberMe = remember);
      }
    } catch (e) {
      print('Load remember preference error: $e');
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String username = _usernameController.text.trim();
      String password = _passwordController.text;

      try {
        // First, try to authenticate with Supabase (for admin users)
        // Admin users should use email format
        if (username.contains('@')) {
          try {
            final supa = Supabase.instance.client;
            final res = await supa.auth.signInWithPassword(
              email: username,
              password: password,
            );

            if (res.session != null && mounted) {
              // Successfully logged in with Supabase - Admin user
              if (_rememberMe) {
                await UserService.saveLoginState(username, remember: true);
              } else {
                // Mark as not remembered; keep session for this run but prevent future auto-login
                await UserService.clearLoginState();
                await UserService.setRememberPreference(false);
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
              return;
            }
          } on AuthException catch (e) {
            // Supabase auth failed, will try regular user auth below
            print('Supabase auth failed: ${e.message}');
          }
        }

        // Try regular user authentication from database
        if (await UserService.authenticateUser(username, password)) {
          // Check user role
          final role = await UserService.getUserRole(username);

          if (role == 'admin' || UserService.isAdminUser(username)) {
            // Admin user from database
            if (_rememberMe) {
              await UserService.saveLoginState(username, remember: true);
            } else {
              await UserService.clearLoginState();
            }
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            }
          } else {
            // Regular user - go to user dashboard
            if (_rememberMe) {
              await UserService.saveLoginState(username, remember: true);
            } else {
              await UserService.clearLoginState();
            }
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDashboard(username: username),
                ),
              );
            }
          }
        } else {
          // Authentication failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid credentials. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0066CC), // Premium Blue
              Color(0xFF0052A3), // Dark Blue
              Color(0xFFF0F7FF), // Light Blue-White
              Color(0xFFFFFFFF), // Pure White
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Logo with glow effect
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo/UniPerks.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'UniPerks',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome !',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // White card container for form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username/Email Field with Animated Border
                          AnimatedBorderTextField(
                            controller: _usernameController,
                            hintText: 'Username or email',
                            labelText: 'Username / Email',
                            prefixIcon: Icons.person,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            gradientColors: const [
                              Color(0xFF0066CC),
                              Color(0xFF0052A3),
                              Color(0xFF667EEA),
                              Color(0xFF0066CC),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username or email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field with Animated Border
                          AnimatedBorderTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            labelText: 'Password',
                            prefixIcon: Icons.lock,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            gradientColors: const [
                              Color(0xFF0066CC),
                              Color(0xFF0052A3),
                              Color(0xFF667EEA),
                              Color(0xFF0066CC),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 16),

                          // Remember Me Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: const Color(0xFF0066CC),
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text('Remember Me'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066CC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Register Link
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage(),
                                      ),
                                    );
                                  },
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Register',
                                    style: TextStyle(
                                      color: Color(0xFF0066CC),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Demo Credentials
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue[700],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Early Access',
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
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
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
