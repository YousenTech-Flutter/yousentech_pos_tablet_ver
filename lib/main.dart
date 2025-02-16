import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_service.dart';
import 'package:remote_database_setting/remote_database_setting/presentation/key_screen.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/config/app_messages_translation.dart';
import 'package:shared_widgets/config/network_connectivity_checker.dart';
import 'package:shared_widgets/utils/file_management.dart';
import 'package:shared_widgets/utils/mac_address_helper.dart';
import 'package:shared_widgets/utils/touch_screen_support_helper.dart';
import 'package:yousentech_authentication/authentication/presentation/views/employees_list.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';
import 'package:yousentech_pos_notification/notification/utils/background_task.dart';
import 'package:yousentech_pos_notification_history/notification_history/domain/notification_history_viewmodel.dart';
import 'package:yousentech_pos_token/token_settings/presentation/token_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await FileManagement.getInstance();
  if (Platform.isAndroid || Platform.isIOS) {
    initNotification();
  }

  await SharedPr.loadEnv();
  await SharedPr.init();
  SharedPr.retrieveInfo();
  await DbHelper.getInstance();
  await AppInvoiceStyle.loadFonts();
  await RemoteDatabaseSettingService.instantiateOdooConnection();
  await MacAddressHelper.getDeviceMacAddress();
  TouchScreenSupportHelper.isTouchInputAvailable();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

    Get.put(NotificationHistoryController());
  }

  @override
  Widget build(BuildContext context) {
    NetworkConnectivityChecker.init();
    // BackgroundTask.init();
    return OverlaySupport(
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          child: SharedPr.subscriptionDetailsObj?.url == null
              ? const KeyScreen()
              : SharedPr.token == null
                  ? const TokenScreen()
                  : const EmployeesListScreen(),
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
                home: child);
          }),
    );
  }
}

Future<void> initNotification() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettingsIOS = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    defaultPresentBadge: true,
    defaultPresentList: true,
  );

  /// initialization part
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {},
  );

  if (Platform.isAndroid) {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}
