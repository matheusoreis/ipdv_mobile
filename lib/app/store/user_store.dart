import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipdv/app/store/role_store.dart';

class UserStore extends GetxController {
  late Box _usersBox;
  final RoleStore roleStore = Get.find();

  var users = <Map<String, dynamic>>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _usersBox = Hive.box('users');
    loadUsers();
  }

  void loadUsers() {
    loading.value = true;
    users.value = _usersBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
    loading.value = false;
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    if (!_validateUser(user)) return;
    await _usersBox.add(user);
    loadUsers();
  }

  Future<void> updateUser(int index, Map<String, dynamic> user) async {
    if (!_validateUser(user)) return;
    await _usersBox.putAt(index, user);
    loadUsers();
  }

  Future<void> toggleActive(int index) async {
    final rawUser = _usersBox.getAt(index);
    if (rawUser == null) {
      Get.snackbar('Erro', 'Usuário não encontrado');
      return;
    }

    final user = Map<String, dynamic>.from(rawUser);
    user['active'] = !(user['active'] ?? true);
    await _usersBox.putAt(index, user);
    loadUsers();
  }

  bool _validateUser(Map<String, dynamic> user) {
    if (user['name'] == null || user['name'].toString().trim().isEmpty) {
      Get.snackbar('Erro', 'O nome do usuário é obrigatório');
      return false;
    }
    if (user['email'] == null || user['email'].toString().trim().isEmpty) {
      Get.snackbar('Erro', 'O email do usuário é obrigatório');
      return false;
    }
    if (user['role'] == null) {
      Get.snackbar('Erro', 'O cargo é obrigatório');
      return false;
    }
    return true;
  }
}
