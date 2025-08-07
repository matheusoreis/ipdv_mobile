import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipdv/app/store/role_store.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  final RoleStore store = Get.find<RoleStore>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  int? _editingIndex;

  void _showRoleDialog({Map<String, dynamic>? role, int? index}) {
    if (role != null) {
      _nameController.text = role['name'] ?? '';
      _editingIndex = index;
    } else {
      _nameController.clear();
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_editingIndex == null ? 'Adicionar Cargo' : 'Editar Cargo'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome do Cargo'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
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
              if (_editingIndex == null) {
                await store.addRole({
                  'name': _nameController.text.trim(),
                  'active': true,
                });
              } else {
                await store.updateRole(_editingIndex!, {
                  'name': _nameController.text.trim(),
                  'active': store.roles[_editingIndex!]['active'],
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
        title: const Text('Cargos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoleDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (store.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (store.roles.isEmpty) {
          return const Center(child: Text('Nenhum cargo cadastrado'));
        }
        return ListView.separated(
          itemCount: store.roles.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final role = store.roles[index];
            return ListTile(
              title: Text(role['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      role['active'] ? Icons.toggle_on : Icons.toggle_off,
                      color: role['active'] ? Theme.of(context).colorScheme.primary : Colors.grey,
                      size: 40,
                    ),
                    onPressed: () => _toggleActive(index),
                    tooltip: role['active'] ? 'Desativar' : 'Ativar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showRoleDialog(role: role, index: index),
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
