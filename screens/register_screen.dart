
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../features/onboarding/services/patient_onboarding_service.dart';
import '../features/onboarding/screens/patient_onboarding_complete_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String _role = 'patient';
  String _language = 'en';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService.instance.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        role: _role,
        language: _language,
      );

      if (_role == 'patient') {
        String? patientId;

        try {
          patientId = result?.user?.id?.toString();
        } catch (_) {}

        try {
          patientId ??= result?.id?.toString();
        } catch (_) {}

        if (patientId != null && patientId.isNotEmpty) {
          await PatientOnboardingService.instance.initializeForPatient(
            patientId: patientId,
            patientName: _name.text.trim(),
            language: _language,
          );
        }

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PatientOnboardingCompleteScreen(
              patientName: _name.text.trim(),
            ),
          ),
          (_) => false,
        );
      } else {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/caregiver',
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Create your SmritiAI account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _role,
                decoration: _decoration('Account type'),
                items: const [
                  DropdownMenuItem(
                    value: 'patient',
                    child: Text('Patient'),
                  ),
                  DropdownMenuItem(
                    value: 'caregiver',
                    child: Text('Caregiver'),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _role = value);
                        }
                      },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                enabled: !_loading,
                decoration: _decoration('Full name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Enter the full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _email,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Email'),
                validator: (v) {
                  final email = v?.trim() ?? '';
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _password,
                enabled: !_loading,
                obscureText: true,
                decoration: _decoration('Password'),
                validator: (v) {
                  if ((v ?? '').length < 6) {
                    return 'Password must contain at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _language,
                decoration: _decoration('Preferred language'),
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'hi',
                    child: Text('Hindi'),
                  ),
                  DropdownMenuItem(
                    value: 'mr',
                    child: Text('Marathi'),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _language = value);
                        }
                      },
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        ),
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
