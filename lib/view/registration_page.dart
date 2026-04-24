import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../viewmodels/user_viewmodel.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();

  int _gender = 0;
  File? _pickedImage;

  // -----------------------------
  // PICK IMAGE (UI ONLY)
  // -----------------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  // -----------------------------
  // REGISTER USING VIEWMODEL
  // -----------------------------
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<UserViewModel>();

    final user = User(
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: _gender,
      email: _emailController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      mobile: _mobileController.text.trim(),
    );

    final success = await vm.registerUser(user, _pickedImage);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully ${user.name} registered.")),
      );

      _clearForm();

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  // -----------------------------
  // CLEAR FORM
  // -----------------------------
  void _clearForm() {
    _nameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _ageController.clear();
    _pickedImage = null;
    _gender = 0;

    setState(() {});
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Register User")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // IMAGE
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.camera_alt)
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                // NAME
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("Name"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 15),

                // LAST NAME
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration("Last Name"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 15),

                // AGE
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Age"),
                ),

                const SizedBox(height: 15),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email"),
                ),

                const SizedBox(height: 15),

                // MOBILE
                TextFormField(
                  controller: _mobileController,
                  decoration: _inputDecoration("Mobile"),
                ),

                const SizedBox(height: 20),

                // BUTTONS
                vm.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text("Register"),
                      ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
