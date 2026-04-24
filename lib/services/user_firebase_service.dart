import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../model/user.dart';

class UserFirebaseService {
  final _users = FirebaseFirestore.instance.collection('users');

  // -----------------------------
  // CREATE / REGISTER USER
  // (Firestore auto-ID supported)
  // -----------------------------
  Future<bool> registerUser(User user, File? imageFile) async {
    try {
      final docRef = _users.doc();
      final userId = docRef.id;

      String? imageUrl;

      if (imageFile != null) {
        // 🔥 compress first
        final compressedFile = await _compressImage(imageFile);

        // fallback if compression fails
        final fileToUpload = compressedFile ?? imageFile;

        imageUrl = await uploadImage(fileToUpload, userId);
      }

      final newUser = user.copyWith(
        id: userId,
        imageUrl: imageUrl,
      );

      await docRef.set({
        'name': newUser.name,
        'lastName': newUser.lastName,
        'age': newUser.age,
        'gender': newUser.gender,
        'mobile': newUser.mobile,
        'email': newUser.email,
        'imageUrl': imageUrl,
        'description': newUser.description,

        'searchKeywords': User.generateSearchKeywords(
          user.name,
          user.lastName,
          user.mobile,
        ),

        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // -----------------------------
  // GET ALL USERS (DESC ORDER)
  // -----------------------------
  Future<List<User>> getUsers() async {
    final snapshot = await _users.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => User.fromJson(doc.data(), doc.id))
        .toList();
  }

  // -----------------------------
  // UPDATE USER
  // -----------------------------
  Future<void> updateUser(User user) async {
    await _users.doc(user.id).update({
      'name': user.name,
      'lastName': user.lastName,
      'age': user.age,
      'gender': user.gender,
      'mobile': user.mobile,
      'email': user.email,
      'imageUrl': user.imageUrl,
      'description': user.description,

      // 🔥 ALWAYS regenerate keywords on update
      'searchKeywords': User.generateSearchKeywords(
        user.name,
        user.lastName,
        user.mobile,
      ),
    });
  }

  // -----------------------------
  // DELETE USER
  // -----------------------------
  Future<void> deleteUser(String id) async {
    await _users.doc(id).delete();
  }

  // -----------------------------
  // SEARCH USERS
  // -----------------------------
  Future<List<User>> searchUsers(String query) async {
    final q = query.trim().toLowerCase();

    // ✅ if empty → return all users
    if (q.isEmpty) {
      return getUsers();
    }

    final result = await _users.where('searchKeywords', arrayContains: q).get();

    return result.docs.map((doc) => User.fromJson(doc.data(), doc.id)).toList();
  }

  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$userId.jpg');

      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80, // 🔥 adjust (50–80 best range)
      );

      if (compressed == null) return null;

      return File(compressed.path);
    } catch (e) {
      return null;
    }
  }
}
