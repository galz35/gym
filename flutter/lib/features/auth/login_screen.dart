import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/config/app_config.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _empresaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _loadEmpresaId();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  Future<void> _loadEmpresaId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('last_empresa_id');
    if (savedId != null && savedId.isNotEmpty) {
      _empresaController.text = savedId;
    } else {
      _empresaController.text = AppConfig.defaultEmpresaId;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final empresaId = _empresaController.text.trim();

    // Validar formato UUID
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(empresaId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El ID de Empresa no tiene un formato UUID válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await auth.login(email, password, empresaId: empresaId);

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_empresa_id', empresaId);
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al iniciar sesión'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // ─── Background gradient ───
            Container(
              height: size.height * 0.45,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF991B1B),
                    Color(0xFFDC2626),
                    Color(0xFFEF4444),
                  ],
                ),
              ),
            ),
            // ─── Decorative circles ───
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: -60,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // ─── Content ───
            SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height - MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      // ─── Logo & Branding ───
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'GymPro',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sistema de Gestión Multi-Sucursal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // ─── Login Card ───
                      Expanded(
                        child: SlideTransition(
                          position: _slideUp,
                          child: FadeTransition(
                            opacity: _fadeIn,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 40,
                                    offset: const Offset(0, -8),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ingresa tus credenciales para continuar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    // ─── Empresa ID ───
                                    TextFormField(
                                      controller: _empresaController,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ingresa el ID de la empresa';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'ID de Empresa',
                                        hintText: 'UUID de la empresa',
                                        prefixIcon: const Icon(
                                          Icons.business_rounded,
                                          size: 20,
                                          color: AppColors.textTertiary,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // ─── Email ───
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ingresa tu email';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'usuario@empresa.com',
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          size: 20,
                                          color: AppColors.textTertiary,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // ─── Password ───
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        hintText: '••••••••',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 20,
                                          color: AppColors.textTertiary,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: AppColors.surfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // ─── Login Button ───
                                    SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text(
                                                'Ingresar',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // ─── Error message ───
                                    if (auth.error != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorLight,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                auth.error!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    // ─── Footer ───
                                    Center(
                                      child: Text(
                                        'v1.0.0 — GymPro Multi-Sucursal',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
