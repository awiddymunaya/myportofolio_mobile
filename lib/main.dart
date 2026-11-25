import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, super.key});

  final ApiClient apiClient;

  // Widget ini adalah akar (root) aplikasi.
  @override
  Widget build(BuildContext context) {
    // MultiProvider menyisipkan ApiClient dan AuthState ke widget tree,
    // sehingga semua layar bisa memakainya lewat context.read/watch.
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(apiClient)),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        debugShowCheckedModeBanner: false,
        // Tema Royal Blue & Gold, sama dengan web portofolio Django.
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            secondary: const Color(0xFFD4AF37),
          ),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}
