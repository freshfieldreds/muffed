import 'package:equatable/equatable.dart';
import 'package:muffed/repo/lemmy/models/user.dart';
import 'package:muffed/repo/server_repo.dart';

abstract class ContentRetrieverDelegate<Data> extends Equatable {
  const ContentRetrieverDelegate();

  Future<List<Data>> retrieveContent({required int page});

  /// Function used to check if there are no more pages to be loaded
  bool hasReachedEnd(
      {required List<Data> oldContent, required List<Data> newContent,}) {
    final combinedContent = {...oldContent, ...newContent}.toList();

    return combinedContent.length == oldContent.length;
  }

  @override
  List<Object?> get props => [];
}

class UserContentRetriever
    extends ContentRetrieverDelegate<LemmyGetPersonDetailsResponse> {
  const UserContentRetriever({
    required this.repo,
    this.userId,
    this.username,
  }) : assert(userId != null || username != null, 'no user was provided');

  final int? userId;
  final String? username;
  final ServerRepo repo;

  @override
  Future<List<LemmyGetPersonDetailsResponse>> retrieveContent({
    int page = 1,
  }) async {
    final response = await repo.lemmyRepo.getPersonDetails(
      id: userId,
      username: username,
      page: page,
    );

    return [response];
  }

  @override
  bool hasReachedEnd({
    required List<LemmyGetPersonDetailsResponse> oldContent,
    required List<LemmyGetPersonDetailsResponse> newContent,
  }) =>
      newContent.first.posts.isEmpty && newContent.first.comments.isEmpty;
}
