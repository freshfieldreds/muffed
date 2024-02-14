import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/domain/server_repo.dart';
import 'package:muffed/view/pages/community_screen/community_screen.dart';
import 'package:muffed/view/pages/search/controller/controller.dart';
import 'package:muffed/view/widgets/community/community.dart';
import 'package:muffed/view/widgets/snackbars.dart';

void openSearchDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return Builder(
        builder: (context) {
          return SearchDialog();
        },
      );
    },
  );
}

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final textFocusNode = FocusNode();
  final textController = TextEditingController();

  final sortType = LemmySortType.topAll;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(
        searchType: SearchType.communities,
        lemmyRepo: context.read<ServerRepo>().lemmyRepo,
      ),
      child: Dialog(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomCenter,
        insetPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: BlocConsumer<SearchCubit, SearchModel>(
          listener: (context, state) {
            if (state.status == SearchStatus.failure &&
                state.errorMessage != null) {
              showErrorSnackBar(context, error: state.errorMessage);
            }
          },
          builder: (context, state) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: state.items.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CommunityListTile(
                          state.items[index] as LemmyCommunity,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  TextField(
                    focusNode: textFocusNode,
                    controller: textController,
                    onChanged: (query) {
                      context.read<SearchCubit>().search(
                            query: textController.text,
                            sortType: sortType,
                          );
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          textFocusNode.unfocus();
                          context.push(
                            '/home/search?query=${textController.text}',
                            extra: state,
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.open_in_new),
                      ),
                      prefixIcon: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      hintText: 'Search',
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                    child: (state.status == SearchStatus.loading)
                        ? const LinearProgressIndicator()
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
