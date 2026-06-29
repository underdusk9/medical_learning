import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/constants.dart';
import 'providers/init_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MedicalWorkbuddyApp(),
    ),
  );
}

/// 带初始化逻辑的应用入口
class MedicalWorkbuddyApp extends ConsumerStatefulWidget {
  const MedicalWorkbuddyApp({super.key});

  @override
  ConsumerState<MedicalWorkbuddyApp> createState() =>
      _MedicalWorkbuddyAppState();
}

class _MedicalWorkbuddyAppState extends ConsumerState<MedicalWorkbuddyApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    await ref.read(initProvider.future);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: AppColors.primary),
        home: const Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(),
        ),
      );
    }
    return const ConsumerApp();
  }
}
