import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/notifications.dart';
import 'core/theme.dart';
import 'data/database/db_helper.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
  ));
  // Open DB early so first-launch seeding is done before UI starts.
  await DbHelper.instance.db;
  await Notifications.instance.init();
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رفيقي في الإنجليزية',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _RootRouter(),
    );
  }
}

/// Decides whether to show Onboarding (first launch) or HomeShell.
class _RootRouter extends StatefulWidget {
  const _RootRouter();

  @override
  State<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<_RootRouter> {
  bool? _onboarded;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboarded = prefs.getBool('onboarded') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboarded == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_onboarded!) {
      return OnboardingScreen(onDone: () {
        setState(() => _onboarded = true);
      });
    }
    return const HomeShell();
  }
}
