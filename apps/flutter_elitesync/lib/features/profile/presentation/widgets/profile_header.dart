import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.nickname, required this.city});

  final String nickname;
  final String city;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
      title: Text(nickname),
      subtitle: Text(city),
    );
  }
}
