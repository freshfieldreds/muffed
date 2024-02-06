part of 'bloc.dart';

sealed class MentionsEvent {}

class Initialize extends MentionsEvent {}

class ReachedEndOfScroll extends MentionsEvent {}

class ShowAllToggled extends MentionsEvent {}

class Refresh extends MentionsEvent {}

class MarkAsReadToggled extends MentionsEvent {
  MarkAsReadToggled({required this.id, required this.index});

  final int id;
  final int index;
}