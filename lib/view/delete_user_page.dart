
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../viewmodels/user_viewmodel.dart';

class DeleteUserPage extends StatelessWidget {
  final User selectedUser;

  const DeleteUserPage({super.key, required this.selectedUser});

  Future<void> _deleteUser(BuildContext context) async {
    final vm = context.read<UserViewModel>();

    try {
      await vm.deleteUser(selectedUser.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedUser.name} deleted successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Delete User')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to delete ${selectedUser.name}?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () => _deleteUser(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
