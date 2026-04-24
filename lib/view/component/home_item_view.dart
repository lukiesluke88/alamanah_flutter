import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/user.dart';
import '../delete_user_page.dart';

class HomeItemView extends StatelessWidget {
  final User user;
  final int index;
  final VoidCallback refreshUsers;
  final Function(User, int) editUser;

  const HomeItemView({
    super.key,
    required this.user,
    required this.index,
    required this.refreshUsers,
    required this.editUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slidable(
          key: ValueKey(user.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => editUser(user, index),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),

              SlidableAction(
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteUserPage(selectedUser: user),
                    ),
                  ).then((value) {
                    if (value == true) {
                      refreshUsers();
                    }
                  });
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    user.gender == 0
                        ? 'assets/images/female_1.jpeg'
                        : 'assets/images/id_male.jpg',
                  ),
                ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.mobile),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  user.gender == 0
                      ? 'assets/images/female_1.jpeg'
                      : 'assets/images/id_male.jpg',
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: const [
                  Icon(Icons.thumb_up_alt_outlined),
                  SizedBox(width: 4),
                  Text("Like"),
                  SizedBox(width: 24),
                  Icon(Icons.comment_outlined),
                  SizedBox(width: 4),
                  Text("Comment"),
                ],
              ),
            ],
          ),
        ),

        const Divider(thickness: 2),
      ],
    );
  }
}
