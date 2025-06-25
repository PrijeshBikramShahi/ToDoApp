import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
// ignore: unused_import
import 'views/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter To-Do App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}