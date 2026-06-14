import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techia_ats/core/constants/app_routes.dart';
import 'package:techia_ats/core/theme/app_colors.dart';
import 'package:techia_ats/core/theme/app_text_styles.dart';
import 'package:techia_ats/blocs/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 360,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated && mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentEmerald,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.people_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Techia ATS', style: AppTextStyles.titleMedium.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Sign in to your account', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 32),
                    // Error
                    if (state is AuthError)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.statusRejected.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.statusRejected.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          state.message,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusRejected),
                        ),
                      ),
                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLabel, fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'admin@techia.com',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLabel, fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _login(context),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _login(context),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Techia ATS \u00b7 v1.0.0', style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    context.read<AuthBloc>().add(
      AuthLogin(_emailController.text.trim(), _passwordController.text),
    );
  }
}
