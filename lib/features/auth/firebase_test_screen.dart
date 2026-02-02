import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stray_resuce_bih/core/providers/firebase_providers.dart';
import 'package:stray_resuce_bih/core/services/firebase_service.dart';

/// Firebase Connection Test Screen
/// This screen demonstrates Firebase connectivity and basic operations
class FirebaseTestScreen extends ConsumerStatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  ConsumerState<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends ConsumerState<FirebaseTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _statusMessage = 'Firebase is connected and ready!';
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = _isSignUp ? 'Creating account...' : 'Signing in...';
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      
      if (_isSignUp) {
        await firebaseService.registerWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Create user profile
        final user = firebaseService.currentUser;
        if (user != null) {
          await firebaseService.createUserProfile(
            userId: user.uid,
            userData: {
              'email': user.email,
              'displayName': user.email?.split('@')[0],
            },
          );
        }
        
        setState(() {
          _statusMessage = 'Account created successfully!';
        });
      } else {
        await firebaseService.signInWithEmailPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        setState(() {
          _statusMessage = 'Signed in successfully!';
        });
      }

      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Signing out...';
    });

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.signOut();
      setState(() {
        _statusMessage = 'Signed out successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error signing out: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 4,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_done,
                          color: Colors.deepPurple,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Firebase Status',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Info Card
            userAsync.when(
              data: (user) {
                if (user != null) {
                  return Card(
                    elevation: 4,
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Authenticated User',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Email: ${user.email ?? 'N/A'}'),
                          Text('UID: ${user.uid}'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSignOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleAuth,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                                  child: Text(
                                    _isSignUp
                                        ? 'Already have an account? Sign In'
                                        : 'Don\'t have an account? Sign Up',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Card(
                elevation: 4,
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Firebase Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Configuration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Project ID', 'bih20-75780'),
                    _buildInfoRow('Project Number', '790257403484'),
                    _buildInfoRow('Storage Bucket', 'bih20-75780.firebasestorage.app'),
                    _buildInfoRow('Package Name', 'com.company.bih'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
