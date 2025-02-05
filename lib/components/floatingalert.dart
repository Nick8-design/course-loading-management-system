import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class Floatingalert extends StatelessWidget {

@override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => GoRouter.of(context).go('/conflicts'),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').where(
            'hasConflict', isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          int conflictCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return Stack(
            children: [
              Icon(Icons.notifications),
              if (conflictCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 10,
                    child: Text('$conflictCount',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}