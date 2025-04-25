import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'models/event.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;
  final String role;
  const EventDetailsPage({super.key, required this.event, required this.role});

  Future<void> _launchForm(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the form.')),
      );
    }
  }

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
    final bool isGuest = role == 'guest';

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
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    width: double.infinity,
                    height: 240,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (ctx, url, error) => const Icon(Icons.broken_image, size: 50),
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
                  onPressed: isGuest
                  ? null
                  : () => _launchForm(context, event.googleFormLink),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isGuest ? Colors.grey : Theme.of(context).primaryColor,
                  ),
                  child: Text(isGuest ? "Login to Register" : "Register",style: TextStyle(color: isGuest ? Colors.black38 : Colors.white,),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
