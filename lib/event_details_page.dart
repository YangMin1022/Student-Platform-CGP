import 'package:flutter/material.dart';
import 'events_page.dart';
import 'event_registration_form.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event cover image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/badminton_tournament.jpg', fit: BoxFit.cover);
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Event title
              Text(event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              // Date and time
              Text("${event.date} @ ${event.time}", style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 5),
              // Organizer
              Text("Organized by: ${event.organizer}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 5),
                  Text(event.location, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),
              // Event description
              Text(event.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              // Additional Event Details
              _buildDetailRow(Icons.money, "Fee", event.eventFee),
              _buildDetailRow(Icons.directions_bus, "Transportation", event.eventTransportation),
              _buildDetailRow(Icons.category, "Category", event.eventCategory),
              _buildDetailRow(Icons.link, "Google Form", event.googleFormLink),
              _buildDetailRow(Icons.group, "Participants", event.numParticipant),
              const SizedBox(height: 20),
              // Register Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventRegistrationForm(
                          eventTitle: event.title,
                          onRegistered: () {
                            // Optionally update registration status in the app
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
