import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muffed/view/widgets/content_scroll_view/widgets/widgets.dart';

enum PagedScrollViewStatus {
  idle,
  loading,
  failure,
  loadingMore,
  loadingMoreFailure,
}

class PagedScroll<T> extends StatelessWidget {
  const PagedScroll({
    required this.status,
    required this.items,
    required this.itemBuilder,
    this.headerSlivers = const [],
    this.scrollController,
    this.onRefresh = PagedScrollView._defaultOnRefresh,
    this.loadMoreCallback = PagedScrollView._defaultLoadMoreCallback,
    this.allPagesLoaded = false,
    this.seperatorBuilder = _defaultSeperatorBuilder,
    super.key,
  });

  final PagedScrollViewStatus status;
  final List<T>? items;
  final Widget Function(BuildContext, T) itemBuilder;
  final List<Widget> headerSlivers;
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  final void Function() loadMoreCallback;
  final bool allPagesLoaded;
  final Widget? Function(BuildContext, int) seperatorBuilder;

  static Widget? _defaultSeperatorBuilder(BuildContext context, int index) =>
      const SizedBox();

  @override
  Widget build(BuildContext context) {
    var bodyMode = ScrollBodyMode.content;
    var footerMode = ScrollFooterMode.hidden;
    var showLoadingIndicator = false;

    final bool hasItems = items != null && items!.isNotEmpty;
    final bool itemsEmpty = items != null && items!.isEmpty;

    if (hasItems) {
      bodyMode = ScrollBodyMode.content;
      if (status == PagedScrollViewStatus.loading) {
        showLoadingIndicator = true;
      }
    } else {
      if (status == PagedScrollViewStatus.failure) {
        bodyMode = ScrollBodyMode.failure;
      }
      if (status == PagedScrollViewStatus.loading) {
        bodyMode = ScrollBodyMode.loading;
      }
    }

    if (allPagesLoaded) {
      footerMode = ScrollFooterMode.reachedEnd;
    }
    if (status == PagedScrollViewStatus.loadingMore) {
      footerMode = ScrollFooterMode.loading;
    }
    if (status == PagedScrollViewStatus.loadingMoreFailure) {
      footerMode = ScrollFooterMode.failure;
    }

    return PagedScrollView(
      indicateLoading: showLoadingIndicator,
      footer: ScrollFooter(
        displayMode: footerMode,
      ),
      body: ScrollBody(
        contentSliver: SliverList.separated(
          separatorBuilder: seperatorBuilder,
          itemCount: items?.length ?? 0,
          itemBuilder: (context, index) => itemBuilder(context, items![index]),
        ),
        mode: bodyMode,
      ),
      headerSlivers: headerSlivers ?? const [],
      onRefresh: onRefresh,
      loadMoreCallback: loadMoreCallback,
      controller: scrollController,
    );
  }
}

class PagedScrollView extends StatefulWidget {
  const PagedScrollView({
    this.body,
    this.footer,
    this.headerSlivers = const [],
    this.controller,
    this.loadMoreThreshold = 500,
    this.loadMoreCallback = _defaultLoadMoreCallback,
    this.onRefresh = _defaultOnRefresh,
    this.indicateLoading = false,
    super.key,
  });

  final List<Widget> headerSlivers;
  final Widget? body;
  final Widget? footer;
  final ScrollController? controller;
  final bool indicateLoading;

  final double loadMoreThreshold;
  final void Function() loadMoreCallback;

  final Future<void> Function() onRefresh;

  static void _defaultLoadMoreCallback() {}

  static Future<void> _defaultOnRefresh() {
    return SynchronousFuture(null);
  }

  @override
  State<PagedScrollView> createState() => _PagedScrollViewState();
}

class _PagedScrollViewState extends State<PagedScrollView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification notification) {
    final maxScrollExtent = notification.metrics.maxScrollExtent;
    final currentScrollExtent = notification.metrics.pixels;

    final isScrollOverThreshold =
        currentScrollExtent >= maxScrollExtent - widget.loadMoreThreshold;

    if (isScrollOverThreshold) {
      widget.loadMoreCallback();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: NotificationListener(
            onNotification: onScrollNotification,
            child: CustomScrollView(
              cacheExtent: 1000,
              controller: widget.controller,
              slivers: [
                ...widget.headerSlivers,
                if (widget.body != null) widget.body!,
                if (widget.footer != null) widget.footer!,
              ],
            ),
          ),
        ),
        if (widget.indicateLoading)
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
