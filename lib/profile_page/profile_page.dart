import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/dynamic_navigation_bar/dynamic_navigation_bar.dart';
import 'package:muffed/global_state/bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.read<GlobalBloc>();

    void showAccountSwitcher() {
      showModalBottomSheet<void>(
        useRootNavigator: true,
        context: context,
        builder: (context) {
          return BlocBuilder<GlobalBloc, GlobalState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...List.generate(globalBloc.state.lemmyAccounts.length,
                      (index) {
                    return ListTile(
                      title: Text(
                        globalBloc.state.lemmyAccounts[index].userName,
                      ),
                      leading: const Icon(Icons.account_circle),
                      trailing: IconButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirm Removal'),
                                content: Text(
                                    'Are you sure you want to remove ${globalBloc.state.lemmyAccounts[index].userName}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      globalBloc.add(
                                        UserRequestsAccountRemoval(
                                          index,
                                        ),
                                      );
                                      context.pop();
                                    },
                                    child: const Text('Remove'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.remove_circle),
                      ),
                      onTap: () {
                        context.pop();
                        globalBloc.add(
                          UserRequestsLemmyAccountSwitch(
                            index,
                          ),
                        );
                      },
                    );
                  }),
                  ListTile(
                    title: const Text('Anonymous'),
                    leading: const Icon(Icons.security),
                    onTap: () {
                      context.pop();
                      globalBloc.add(
                        UserRequestsLemmyAccountSwitch(-1),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Add Account'),
                    leading: const Icon(Icons.add),
                    onTap: () {
                      context
                        ..pop()
                        ..go('/profile/login');
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return SetPageInfo(
      indexOfRelevantItem: 2,
      actions: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {
            context.push('/profile/settings');
          },
          icon: const Icon(Icons.settings),
        ),
      ],
      child: BlocBuilder<GlobalBloc, GlobalState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                ),
                TextButton(
                  onPressed: showAccountSwitcher,
                  child: Text(
                    globalBloc.getSelectedLemmyAccount()?.userName ??
                        'Anonymous',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
