import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/user_dao.dart';

final selectedNameProvider=StateProvider<String>((ref)=>'Admin');

final userDaoProvider = ChangeNotifierProvider<UserDao>((ref) {
  return UserDao();
});

final dashboardDataProvider = FutureProvider((ref) async {
  final db = FirebaseFirestore.instance;
  final instructors = await db.collection('instructors').get();
  final courses = await db.collection('courses').get();
  final conflicts = await db.collection('conflicts').get();
  final reports = await db.collection('reports').get();

  return {
    'instructors': instructors.size,
    'courses': courses.size,
    'conflicts': conflicts.size,
    'reports': reports.size,
  };
});