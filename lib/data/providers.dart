import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/user_dao.dart';

final selectedNameProvider=StateProvider<String>((ref)=>'Admin');

final userDaoProvider = ChangeNotifierProvider<UserDao>((ref) {
  return UserDao();
});