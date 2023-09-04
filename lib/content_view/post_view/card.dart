import 'dart:ui';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/components/image_viewer.dart';
import 'package:muffed/components/markdown_body.dart';
import 'package:muffed/components/popup_menu/popup_menu.dart';
import 'package:muffed/global_state/bloc.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:muffed/utils/measure_size.dart';
import 'package:muffed/utils/time.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays a Lemmy post in card format
class CardLemmyPostItem extends StatefulWidget {
  ///
  const CardLemmyPostItem(
    this.post, {
    this.limitContentHeight = true,
    this.openOnTap = true,
    super.key,
  });

  /// The lemmy post
  final LemmyPost post;

  /// Whether the post should open when tapped
  final bool openOnTap;

  /// Whether the height of the text should be capped
  final bool limitContentHeight;

  @override
  State<CardLemmyPostItem> createState() => _CardLemmyPostItemState();
}

class _CardLemmyPostItemState extends State<CardLemmyPostItem> {
  /// The post variable is created in state so that it can be changed by
  /// functions like upVote and downVote.
  late LemmyPost post;

  @override
  void initState() {
    post = widget.post;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // shows nothing if nsfw and show nsfw off
    if (post.nsfw && !context.read<GlobalBloc>().state.showNsfw) {
      return const SizedBox();
    }

    void openPost() {
      context.push('/home/content', extra: post);
    }

    return Card(
      child: InkWell(
        onTap: (widget.openOnTap) ? openPost : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/home/community?id=${post.communityId}');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(45),
                                    child: (post.communityIcon != null)
                                        ? CachedNetworkImage(
                                            imageUrl: post.communityIcon!,
                                          )
                                        : SvgPicture.asset('assets/logo.svg'),
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  post.communityName,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.push(
                                        '/home/person?id=${post.creatorId}');
                                  },
                                  child: Text(
                                    post.creatorName,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          formattedPostedAgo(post.timePublished) + ' ago',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(post.name, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                return Column(
                  children: [
                    if (post.url != null) ...[
                      Builder(
                        builder: (context) {
                          if (post.url!.contains('.jpg') ||
                              post.url!.contains('.png') ||
                              post.url!.contains('.jpeg') ||
                              post.url!.contains('.gif') ||
                              post.url!.contains('.webp') ||
                              post.url!.contains('.bmp')) {
                            return SizedBox(
                              child: Center(
                                child: _ImageViewer(
                                  imageUrl: post.url!,
                                  shouldBlur: post.nsfw &&
                                      context.read<GlobalBloc>().state.blurNsfw,
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.all(4),
                              child: SizedBox(
                                height: 100,
                                child: AnyLinkPreview(
                                  cache: Duration(days: 1),
                                  placeholderWidget: Container(
                                    height: double.maxFinite,
                                    width: double.maxFinite,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: const Center(
                                      child: Text('Loading url data'),
                                    ),
                                  ),
                                  errorImage: 'null',
                                  errorBody: 'Could not load body',
                                  errorTitle: post.name,
                                  errorWidget: GestureDetector(
                                    onTap: () =>
                                        launchUrl(Uri.parse(post.url!)),
                                    child: Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      padding: EdgeInsets.all(4),
                                      child: Text(
                                        post.url!,
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bodyTextOverflow: TextOverflow.fade,
                                  removeElevation: true,
                                  borderRadius: 10,
                                  boxShadow: [],
                                  link: post.url!,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  titleStyle:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    if (post.body != '' && post.body != null) ...[
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: MuffedMarkdownBody(
                              data: post.body!,
                              height: widget.limitContentHeight ? 300 : null,
                              onTapText: () {
                                if (widget.openOnTap) {
                                  openPost();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('${post.commentCount}'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward_outlined),
                        color: (post.myVote == LemmyVoteType.upVote)
                            ? Colors.deepOrange
                            : null,
                        onPressed: () async {
                          // saves what the last vote is in order to reverse
                          // the vote in the state if an error occurs
                          final lastVote = post.myVote;

                          if (post.myVote == LemmyVoteType.upVote) {
                            setState(() {
                              post
                                ..upVotes = post.upVotes - 1
                                ..myVote = LemmyVoteType.none;
                            });
                            try {
                              // tries to change the vote
                              await context
                                  .read<ServerRepo>()
                                  .lemmyRepo
                                  .votePost(
                                    post.id,
                                    LemmyVoteType.none,
                                  );
                            } catch (err) {
                              // reverts the vote state if an error occurs
                              setState(() {
                                post
                                  ..upVotes = post.upVotes + 1
                                  ..myVote = lastVote;
                              });
                            }
                          } else {
                            // If last vote was downVote a downVote should
                            // be taken off.
                            if (post.myVote == LemmyVoteType.downVote) {
                              setState(() {
                                post.downVotes = post.downVotes - 1;
                              });
                            }
                            setState(() {
                              post
                                ..upVotes = post.upVotes + 1
                                ..myVote = LemmyVoteType.upVote;
                            });
                            try {
                              // tries to change the vote
                              await context
                                  .read<ServerRepo>()
                                  .lemmyRepo
                                  .votePost(
                                    post.id,
                                    LemmyVoteType.upVote,
                                  );
                            } catch (err) {
                              // reverts the vote state if an error occurs
                              setState(() {
                                post
                                  ..upVotes = post.upVotes - 1
                                  ..myVote = lastVote;
                              });
                            }
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(post.upVotes.toString()),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward_outlined),
                        color: (post.myVote == LemmyVoteType.downVote)
                            ? Colors.purple
                            : null,
                        onPressed: () async {
                          // saves what the last vote is in order to reverse
                          // the vote in the state if an error occurs
                          final lastVote = post.myVote;

                          if (post.myVote == LemmyVoteType.downVote) {
                            setState(() {
                              post
                                ..downVotes = post.downVotes - 1
                                ..myVote = LemmyVoteType.none;
                            });
                            try {
                              // tries to change the vote
                              await context
                                  .read<ServerRepo>()
                                  .lemmyRepo
                                  .votePost(
                                    post.id,
                                    LemmyVoteType.none,
                                  );
                            } catch (err) {
                              // reverts the vote state if an error occurs
                              setState(() {
                                post
                                  ..downVotes = post.downVotes + 1
                                  ..myVote = lastVote;
                              });
                            }
                          } else {
                            // If last vote was upVote a upVote should
                            // be taken off.
                            if (post.myVote == LemmyVoteType.upVote) {
                              setState(() {
                                post.upVotes = post.upVotes - 1;
                              });
                            }
                            setState(() {
                              post
                                ..downVotes = post.downVotes + 1
                                ..myVote = LemmyVoteType.downVote;
                            });
                            try {
                              // tries to change the vote
                              await context
                                  .read<ServerRepo>()
                                  .lemmyRepo
                                  .votePost(
                                    post.id,
                                    LemmyVoteType.downVote,
                                  );
                            } catch (err) {
                              // reverts the vote state if an error occurs
                              setState(() {
                                post
                                  ..downVotes = post.downVotes - 1
                                  ..myVote = lastVote;
                              });
                            }
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(post.downVotes.toString()),
                      MuffedPopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        items: [
                          MuffedPopupMenuItem(
                            title: 'Debug Info',
                            onTap: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Debug Info'),
                                    content: SelectableText(
                                        'id: ${post.id}\nname: ${post.name}\nbody: ${post.body}\nurl: ${post.url}\nthumb url: ${post.thumbnailUrl}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer(
      {required this.imageUrl, required this.shouldBlur, super.key});

  final String imageUrl;
  final bool shouldBlur;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  double? height;
  late bool shouldBlur;

  @override
  void initState() {
    shouldBlur = widget.shouldBlur;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: shouldBlur
          ? () {
              setState(() {
                shouldBlur = false;
              });
            }
          : null,
      child: AnimatedSize(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        child: SizedBox(
          height: height,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            imageBuilder: (context, imageProvider) {
              UniqueKey heroTag = UniqueKey();
              return GestureDetector(
                // if should blur is on a tap should remove the blur and a
                // second tap should open the image
                onTap: (!shouldBlur)
                    ? () {
                        openImageViewer(
                            context, imageProvider, heroTag, DisposeLevel.low);
                      }
                    : null,

                child: MeasureSize(
                  onChange: (size) {
                    setState(() {
                      height = size.height;
                    });
                  },
                  child: ClipRect(
                    child: ImageFiltered(
                      enabled: shouldBlur,
                      imageFilter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Hero(
                        tag: heroTag,
                        child: Image(
                          image: imageProvider,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            placeholder: (context, url) {
              // width is double.maxFinite to make image not animate the
              // width changing size but instead only animate the height
              return SizedBox(
                height: 300,
                width: double.maxFinite,
              );
            },
          ),
        ),
      ),
    );
  }
}
