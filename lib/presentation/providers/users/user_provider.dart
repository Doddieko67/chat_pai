import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
User geminiUser(Ref ref) {
  final geminiUser = User(
    id: 'gemini-id',
    firstName: 'TerapIA',
    imageUrl: 'https://picsum.photos/id/179/200/200',
  );

  return geminiUser;
}

@riverpod
User user(Ref ref) {
  final user = User(
    id: 'user-id-abc',
    firstName: 'Fernando',
    lastName: 'Herrera',
    imageUrl: 'https://picsum.photos/id/177/200/200',
  );

  return user;
}
