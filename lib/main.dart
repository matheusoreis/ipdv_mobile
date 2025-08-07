import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipdv/app/app_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ipdv/app/store/home_store.dart';
import 'package:ipdv/app/store/role_store.dart';
import 'package:ipdv/app/store/user_store.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  await Hive.openBox('roles');
  await Hive.openBox('users');

  Get.put(HomeStore());
  Get.put(RoleStore());
  Get.put(UserStore());

  runApp(const AppWidget());
}
