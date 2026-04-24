import 'dart:async';

import 'package:alamanah/model/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/user_viewmodel.dart';

class UpdateUserPage extends StatefulWidget {
  final User user;

  const UpdateUserPage({super.key, required this.user});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _mobileController;
  late TextEditingController _mobileDescription;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.name);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _mobileController = TextEditingController(text: widget.user.mobile);
    _mobileDescription = TextEditingController(text: widget.user.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _mobileDescription.dispose();
    super.dispose();
  }

  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedUser = User(
      id: widget.user.id,
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: widget.user.gender,
      email: _emailController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      mobile: _mobileController.text.trim(),
      description: _mobileDescription.text.trim(),
    );

    try {
      await context.read<UserViewModel>().updateUser(updatedUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Update")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                    v == null || v.isEmpty ? "Name required" : null,
                decoration: _inputDecoration("Name"),
              ),

              const SizedBox(height: 10),

              // LAST NAME
              TextFormField(
                controller: _lastNameController,
                validator: (v) =>
                    v == null || v.isEmpty ? "Last name required" : null,
                decoration: _inputDecoration("Last Name"),
              ),

              const SizedBox(height: 10),

              // AGE
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Age required" : null,
                decoration: _inputDecoration("Age"),
              ),

              const SizedBox(height: 10),

              // EMAIL
              TextFormField(
                controller: _emailController,
                validator: (v) =>
                    v == null || v.isEmpty ? "Email required" : null,
                decoration: _inputDecoration("Email"),
              ),

              const SizedBox(height: 10),

              // MOBILE
              TextFormField(
                controller: _mobileController,
                decoration: _inputDecoration("Mobile"),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _mobileDescription,
                maxLines: 4,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description (recommended)",
                  hintText:
                      "Summarise your responsibilities, skills and achievements.",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : saveUser,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
