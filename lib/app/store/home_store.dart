import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeStore extends GetxController {
  final Rx<File?> image = Rx<File?>(null);
  final RxString currentDateTime = ''.obs;
  final RxInt batteryLevel = 0.obs;
  final RxString deviceModel = ''.obs;
  final RxString osVersion = ''.obs;

  final Battery _battery = Battery();
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadDeviceInfo();
    _loadBatteryLevel();
    _startClock();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Foto',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.blue,

            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Editar Foto',
          ),
        ],
      );

      if (croppedFile != null) {
        image.value = File(croppedFile.path);
      } else {
        image.value = File(pickedFile.path);
      }
    }
  }

  void _startClock() {
    Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      currentDateTime.value =
          '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year} '
          '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    deviceModel.value = androidInfo.model;
    osVersion.value = 'Android ${androidInfo.version.release}';
  }

  Future<void> _loadBatteryLevel() async {
    batteryLevel.value = await _battery.batteryLevel;
    _battery.onBatteryStateChanged.listen((_) async {
      batteryLevel.value = await _battery.batteryLevel;
    });
  }
}
