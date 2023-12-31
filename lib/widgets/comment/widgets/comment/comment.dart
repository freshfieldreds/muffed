import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muffed/global_state/bloc.dart';
import 'package:muffed/pages/community/community.dart';
import 'package:muffed/pages/post_page/view/post_page.dart';
import 'package:muffed/pages/user/user.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:muffed/router/models/models.dart';
import 'package:muffed/utils/time.dart';
import 'package:muffed/widgets/comment/comment.dart';
import 'package:muffed/widgets/create_comment/create_comment_dialog.dart';
import 'package:muffed/widgets/markdown_body.dart';

part 'card_view.dart';
part 'components.dart';
part 'tree_view.dart';

class CommentCardWidget extends StatelessWidget {
  const CommentCardWidget({
    required this.comment,
    this.sortType = LemmyCommentSortType.hot,
    this.children = const [],
    this.trailingPostTitle,
    super.key,
  });

  final LemmyComment comment;
  final List<LemmyComment> children;
  final LemmyCommentSortType sortType;
  final Widget? trailingPostTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: key,
      create: (context) => CommentBloc(
        comment: comment,
        children: children,
        sortType: sortType,
        repo: context.read<ServerRepo>(),
        globalBloc: context.read<GlobalBloc>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              return _CardCommentView(
                trailingPostTitle: trailingPostTitle,
              );
            },
          );
        },
      ),
    );
  }
}

class CommentTreeItemWidget extends StatelessWidget {
  const CommentTreeItemWidget({
    required this.comment,
    required this.children,
    required this.sortType,
    super.key,
  });

  final LemmyComment comment;
  final List<LemmyComment> children;
  final LemmyCommentSortType sortType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: key,
      create: (context) => CommentBloc(
        comment: comment,
        children: children,
        sortType: sortType,
        repo: context.read<ServerRepo>(),
        globalBloc: context.read<GlobalBloc>(),
      ),
      child: Builder(
        builder: (context) {
          return const _TreeCommentView();
        },
      ),
    );
  }
}
