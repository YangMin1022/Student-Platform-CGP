import 'package:flutter/material.dart';
import 'insert_event.dart';
import 'insert_club.dart';
import 'insert_discover.dart';
class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Page")),
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
          ElevatedButton(
            child: Text("Insert Club"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsertClubPage()),
              );
            },
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
