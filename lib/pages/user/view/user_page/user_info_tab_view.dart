part of 'user_page.dart';

class _UserInfoTabView extends StatelessWidget {
  _UserInfoTabView({LemmyUser? user})
      : usingPlaceHolderData = user == null,
        user = user ?? LemmyUser.placeHolder();

  final LemmyUser user;
  final bool usingPlaceHolderData;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: usingPlaceHolderData,
      child: CustomScrollView(
        slivers: [
          SliverList.list(
            children: [
              const SizedBox(
                height: _headerMinHeight,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Flexible(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              user.postCount.toString(),
                              style: context.textTheme.displaySmall,
                            ),
                            Text(
                              'Posts',
                              style: context.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              user.commentCount.toString(),
                              style: context.textTheme.displaySmall,
                            ),
                            Text(
                              'Comments',
                              style: context.textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (user.bio != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MuffedMarkdownBody(data: user.bio!),
                ),
              SizedBox(
                height: 8,
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Moderates (${user.moderates!.length})',
                  style: context.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SliverList.builder(
            itemCount: user.moderates!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: MuffedAvatar(
                  url: user.moderates![index].icon,
                  radius: 16,
                ),
                title: Text(
                  user.moderates![index].name,
                ),
                onTap: () {
                  // TODO: add navigation
                },
              );
            },
          ),
        ],
      ),
    );
  }
}