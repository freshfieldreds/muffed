import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/global_state/bloc.dart';

class ContentFiltersPage extends StatelessWidget {
  const ContentFiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Content Filters'),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          children: [
            SwitchListTile(
                title: Text('Show NSFW posts'),
                value: state.showNsfw,
                onChanged: (value) {
                  context.read<GlobalBloc>().add(ShowNsfwChanged(value));
                }),
            if (state.showNsfw)
              SwitchListTile(
                  title: Text('Blur NSFW posts'),
                  value: state.blurNsfw,
                  onChanged: (value) {
                    context.read<GlobalBloc>().add(BlurNsfwChanged(value));
                  }),
          ],
        ),
      );
    });
  }
}