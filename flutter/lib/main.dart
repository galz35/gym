import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'core/router/app_shell.dart';
import 'core/database/app_database.dart';
import 'core/services/offline_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializaciones en paralelo
  await Future.wait([
    initializeDateFormatting('es_ES', null),
    Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    ),
  ]);

  final database = AppDatabase();
  final syncService = OfflineSyncService(database);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ProviderScope(
      child: Provider.value(
        value: database,
        child: Provider.value(value: syncService, child: const GymApp()),
      ),
    ),
  );
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = context.watch<AppDatabase>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ClientesProvider(database)),
        ChangeNotifierProvider(create: (_) => CajaProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider(database)),
        ChangeNotifierProvider(create: (_) => AsistenciaProvider()),
        ChangeNotifierProvider(create: (_) => PlanesProvider()),
        ChangeNotifierProvider(create: (_) => MembresiasProvider(database)),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => SucursalProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
        ChangeNotifierProvider(create: (_) => TrasladosProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'GymPro Multi-Sucursal',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthenticationWrapper(),
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Mientras no tengamos ni idea (primera carga), podemos mostrar un placeholder ligero
        // Pero con la optimización en AuthProvider, isLoading pasará a false casi de inmediato.
        if (auth.isLoading && !auth.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          return LoginScreen(
            onLoginSuccess: () {
              // Login handled by AuthProvider
            },
          );
        }

        return AppShell(
          onLogout: () async {
            await auth.logout();
          },
        );
      },
    );
  }
}
