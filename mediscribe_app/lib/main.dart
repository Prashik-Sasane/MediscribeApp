import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'package:mediscribe_app/core/theme.dart';
import 'package:mediscribe_app/core/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  
  // Initialize Stripe with publishable key from .env
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 
      'pk_test_51TKLGCA0vwEId8d1ChT5p251LabT0MZ61Hlq4Jq233SOHNEa6yM80fDFRYOqfXDaHtFn8BredvwBtH974pt3olZu00Sn9lvWwp';
  
  runApp(MediscribeApp());
}

class MediscribeApp extends StatelessWidget {
  MediscribeApp({super.key});

  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      appState: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mediscribe',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
