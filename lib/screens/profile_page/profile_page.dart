import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muffed/global_state/bloc.dart';
import 'account_switcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.read<GlobalBloc>();

    return BlocBuilder<GlobalBloc, GlobalState>(
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 50,
                    ),
                    TextButton(
                      onPressed: () => showAccountSwitcher(context),
                      child: Row(
                        children: [
                          Text(
                            globalBloc.getSelectedLemmyAccount()?.name ??
                                'Anonymous',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const Icon(Icons.arrow_drop_down_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (context.read<GlobalBloc>().isLoggedIn())
                      ElevatedButton(
                        onPressed: () {
                          // TODO: add navigation
                        },
                        child: const Text('Show saved posts'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}