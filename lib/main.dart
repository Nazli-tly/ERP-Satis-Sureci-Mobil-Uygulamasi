import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobil_satis/viewmodels/cek_senet_viewmodel.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'views/login_view.dart';
import 'firebase_options.dart';
import 'package:mobil_satis/viewmodels/cari_viewmodel.dart';
import 'viewmodels/fatura_viewmodel.dart';
import 'viewmodels/siparis_viewmodel.dart';
import 'viewmodels/firma_viewmodel.dart';
import 'viewmodels/rota_viewmodel.dart';
import 'viewmodels/senkron_viewmodel.dart';
import 'viewmodels/ayarlar_viewmodel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CariViewModel()),
        ChangeNotifierProvider(create: (_) => SiparisViewModel()),
        ChangeNotifierProvider(create: (_) => SenkronViewModel()),


        ChangeNotifierProvider(create: (_) => FirmaViewModel()),
        ChangeNotifierProvider(create: (_) => CekSenetViewModel()),
        ChangeNotifierProvider(create: (_) => FaturaViewModel(), child: MyApp(),),
        ChangeNotifierProvider(create: (_) => RotaViewModel()),
        ChangeNotifierProvider(create: (_) => AyarlarViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginView(),
      ),
    );
  }
}
