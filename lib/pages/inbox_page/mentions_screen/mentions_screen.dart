import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muffed/components/comment_item/comment_item.dart';
import 'package:muffed/components/error.dart';
import 'package:muffed/components/muffed_page.dart';
import 'package:muffed/dynamic_navigation_bar/dynamic_navigation_bar.dart';

import 'bloc/bloc.dart';

class MentionsScreen extends StatelessWidget {
  const MentionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MentionsBloc, MentionsState>(
      builder: (context, state) {
        return SetPageInfo(
          actions: [],
          indexOfRelevantItem: 1,
          child: Builder(
            builder: (context) {
              if (state.replyItemsStatus == MentionsStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (state.replyItemsStatus == MentionsStatus.failure) {
                return ErrorComponentTransparent(
                  message: state.error,
                  retryFunction: () =>
                      context.read<MentionsBloc>().add(Initialize()),
                );
              } else if (state.replyItemsStatus == MentionsStatus.success) {
                return MuffedPage(
                  isLoading: state.isLoading,
                  error: state.error,
                  child: ListView(
                    children: List.generate(
                      state.replyItems.length,
                      (index) => CommentItem(
                        comment: state.replyItems[index],
                        isOrphan: true,
                        displayAsSingle: true,
                        sortType: state.sortType,
                        ableToLoadChildren: false,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        );
      },
    );
  }
}