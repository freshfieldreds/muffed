import 'package:flutter/material.dart';
import 'package:muffed/pages/community/community.dart';
import 'package:muffed/repo/lemmy/models/models.dart';
import 'package:muffed/router/router.dart';
import 'package:muffed/theme/theme.dart';
import 'package:muffed/widgets/muffed_avatar.dart';

/// Shows information about a community in a list tile format
class CommunityListTile extends StatelessWidget {
  const CommunityListTile(
    this.community, {
    super.key,
  });

  factory CommunityListTile.compact(
    LemmyCommunity community, {
    Key? key,
  }) {
    return _CompactCommunityListTile(community, key: key);
  }

  final LemmyCommunity community;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushPage(
          CommunityPage(
            community: community,
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: MuffedAvatar(
                    url: community.icon,
                    radius: 16,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.title,
                        style: context.textTheme.titleMedium,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${community.subscribers}',
                              style: context.textTheme.bodySmall!.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline,
                              ),
                            ),
                            TextSpan(
                              text: ' members ',
                              style: context.textTheme.bodySmall!.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      if (community.description != null)
                        Text(
                          community.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall!.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _CompactCommunityListTile extends CommunityListTile {
  const _CompactCommunityListTile(super.community, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
            context.pushPage(CommunityPage(community: community));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: Row(
              children: [
                MuffedAvatar(
                  url: community.icon,
                  identiconID: community.name,
                  radius: 12,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                    ),
                    Text(
                      '${community.subscribers} members',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colorScheme.outline,
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
  }
}
