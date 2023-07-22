part of 'bloc.dart';

enum HomePageStatus { initial, loading, success, failure }

final class HomePageState extends Equatable {
  final HomePageStatus status;
  final List? posts;
  final bool isRefreshing;
  final int pagesLoaded;
  final bool isLoadingMore;
  final String? errorMessage;

  HomePageState({
    required this.status,
    this.posts,
    this.isRefreshing = false,
    this.pagesLoaded = 1,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [posts, status, isRefreshing, pagesLoaded, isLoadingMore, errorMessage];

  HomePageState copyWith({
    String? errorMessage,
    HomePageStatus? status,
    List? posts,
    bool? isRefreshing,
    int? pagesLoaded,
    bool? isLoadingMore,
  }) {
    return HomePageState(
      errorMessage: errorMessage,
      status: status ?? this.status,
      posts: posts ?? this.posts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      pagesLoaded: pagesLoaded ?? this.pagesLoaded,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
