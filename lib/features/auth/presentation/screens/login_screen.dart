import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/services/firebase_services/analytics_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../providers/auth_providers.dart';
import 'widgets/appbar_auth.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  final void Function(bool success)? onResult;
  const LoginScreen({super.key, this.onResult});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    authState.whenOrNull(
      data: (user) {
        if (user != null) {
          if (widget.onResult != null) {
            widget.onResult?.call(true);
          } else {
            ref.read(analyticsProvider).logLogin();
            context.router.replaceAll([const MainWrapperRoute()]);
          }
        }
      },
      error: (e, _) {
        final msg =
            e is AuthException ? e.message : context.l10n.msgLoginFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 70,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white10,
            padding: const EdgeInsets.all(AppSizes.p12),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p28,
            vertical: AppSizes.p24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Logo(),
                const SizedBox(height: AppSizes.p40),
                Text(
                  context.l10n.loginTitle,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: AppSizes.displayLarge,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  context.l10n.loginSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.p40),
                _EmailField(controller: _emailController),
                const SizedBox(height: AppSizes.p16),
                _PasswordField(
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: AppSizes.p12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      context.l10n.forgotPassword,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: NeonButton(
                    label: context.l10n.btnLogin,
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(height: AppSizes.p32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.dontHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.router.push(const RegisterRoute()),
                      child: Text(
                        context.l10n.registerNow,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: context.l10n.labelEmail,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return context.l10n.valEmptyEmail;
        if (!v.contains('@')) return context.l10n.valInvalidEmail;
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: context.l10n.labelPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return context.l10n.valEmptyPassword;
        if (v.length < 6) return context.l10n.valShortPassword;
        return null;
      },
    );
  }
}
