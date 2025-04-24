
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubMembersPage extends StatelessWidget {
  final String clubId;
  const ClubMembersPage({Key? key, required this.clubId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Members'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(clubId)
            .collection('registrations')
            .orderBy('registeredAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No members have joined yet.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['studentName'] ?? '—'),
                subtitle: Text(
                  '${data['studentEmail'] ?? '—'}\nID: ${data['studentId'] ?? '—'}',
                  style: const TextStyle(fontSize: 15),
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
