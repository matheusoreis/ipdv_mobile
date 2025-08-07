import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipdv/app/store/role_store.dart';
import 'package:ipdv/app/store/user_store.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserStore store = Get.find<UserStore>();
  final RoleStore roleStore = Get.find<RoleStore>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int? _editingIndex;
  int? _selectedRoleIndex;

  void _showUserDialog({Map<String, dynamic>? user, int? index}) {
    final activeRoles = roleStore.roles.where((r) => r['active'] == true).toList();

    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';

      // Encontrar o índice do cargo ativo que corresponde ao cargo do usuário, ou null se não encontrado
      if (user['role'] != null) {
        final userRole = Map<String, dynamic>.from(user['role']);
        _selectedRoleIndex = activeRoles.indexWhere((r) => r['name'] == userRole['name']);
        if (_selectedRoleIndex == -1) {
          // Caso o cargo do usuário não esteja ativo mais, opcionalmente setar null
          _selectedRoleIndex = null;
        }
      } else {
        _selectedRoleIndex = null;
      }

      _editingIndex = index;
    } else {
      _nameController.clear();
      _emailController.clear();
      _selectedRoleIndex = null;
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_editingIndex == null ? 'Adicionar Usuário' : 'Editar Usuário'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedRoleIndex,
                decoration: const InputDecoration(labelText: 'Cargo'),
                items: List.generate(activeRoles.length, (i) {
                  final role = activeRoles[i];
                  return DropdownMenuItem<int>(
                    value: i,
                    child: Text(role['name']),
                  );
                }),
                onChanged: (int? newIndex) {
                  setState(() {
                    _selectedRoleIndex = newIndex;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _showConfirmDialog();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog() {
    final activeRoles = roleStore.roles.where((r) => r['active'] == true).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Deseja realmente salvar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedRoleIndex == null) {
                Get.snackbar('Erro', 'Selecione um cargo ativo');
                return;
              }
              final selectedRole = activeRoles[_selectedRoleIndex!];

              if (_editingIndex == null) {
                await store.addUser({
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'role': selectedRole,
                  'active': true,
                });
              } else {
                await store.updateUser(_editingIndex!, {
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'role': selectedRole,
                  'active': store.users[_editingIndex!]['active'],
                });
              }

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  void _toggleActive(int index) {
    store.toggleActive(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (store.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (store.users.isEmpty) {
          return const Center(child: Text('Nenhum usuário cadastrado'));
        }
        return ListView.separated(
          itemCount: store.users.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final user = store.users[index];
            return ListTile(
              title: Text(user['name']),
              subtitle: Text(user['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      user['active'] ? Icons.toggle_on : Icons.toggle_off,
                      color: user['active'] ? Theme.of(context).colorScheme.primary : Colors.grey,
                      size: 40,
                    ),
                    onPressed: () => _toggleActive(index),
                    tooltip: user['active'] ? 'Desativar' : 'Ativar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showUserDialog(user: user, index: index),
                    tooltip: 'Editar',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
