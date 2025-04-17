import 'package:flutter/material.dart';
import 'insert_event.dart';
import 'insert_club.dart';
import 'insert_discover.dart';
class AdminPage extends StatelessWidget {
  final String role;
  const AdminPage({Key? key, required this.role}) : super(key: key);

  bool get isSystemAdmin => role == 'admin';
  bool get isClubAdmin   => role == 'clubAdmin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome to the Admin Page!"),
          ElevatedButton(
            child: Text("Insert Event"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsertEventPage()),
              );
            },
          ),
          if (isSystemAdmin)
              ElevatedButton(
                child: const Text("Insert Club"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InsertClubPage()),
                ),
              ),
          ElevatedButton(
            child: Text("Insert Discover"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsertDiscoverPage()),
              );
            },
          ),
        ],
      ),
    ),
    );
}
}
