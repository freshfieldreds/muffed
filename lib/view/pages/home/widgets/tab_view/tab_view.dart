import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:muffed/domain/lemmy/lemmy.dart';
import 'package:muffed/view/pages/home/home.dart';
import 'package:muffed/view/pages/home/widgets/tab_view/controller.dart';
import 'package:muffed/view/widgets/content_scroll_view/view/view.dart';
import 'package:muffed/view/widgets/post/post_item.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({
    required this.contentType,
    required this.sortType,
    required this.lemmyRepo,
    this.scrollController,
    super.key,
  });

  final HomeContentType contentType;

  final ScrollController? scrollController;

  final SortType sortType;
  final LemmyRepo lemmyRepo;

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  late final HomeTabViewController controller;
  late List<PostView>? items;
  SortType sortType = SortType.active;
  HomeContentType contentType = HomeContentType.popular;
  HomeTabViewStatus status = HomeTabViewStatus.idle;

  @override
  void initState() {
    super.initState();

    contentType = widget.contentType;
    sortType = widget.sortType;

    controller = HomeTabViewController(lemmyRepo: widget.lemmyRepo);
    controller.stream.listen(onStreamEvent);
    onState(controller.state);
    controller.loadInitialContent(sortType: sortType, contentType: contentType);
  }

  Widget itemBuilder(BuildContext context, Object item) {
    if (item is PostView) {
      return PostWidget(
        post: item,
      );
    } else {
      return const SizedBox(
        height: 100,
        width: 200,
        child: Center(
          child: Text('ItemType not recognised'),
        ),
      );
    }
  }

  void onStreamEvent(HomeTabViewModel state) {
    setState(() {
      onState(state);
    });
  }

  void onState(HomeTabViewModel state) {
    items = state.items;
    status = state.status;
  }

  final homeTabToScrollStatus = {
    HomeTabViewStatus.idle: PagedScrollViewStatus.idle,
    HomeTabViewStatus.loading: PagedScrollViewStatus.loading,
    HomeTabViewStatus.failure: PagedScrollViewStatus.failure,
    HomeTabViewStatus.loadingNext: PagedScrollViewStatus.loadingMore,
    HomeTabViewStatus.loadingNextFailure:
        PagedScrollViewStatus.loadingMoreFailure,
  };

  @override
  Widget build(BuildContext context) {
    return PagedScroll(
      onRefresh: () async {
        await controller.loadInitialContent(
          sortType: sortType,
          contentType: contentType,
        );
      },
      status: homeTabToScrollStatus[status]!,
      items: items,
      itemBuilder: itemBuilder,
      loadMoreCallback: controller.loadNextPage,
      scrollController: widget.scrollController,
    );
  }
}
