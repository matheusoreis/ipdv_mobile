import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipdv/app/store/home_store.dart';
import 'package:ipdv/app/ui/widgets/drawer_items.dart';
import 'package:ipdv/app/ui/widgets/info_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeStore store = Get.find<HomeStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: DrawerItems(),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Bem-vindo ao IPDV!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Obx(() {
              return Column(
                children: [
                  store.image.value == null
                      ? const CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.file(
                              store.image.value!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => store.pickImage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt),
                          const Text('Tirar / Editar Foto'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 30),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Obx(
                    () => InfoTitle(
                      icon: Icons.access_time,
                      label: 'Data/Hora',
                      value: store.currentDateTime.value,
                    ),
                  ),
                  const Divider(height: 0),
                  Obx(
                    () => InfoTitle(
                      icon: Icons.battery_full,
                      label: 'Bateria',
                      value: '${store.batteryLevel.value}%',
                    ),
                  ),
                  const Divider(height: 0),
                  Obx(
                    () => InfoTitle(
                      icon: Icons.phone_android,
                      label: 'Modelo',
                      value: store.deviceModel.value,
                    ),
                  ),
                  const Divider(height: 0),
                  Obx(
                    () => InfoTitle(
                      icon: Icons.system_update,
                      label: 'Versão SO',
                      value: store.osVersion.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
