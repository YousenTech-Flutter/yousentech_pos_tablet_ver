import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_service.dart';
import 'package:remote_database_setting/remote_database_setting/presentation/key_screen.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_messages_translation.dart';
import 'package:shared_widgets/config/network_connectivity_checker.dart';
import 'package:shared_widgets/utils/file_management.dart';
import 'package:shared_widgets/utils/mac_address_helper.dart';
import 'package:yousentech_pos_token/token_settings/presentation/token_screen.dart';


Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: kDebugMode ? ".env.development" : ".env.production");
  String encryptionKeyBase64 = dotenv.env['ENCRYPTION_KEY']!;
  await SharedPr.init(encryptionKeyBase64:encryptionKeyBase64 );
  SharedPr.retrieveInfo();
  await FileManagement.getInstance();
  // change
  // await DbHelper.getInstance();
  // await AppInvoiceStyle.loadFonts();
  await RemoteDatabaseSettingService.instantiateOdooConnection();
  //===
  await MacAddressHelper.getDeviceMacAddress();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // change
    // Get.put(NotificationHistoryController());
    //===
  }

  @override
  Widget build(BuildContext context) {
    NetworkConnectivityChecker.init();
    // change
    // BackgroundTask.init();
    //===
    return OverlaySupport(
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          child:
              SharedPr.subscriptionDetailsObj?.url == null
                  ? const KeyScreen()
                  : 
                  const TokenScreen(),
                  // SharedPr.token == null
                  //     ? const TokenScreen()
                  //     : const EmployeesListScreen(),
          builder: (_, child) {
            return GetMaterialApp(
                title: 'Point Of Sale',
                debugShowCheckedModeBanner: false,
                translations: Messages(),
                locale: Locale(SharedPr.lang ?? 'en'),
                fallbackLocale: const Locale('en'),
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown
                  },
                ),
                theme: ThemeData(
                  useMaterial3: true,
                  textTheme: Theme.of(context).textTheme.apply(
                        bodyColor: AppColor.black,
                        fontFamily: 'Tajawal',
                      ),
                ),
                home: child
                );

          }),
    );
  }
}
