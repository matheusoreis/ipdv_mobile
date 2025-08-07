import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importa o GetX
import 'package:ipdv/app/shared/theme.dart';
import 'package:ipdv/app/ui/pages/home_page.dart';
import 'package:ipdv/app/ui/pages/role_page.dart';
import 'package:ipdv/app/ui/pages/user_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "App Base",
      themeMode: ThemeMode.light,
      theme: MaterialTheme(const TextTheme()).light(),
      darkTheme: MaterialTheme(const TextTheme()).dark(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/roles', page: () => const RolePage()),
        GetPage(name: '/users', page: () => const UserPage()),
      ],
    );
  }
}
