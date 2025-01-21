import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_service.dart';
import 'package:remote_database_setting/remote_database_setting/presentation/key_screen.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_messages_translation.dart';
import 'package:shared_widgets/config/network_connectivity_checker.dart';
import 'package:shared_widgets/utils/file_management.dart';
import 'package:shared_widgets/utils/mac_address_helper.dart';
import 'package:shared_widgets/utils/touch_screen_support_helper.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main() async{
  // await initPosPackage();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: kDebugMode ? ".env.development":".env.production");
  await SharedPr.init();
  SharedPr.retrieveInfo();
  // await WindowsSingleInstance.ensureSingleInstance(args, "instance_checker",
  //     onSecondWindow: (args) {
  //       // ignore: avoid_print
  //       // print(args);
  //     });
  // TODO: Initialize SocketConnectivityChecker
  // SocketConnectivityChecker.init();
  await FileManagement.getInstance();
  // TODO: Initialize config
  // await appConfiguration();
  // await DbHelper.getInstance();
  // await AppInvoiceStyle.loadFonts();
  await RemoteDatabaseSettingService.instantiateOdooConnection();
  await MacAddressHelper.getDeviceMacAddress();
  TouchScreenSupportHelper.isTouchInputAvailable();

  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn = 'https://549ffb2b3c149bdbc2eeae1c41302785@o4508426533797888.ingest.us.sentry.io/4508426542383104';
  //     options.tracesSampleRate = 1.0;
  //     options.profilesSampleRate = 1.0;
  //   },
  //   appRunner: () => runApp(const MyApp()),
  // );

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
    // TODO: Initialize config
    // Get.put(NotificationHistoryController());
  }

  @override
  Widget build(BuildContext context) {
    NetworkConnectivityChecker.init();
    // TODO: Initialize BackgroundTask
    // BackgroundTask.init();
    return OverlaySupport(
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          child:
          // WebViewClass(),
          SharedPr.subscriptionDetailsObj?.url == null
              ? const KeyScreen()
              : Container(),
          // TODO: Initialize token & EmployeesListScreen
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
              // home: ProgressBarWithText(
              //   percentage: 50, // Adjust the percentage to see different effects
              //   text: 'This is a long progress text to demonstrate contrast and layout behavior.',
              //   backgroundColor: Colors.white, // Screen background color
              // )
            );
            // home: InvoiceComparisonScreen());
            // home: TableWithKeyboardNavigation());
            // home: CenteredCardWithList());
            // home: BackupScreen());
          }),
    );
  }
}
