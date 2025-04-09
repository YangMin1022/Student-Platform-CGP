import 'package:flutter/material.dart';

class ClubDetailsPage extends StatelessWidget {
  final String clubName;
  final String description;
  final String imagePath;
  final String activities;
  final String picName;
  final String picContact;
  final String picPosition;

  const ClubDetailsPage({
    Key? key,
    required this.clubName,
    required this.description,
    required this.imagePath, 
    required this.activities,
    required this.picName,
    required this.picContact,
    required this.picPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clubName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imagePath,
                width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),),
            const SizedBox(height: 15),
            Text(clubName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('Activities :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(activities),

            const SizedBox(height: 20),
            Text('Person In Charge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Name : $picName"),
            Text("Position : $picPosition"),
            Text("Contact : $picContact"),
          ],
        ),
      ),
    );
  }
}
