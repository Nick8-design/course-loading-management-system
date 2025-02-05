import 'package:flutter/material.dart';

class ScheduleOperationWidget extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const ScheduleOperationWidget({
    Key? key,
    required this.name,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16,left: 5,right: 2),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 5),
              blurRadius: 10,
            )
          ],
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
          color: Colors.white,
          border: Border(
            left: BorderSide(color: Colors.yellow, width: 4),
            bottom: BorderSide(color: Colors.yellow, width: 4),
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black), // Icon before the text
            SizedBox(width: 8), // Space between icon and text
            Text(name, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
