part of 'bloc.dart';

sealed class ContentScrollEvent {}

final class Initialise extends ContentScrollEvent {}

final class PullDownRefresh extends ContentScrollEvent {}

final class ReachedNearEndOfScroll extends ContentScrollEvent {}

final class RetrieveContentFunctionChanged extends ContentScrollEvent {
  RetrieveContentFunctionChanged(this.retrieveContent);

  final ContentRetriever retrieveContent;
}
