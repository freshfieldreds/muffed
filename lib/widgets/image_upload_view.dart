import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muffed/repo/pictrs/models.dart';
import 'package:muffed/widgets/icon_button.dart';
import 'package:muffed/widgets/snackbars.dart';

/// A widget that displays uploaded images and their upload progress.
class ImageUploadView extends StatelessWidget {
  const ImageUploadView({
    required this.images,
    required this.onDelete,
    super.key,
  });

  final SplayTreeMap<int, ImageUploadState> images;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(images.length, (index) {
            final item = images[images.keys.toList()[index]]!;
            return Container(
              padding: const EdgeInsets.only(left: 4),
              decoration: (item.imageName == null)
                  ? null
                  : BoxDecoration(
                      image: DecorationImage(
                        opacity: 0.5,
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          item.imageLink!,
                        ),
                      ),
                    ),
              child: Row(
                children: [
                  Text(
                    item.id.toString(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (item.imageLink == null)
                    const IconButtonLoading()
                  else
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: '![](${item.imageLink!})',
                          ),
                        );
                        if (!context.mounted) return;
                        showInfoSnackBar(
                          context,
                          text: 'Copied image URL to clipboard',
                        );
                      },
                    ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: item.uploadProgress,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: (item.deleteToken == null)
                        ? null
                        : () {
                            showDialog<void>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete image?'),
                                  content: const Text(
                                    'Are you sure you want to delete this image from the server?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );
                                        onDelete(item.id!);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                  ),
                ],
              ),
            );
          }),
          //Divider(),
        ],
      ),
    );
  }
}
