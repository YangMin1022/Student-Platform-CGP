import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsertDiscoverPage extends StatefulWidget {
  const InsertDiscoverPage({Key? key}) : super(key: key);

  @override
  State<InsertDiscoverPage> createState() => _InsertDiscoverPageState();
}

class _InsertDiscoverPageState extends State<InsertDiscoverPage> {
  // Controllers for text fields for discover content and image URL.
  final TextEditingController _discoverImageUrlController = TextEditingController();
  final TextEditingController _discoverContentController = TextEditingController();

  // For club selection
  String? _selectedClubId;
  String? _selectedClubName;
  List<Map<String, dynamic>> _clubs = [];

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Fetch clubs from Firestore and store in _clubs list.
  Future<void> _fetchClubs() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('clubs').get();
    setState(() {
      _clubs = snapshot.docs.map((doc) {
        Map data = doc.data() as Map<String, dynamic>;
        return {
          'clubId': doc.id,
          'clubName': data['clubName'] ?? 'Unnamed Club',
          'presidentEmail': data['presidentEmail'] ?? '', // Make sure each club doc has this field.
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _submitDiscover() async {
    if (!_formKey.currentState!.validate() || _selectedClubId == null) return;

    // Get current user email
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not signed in.")),
      );
      return;
    }
    String currentUserEmail = currentUser.email ?? '';

    // Retrieve the club document to check the president's email.
    DocumentSnapshot clubDoc = await FirebaseFirestore.instance.collection('clubs').doc(_selectedClubId).get();
    if (!clubDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected club not found.")),
      );
      return;
    }
    String clubPresidentEmail = clubDoc.get('presidentEmail'); // Ensure this field exists.
    
    // For non-admins: check if current user's email matches the club president email.
    // (You may want to add additional logic if you maintain an admin flag as well.)
    // In this example, we assume that only the club president (or admin) can submit.
    if (currentUserEmail.toLowerCase() != clubPresidentEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only the club president can add a discover post for this club.")),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(_selectedClubId)
          .collection('discover')
          .add({
        'discoverImageUrl': _discoverImageUrlController.text.trim(),
        'discoverContent': _discoverContentController.text.trim(),
        'clubName': _selectedClubName, // stored for reference
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discover added successfully!')),
      );

      // Clear all fields after successful submission.
      _discoverImageUrlController.clear();
      _discoverContentController.clear();
      setState(() {
        _selectedClubId = null;
        _selectedClubName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Discover: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildClubDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Club",
        border: OutlineInputBorder(),
      ),
      value: _selectedClubId,
      items: _clubs.map((club) {
        return DropdownMenuItem<String>(
          value: club['clubId'],
          child: Text(club['clubName']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClubId = value;
          _selectedClubName = _clubs.firstWhere((club) => club['clubId'] == value)['clubName'];
        });
      },
      validator: (value) => value == null ? "Please select a club" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insert Discover'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            _buildClubDropdown(),
            const SizedBox(height: 20),
            _buildTextField('Image URL', _discoverImageUrlController),
            _buildTextField('Discover Content', _discoverContentController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitDiscover,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
