
import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;

  const LoginScreen({
    super.key,
    this.initialRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final AuthSession? session =
          await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (session == null) {
        setState(() {
          _error =
              'Login failed. Check your email and password.';
          _loading = false;
        });
        return;
      }

      if (session.isPatient) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/patient',
          (_) => false,
        );
      } else if (session.isCaregiver) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/caregiver',
          (_) => false,
        );
      } else {
        setState(() {
          _error = 'Unknown account role.';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error =
            'Unable to sign in right now. Please try again.';
        _loading = false;
      });
    }
  }

  void _openRegister() {
    Navigator.pushNamed(
      context,
      '/register',
      arguments: widget.initialRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.initialRole;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 72,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      role == 'patient'
                          ? 'Patient account'
                          : role == 'caregiver'
                              ? 'Caregiver account'
                              : 'SmritiAI account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip:
                              _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Enter your password';
                        }

                        return null;
                      },
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .error,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 60,
                      child: FilledButton(
                        onPressed:
                            _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(),
                              )
                            : const Text(
                                'Sign in',
                                style:
                                    TextStyle(fontSize: 19),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    OutlinedButton(
                      onPressed:
                          _loading ? null : _openRegister,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Create an account',
                          style:
                              TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    const SizedBox(height: 12),

                    const Text(
                      'Demo accounts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Patient: patient@smriti.ai / 1234\n'
                      'Caregiver: caregiver@smriti.ai / 1234',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
