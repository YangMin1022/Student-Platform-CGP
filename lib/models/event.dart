
// lib/model/event.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String date;
  final String time;
  final String organizer;
  final String location;
  final String imageUrl;
  final String registrationUrl;
  final String description;
  final String eventFee;
  final String eventTransportation;
  final String eventCategory;
  final String googleFormLink;
  final String numParticipant;
  final String clubId;     // id of the parent club
  final String clubName;   // optional display

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.organizer,
    required this.location,
    required this.imageUrl,
    required this.registrationUrl,
    required this.description,
    required this.eventFee,
    required this.eventTransportation,
    required this.eventCategory,
    required this.googleFormLink,
    required this.numParticipant,
    required this.clubId,
    required this.clubName,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Firestore adds a special field "__name__" in document snapshot's reference,
    // but to get the parent path we can use doc.reference.parent.parent.id
    final parentClubId = doc.reference.parent.parent?.id ?? '';
    return Event(
      title: data['eventName']             ?? 'No Title',
      date: data['eventDate']               ?? 'No Date',
      time: data['eventTime']               ?? '',
      organizer: data['eventOrganizer']     ?? '',
      location: data['eventVenue']          ?? '',
      imageUrl: data['eventCoverPic']       ?? '',
      registrationUrl: data['googleFormLink'] ?? '',
      description: data['eventDescription'] ?? '',
      eventFee: data['eventFee']            ?? 'N/A',
      eventTransportation:
          data['eventTransportation']       ?? 'N/A',
      eventCategory: data['eventCategory']  ?? 'N/A',
      googleFormLink: data['googleFormLink']?? 'N/A',
      numParticipant: data['numParticipants']?? 'N/A',
      clubId: parentClubId,
      clubName: data['clubName']            ?? 'Unknown Club',
    );
  }
}
