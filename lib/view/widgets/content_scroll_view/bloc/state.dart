part of 'bloc.dart';

enum ContentScrollStatus { initial, loading, success, failure }

final class ContentScrollState extends Equatable {
  ///
  const ContentScrollState({
    required this.status,
    required this.retrieveContent,
    this.content,
    this.isRefreshing = false,
    this.pagesLoaded = 0,
    this.isLoadingMore = false,
    this.error,
    this.reachedEnd = false,
    this.isLoading = false,
    ContentRetriever? loadedRetrieveContent,
  }) : loadedRetrieveContent = loadedRetrieveContent ?? retrieveContent;

  final ContentScrollStatus status;
  final List<Object>? content;
  final bool isRefreshing;
  final int pagesLoaded;
  final bool isLoadingMore;

  /// If status set to failure error message should display instead of posts.
  /// If status is success the error message should appear as a snack bar so
  /// the posts are still visible.
  final Object? error;

  final bool reachedEnd;

  final ContentRetriever retrieveContent;
  final ContentRetriever loadedRetrieveContent;

  final bool isLoading;

  @override
  List<Object?> get props => [
        content,
        status,
        isRefreshing,
        pagesLoaded,
        isLoadingMore,
        error,
        reachedEnd,
        retrieveContent,
        isLoading,
        loadedRetrieveContent,
      ];

  ContentScrollState copyWith({
    Object? error,
    ContentScrollStatus? status,
    List<Object>? content,
    bool? isRefreshing,
    int? pagesLoaded,
    bool? reachedEnd,
    ContentRetriever? retrieveContent,
    ContentRetriever? loadedRetrieveContent,
    bool? isLoading,
    bool? isLoadingMore,
  }) {
    return ContentScrollState(
      error: error,
      status: status ?? this.status,
      content: content ?? this.content,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      pagesLoaded: pagesLoaded ?? this.pagesLoaded,
      reachedEnd: reachedEnd ?? this.reachedEnd,
      retrieveContent: retrieveContent ?? this.retrieveContent,
      loadedRetrieveContent:
          loadedRetrieveContent ?? this.loadedRetrieveContent,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
