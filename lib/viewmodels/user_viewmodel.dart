import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../model/user.dart';
import '../services/user_firebase_service.dart';

class UserViewModel extends ChangeNotifier {
  final _service = UserFirebaseService();

  List<User> users = [];
  bool isLoading = false;

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();

    users = await _service.getUsers();

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    await _service.updateUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await _service.deleteUser(id);
    await loadUsers();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    users = await _service.searchUsers(query);
    notifyListeners();
  }

  // -----------------------------
  // REGISTER USER (NOW CLEAN)
  // -----------------------------
  Future<bool> registerUser(User user, File? imageFile) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.registerUser(user, imageFile);

    await loadUsers();

    isLoading = false;
    notifyListeners();

    return result;
  }
}
