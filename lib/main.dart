import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/controller/auth_controller.dart';
import 'package:untitled/views/sma_page.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'views/add_member_screen.dart';
import 'views/chit_type_screen.dart';
import 'views/details_screen.dart';
import 'views/login_screen.dart';
import 'views/member_list_screen.dart';
import 'views/sigup_screen.dart';
import 'views/splash_screen.dart';
import 'package:sizer/sizer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox('chitTypeBox');
  await Hive.openBox('memberLocalBox');

  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SLA Finance',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          initialRoute: AppRoutes.login,
          getPages: [
            GetPage(name: AppRoutes.splashScreen, page: () => SplashScreen()),
            GetPage(name: AppRoutes.login, page: () => LoginPage()),
            GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
            GetPage(name: AppRoutes.chitType, page: () => const ChitTypeScreen()),
            GetPage(name: AppRoutes.members, page: () => const MemberListScreen()),
            GetPage(name: AppRoutes.addMember, page: () => const AddMemberScreen()),
            GetPage(name: AppRoutes.details, page: () => const DetailsScreen()),
            GetPage(name: AppRoutes.message, page: () => SmsPage()),
          ],
        );
      },
    );
  }
}
