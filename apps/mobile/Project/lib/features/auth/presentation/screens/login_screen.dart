import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.dashboard);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Container(
                        // width: 56,
                        height: 56,
                        // decoration: BoxDecoration(
                        // color: AppColors.statusInactive,
                        // borderRadius: BorderRadius.circular(14),
                        // ),
                        child: const Icon(Icons.people_alt_outlined,
                            color: AppColors.accentEmerald, size: 50),
                      ),
                      const SizedBox(height: 24),
                      Text('Welcome back', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 4),
                      Text('Sign in to your Techia ATS account',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 32),
                      if (state is AuthError)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(state.message,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.error))),
                            ],
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Password is required'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(AuthLogin(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        ));
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentEmerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Sign in',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
