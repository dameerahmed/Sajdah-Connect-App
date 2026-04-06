import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  static const Color _bg = Color(0xFF0F1113);
  static const Color _bg2 = Color(0xFF15181B);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _fieldFill = Color(0x66212427);
  static const Color _fieldBorder = Color(0x55D4AF37);
  static const Color _textPrimary = Color(0xFFEDEDED);
  static const Color _textMuted = Color(0xFF9A9A9A);

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) {
        return;
      }
      if (next.error != null && next.error!.isNotEmpty && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please check credentials or connection.'),
            backgroundColor: Color(0xFF7A1F1F),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_bg, _bg2, _bg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/premium_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Image.asset(
                          'assets/images/premium_logo_final.png',
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isLogin ? 'Log In' : 'Sign up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (!_isLogin) ...[
                        _GlassInputField(
                          controller: _nameController,
                          hint: 'Full Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _GlassInputField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _GlassInputField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),
                      _GoldEmailButton(
                        label: _isLogin ? 'Log in' : 'Sign up',
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : _handleEmailAuth,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: _fieldBorder, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: _fieldBorder, height: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _GooglePremiumButton(
                        isLoading: authState.isLoading,
                        onTap: authState.isLoading ? null : _handleGoogleLogin,
                      ),
                      const SizedBox(height: 24),
                      CenterAlignedRow(
                        text: _isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
                        buttonText: _isLogin ? 'Sign up' : 'Log in',
                        onPressed: authState.isLoading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    try {
      await ref.read(authProvider.notifier).googleLogin();
      if (!mounted) {
        return;
      }
      if (ref.read(authProvider).token != null) {
        context.go('/home');
      }
    } catch (e, st) {
      debugPrint('Google login error: $e');
      debugPrint('Google login stack: $st');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Login Error: $e'),
          backgroundColor: const Color(0xFF7A1F1F),
        ),
      );
    }
  }

  Future<void> _handleEmailAuth() async {
    if (_isLogin) {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } else {
      await ref.read(authProvider.notifier).signup(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    }

    if (!mounted) {
      return;
    }

    if (ref.read(authProvider).token != null) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class _GlassInputField extends StatelessWidget {
  const _GlassInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _LoginScreenState._textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: _LoginScreenState._gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _LoginScreenState._textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xD4D4AF37), size: 20),
        filled: true,
        fillColor: _LoginScreenState._fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _LoginScreenState._fieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _LoginScreenState._gold, width: 1.5),
        ),
      ),
    );
  }
}

class _GoldEmailButton extends StatelessWidget {
  const _GoldEmailButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          disabledBackgroundColor: const Color(0xFF555555),
          foregroundColor: const Color(0xFF0C0C0C),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF0C0C0C),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

class _GooglePremiumButton extends StatelessWidget {
  const _GooglePremiumButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF1A1E22),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_icon.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.g_mobiledata_rounded,
                          color: Color(0xFFD4AF37),
                          size: 22,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Color(0xFFEDEDED),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class CenterAlignedRow extends StatelessWidget {
  const CenterAlignedRow({
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });

  final String text;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: _LoginScreenState._textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: _LoginScreenState._gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
