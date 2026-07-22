import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/app/theme/cohabio_theme.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';
import 'package:cohabio/core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(email, password);
    if (success) {
      widget.onLoginSuccess();
    } else {
      final error = ref.read(authProvider).errorMessage ?? "Login failed.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: CohabioTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('C', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Cohabio',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Find Your People. Find Your Place.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'student@cohabio.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              CohabioPrimaryButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _handleLogin,
              ),
              // Divider with "or"
              const SizedBox(height: 8),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                onPressed: () async {
                  // MVP Google Sign-In: prompt for Google email
                  // In production, replace with google_sign_in package
                  final emailController = TextEditingController();
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign in with Google'),
                      content: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Your Google Email',
                          hintText: 'name@gmail.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, emailController.text.trim()),
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  );

                  if (result != null && result.isNotEmpty) {
                    final success = await ref.read(authProvider.notifier).loginWithGoogle(email: result);
                    if (success) {
                      widget.onLoginSuccess();
                    } else {
                      final error = ref.read(authProvider).errorMessage ?? "Google sign-in failed.";
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
