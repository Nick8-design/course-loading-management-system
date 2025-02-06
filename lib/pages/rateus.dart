import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/app_bar.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';

class RateUsPage extends StatefulWidget {


  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const RateUsPage({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    // required this.isAdmin
  });


  @override
  _RateUsPageState createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  int _selectedRating = 0; // Default rating
  final TextEditingController _feedbackController = TextEditingController();

  /// 📌 **Submit Feedback to Firestore**
  void _submitFeedback() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a rating!")));
      return;
    }

    await FirebaseFirestore.instance.collection('feedback').add({
      'rating': _selectedRating,
      'feedback': _feedbackController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thank you for your feedback!")));

    setState(() {
      _selectedRating = 0;
      _feedbackController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: 'Rate Us',
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("How would you rate your experience?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildStarRating(),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: "Leave a comment (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text("Submit"),
              onPressed: _submitFeedback,
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Star Rating Widget**
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            size: 40,
            color: index < _selectedRating ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _selectedRating = index + 1;
            });
          },
        );
      }),
    );
  }
}
