import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muffed/pages/community/community.dart';
import 'package:muffed/pages/search/search.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:muffed/router/models/extensions.dart';
import 'package:muffed/widgets/snackbars.dart';

void openSearchDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return BlocProvider(
        create: (context) => SearchBloc(
          repo: context.read<ServerRepo>(),
        ),
        child: const _SearchDialog(),
      );
    },
  );
}

class _SearchDialog extends StatelessWidget {
  const _SearchDialog();

  @override
  Widget build(BuildContext context) {
    final textFocusNode = FocusNode();
    final textController = TextEditingController();

    return Builder(builder: (context) {
      return Dialog(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomCenter,
        insetPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: BlocConsumer<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state.error != null) {
              showErrorSnackBar(context, error: state.error);
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
                      clipBehavior: Clip.hardEdge,
                      itemCount: state.communities.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            if (state.communities.length - 1 == index)
                              const SizedBox(
                                height: 8,
                              ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.push(
                                  CommunityPage(
                                    community: state.communities[index],
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(45),
                                        child: (state.communities[index].icon !=
                                                null)
                                            ? Image.network(
                                                '${state.communities[index].icon!}?thumbnail=50',
                                              )
                                            : Image.asset(
                                                'assets/logo.png',
                                              ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.communities[index].name,
                                        ),
                                        Text(
                                          '${state.communities[index].subscribers} subscribers',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
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
                      context.read<SearchBloc>().add(
                            SearchQueryChanged(
                              searchQuery: query,
                            ),
                          );
                    },
                    autofocus: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          textFocusNode.unfocus();
                          Navigator.pop(context);
                          context.push(SearchPage(initialState: state));
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
                    child: (state.isLoading)
                        ? const LinearProgressIndicator()
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}