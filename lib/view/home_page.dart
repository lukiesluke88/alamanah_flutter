import 'package:alamanah/view/update_user_page.dart';
import 'package:alamanah/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'component/home_item_view.dart';
import '../viewmodels/user_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<UserViewModel>().loadUsers());
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    context.read<UserViewModel>().search(value);
  }

  void _editUser(User user, int index) async {
    final updatedUser = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            UpdateUserPage(user: user),
      ),
    );

    if (updatedUser != null) {
      context.read<UserViewModel>().loadUsers();
    }
  }

  Future<void> _refreshUsers() async {
    await context.read<UserViewModel>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      body: Column(
        children: [
          // 🔹 Search Box
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.users.isEmpty
                ? const Center(child: Text("No users found."))
                : RefreshIndicator(
              onRefresh: _refreshUsers,
              child: SlidableAutoCloseBehavior(
                child: ListView.builder(
                  itemCount: vm.users.length,
                  itemBuilder: (context, index) {
                    final user = vm.users[index];
                    return HomeItemView(
                      user: user,
                      index: index,
                      refreshUsers: _refreshUsers,
                      editUser: _editUser,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}