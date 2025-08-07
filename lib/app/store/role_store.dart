import 'package:get/get.dart';
import 'package:hive/hive.dart';

class RoleStore extends GetxController {
  late Box _rolesBox;

  var roles = <Map<String, dynamic>>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _rolesBox = Hive.box('roles');
    loadRoles();
  }

  void loadRoles() {
    loading.value = true;
    roles.value = _rolesBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
    loading.value = false;
  }

  Future<void> addRole(Map<String, dynamic> role) async {
    if (!_validateRole(role)) return;
    await _rolesBox.add(role);
    loadRoles();
  }

  Future<void> updateRole(int index, Map<String, dynamic> role) async {
    if (!_validateRole(role)) return;
    await _rolesBox.putAt(index, role);
    loadRoles();
  }

  Future<void> toggleActive(int index) async {
    final rawRole = _rolesBox.getAt(index);
    if (rawRole == null) {
      Get.snackbar('Erro', 'Cargo não encontrado');
      return;
    }

    final role = Map<String, dynamic>.from(rawRole);

    role['active'] = !(role['active'] ?? true);

    await _rolesBox.putAt(index, role);
    loadRoles();
  }

  bool _validateRole(Map<String, dynamic> role) {
    if (role['name'] == null || role['name'].toString().trim().isEmpty) {
      Get.snackbar('Erro', 'O nome do cargo é obrigatório');
      return false;
    }
    return true;
  }
}
