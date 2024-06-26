import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:muffed/view/pages/post_screen/post_screen.dart';
import 'package:muffed/view/router/navigator/navigator.dart';
import 'package:muffed/view/widgets/image.dart';
import 'package:muffed/view/widgets/image_upload_view.dart';
import 'package:muffed/view/widgets/markdown_body.dart';
import 'package:muffed/view/widgets/snackbars.dart';
import 'package:muffed/view/widgets/url_view.dart';

class CreatePostScreen extends StatelessWidget {
  CreatePostScreen({
    required this.communityId,
    super.key,
  })  : bodyTextController = TextEditingController(),
        titleTextController = TextEditingController(),
        urlTextController = TextEditingController(),
        assert(communityId != null);

  /// should be defined if creating a new post
  final int? communityId;

  final TextEditingController bodyTextController;

  final TextEditingController titleTextController;

  final TextEditingController urlTextController;

  final FocusNode bodyTextFocusNode = FocusNode();

  void onSuccessfullyPosted(
    BuildContext context,
  ) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Placeholder();
        // Future<void> openImagePickerForImageUpload() async {
        //   final ImagePicker picker = ImagePicker();
        //   final XFile? file = await picker.pickImage(
        //     source: ImageSource.gallery,
        //   );
        //
        //   context.read<CreatePostBloc>().add(
        //         ImageToUploadSelected(
        //           filePath: file!.path,
        //         ),
        //       );
        // }
        //
        // void runUrlAddedEvent() {
        //   context
        //       .read<CreatePostBloc>()
        //       .add(UrlAdded(url: urlTextController.text));
        // }
        //
        // void runImageRemovedEvent() {
        //   context.read<CreatePostBloc>().add(ImageRemoved());
        // }

        //   void showAddDialog() {
        //     showDialog<void>(
        //       context: context,
        //       builder: (context) => Dialog(
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Padding(
        //               padding: const EdgeInsets.all(8),
        //               child: ElevatedButton(
        //                 onPressed: () {
        //                   Navigator.pop(context);
        //                   showDialog<void>(
        //                     context: context,
        //                     builder: (context) {
        //                       return Dialog(
        //                         child: Column(
        //                           mainAxisSize: MainAxisSize.min,
        //                           children: [
        //                             Padding(
        //                               padding: const EdgeInsets.all(8),
        //                               child: TextField(
        //                                 controller: urlTextController,
        //                                 decoration: const InputDecoration(
        //                                   hintText: 'Url',
        //                                   border: InputBorder.none,
        //                                 ),
        //                               ),
        //                             ),
        //                             Padding(
        //                               padding: const EdgeInsets.all(8),
        //                               child: ElevatedButton(
        //                                 onPressed: () {
        //                                   Navigator.pop(context);
        //                                   runUrlAddedEvent();
        //                                 },
        //                                 style: ElevatedButton.styleFrom(
        //                                   fixedSize: const Size(500, 50),
        //                                 ),
        //                                 child: const Text('Add Url'),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       );
        //                     },
        //                   );
        //                 },
        //                 style: ElevatedButton.styleFrom(
        //                   fixedSize: const Size(500, 50),
        //                 ),
        //                 child: const Text('Add Url'),
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.all(8),
        //               child: ElevatedButton(
        //                 onPressed: () async {
        //                   Navigator.pop(context);
        //                   await openImagePickerForImageUpload();
        //                 },
        //                 style: ElevatedButton.styleFrom(
        //                   fixedSize: const Size(500, 50),
        //                 ),
        //                 child: const Text('Add Image'),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   }
        //
        //   return MuffedPage(
        //     isLoading: state.isLoading,
        //     error: state.error,
        //     child: Scaffold(
        //       appBar: AppBar(
        //         title: Text(
        //           (postBeingEdited == null) ? 'Create post' : 'Edit post',
        //         ),
        //         actions: [
        //           IconButton(
        //             onPressed: () {
        //               // if (titleTextController.text.isEmpty) {
        //               //   showErrorSnackBar(
        //               //     context,
        //               //     error: 'Title must not be empty',
        //               //   );
        //               // } else {
        //               //   context.read<CreatePostBloc>().add(
        //               //         PostSubmitted(
        //               //           title: titleTextController.text,
        //               //           body: bodyTextController.text,
        //               //           url: urlTextController.text,
        //               //         ),
        //               //       );
        //               // }
        //             },
        //             icon: const Icon(Icons.send),
        //           ),
        //         ],
        //       ),
        //       body: Column(
        //         children: [
        //           Expanded(
        //             child: SingleChildScrollView(
        //               child: Column(
        //                 children: [
        //                   ImageUploadView(
        //                     images: state.bodyImages,
        //                     onDelete: (id) {
        //                       // context
        //                       //     .read<CreatePostBloc>()
        //                       //     .add(UploadedBodyImageRemoved(id: id));
        //                     },
        //                   ),
        //                   Padding(
        //                     padding: const EdgeInsets.all(8),
        //                     child: TextField(
        //                       controller: titleTextController,
        //                       decoration: const InputDecoration(
        //                         hintText: 'Title',
        //                         border: InputBorder.none,
        //                       ),
        //                       style: Theme.of(context).textTheme.titleLarge,
        //                     ),
        //                   ),
        //                   if (state.url == null && state.image == null)
        //                     ElevatedButton(
        //                       onPressed: showAddDialog,
        //                       child: const Icon(Icons.add),
        //                     )
        //                   else if (state.url != null)
        //                     Material(
        //                       elevation: 5,
        //                       child: Stack(
        //                         children: [
        //                           UrlView(url: ''),
        //                           Align(
        //                             alignment: Alignment.topRight,
        //                             child: Padding(
        //                               padding: const EdgeInsets.all(4),
        //                               child: IconButton(
        //                                 onPressed: () {
        //                                   // context
        //                                   //     .read<CreatePostBloc>()
        //                                   //     .add(UrlRemoved());
        //                                 },
        //                                 style: IconButton.styleFrom(
        //                                   backgroundColor: Theme.of(context)
        //                                       .colorScheme
        //                                       .primaryContainer
        //                                       .withOpacity(0.5),
        //                                 ),
        //                                 icon: const Icon(Icons.close),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     )
        //                   else if (false)
        //                     if (false)
        //                       Stack(
        //                         children: [
        //                           MuffedImage(
        //                             imageUrl:'',
        //                           ),
        //                           Align(
        //                             alignment: Alignment.topRight,
        //                             child: IconButton(
        //                               onPressed: () {
        //                                 showDialog<void>(
        //                                   context: context,
        //                                   builder: (context) {
        //                                     return AlertDialog(
        //                                       title:
        //                                           const Text('Delete image?'),
        //                                       content: const Text(
        //                                         'Are you sure you want to delete this image from the server?',
        //                                       ),
        //                                       actions: [
        //                                         TextButton(
        //                                           onPressed: () {
        //                                             Navigator.pop(context);
        //                                           },
        //                                           child: const Text('Cancel'),
        //                                         ),
        //                                         TextButton(
        //                                           onPressed: () {
        //                                             runImageRemovedEvent();
        //                                             Navigator.pop(context);
        //                                           },
        //                                           child: const Text('Delete'),
        //                                         ),
        //                                       ],
        //                                     );
        //                                   },
        //                                 );
        //                               },
        //                               icon: const Icon(Icons.delete),
        //                               style: IconButton.styleFrom(
        //                                 backgroundColor: Theme.of(context)
        //                                     .colorScheme
        //                                     .primaryContainer
        //                                     .withOpacity(0.5),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       )
        //                     else
        //                       Padding(
        //                         padding: const EdgeInsets.all(8),
        //                         child: LinearProgressIndicator(
        //                           value: 1, // state.image!.uploadProgress,
        //                         ),
        //                       ),
        //                   Padding(
        //                     padding: const EdgeInsets.all(8),
        //                     child: IndexedStack(
        //                       index: (true ? 0 : 1),
        //                       children: [
        //                         SingleChildScrollView(
        //                           child: MuffedMarkdownBody(
        //                             data: bodyTextController.text,
        //                           ),
        //                         ),
        //                         SingleChildScrollView(
        //                           child: MarkdownTextInputField(
        //                             controller: bodyTextController,
        //                             focusNode: bodyTextFocusNode,
        //                             label: 'Body',
        //                             minLines: 5,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //           const Divider(height: 1),
        //           Row(
        //             children: [
        //               Expanded(
        //                 child: MarkdownButtons(
        //                   controller: bodyTextController,
        //                   focusNode: bodyTextFocusNode,
        //                   actions: const [
        //                     MarkdownType.image,
        //                     MarkdownType.link,
        //                     MarkdownType.bold,
        //                     MarkdownType.italic,
        //                     MarkdownType.blockquote,
        //                     MarkdownType.strikethrough,
        //                     MarkdownType.title,
        //                     MarkdownType.list,
        //                     MarkdownType.separator,
        //                     MarkdownType.code,
        //                   ],
        //                   customImageButtonAction: () async {
        //                     // final ImagePicker picker = ImagePicker();
        //                     // final XFile? file = await picker.pickImage(
        //                     //   source: ImageSource.gallery,
        //                     // );
        //                     //
        //                     // context.read<CreatePostBloc>().add(
        //                     //       BodyImageToUploadSelected(
        //                     //         filePath: file!.path,
        //                     //       ),
        //                     //     );
        //                   },
        //                 ),
        //               ),
        //               // Material(
        //               //   elevation: 5,
        //               //   child: Padding(
        //               //     padding: const EdgeInsets.all(4),
        //               //     child: IconButton(
        //               //       isSelected: state.isPreviewingBody,
        //               //       icon: (state.isPreviewingBody)
        //               //           ? const Icon(Icons.remove_red_eye)
        //               //           : const Icon(Icons.remove_red_eye_outlined),
        //               //       onPressed: () {
        //               //         // context
        //               //         //     .read<CreatePostBloc>()
        //               //         //     .add(PreviewToggled());
        //               //       },
        //               //     ),
        //               //   ),
        //               // ),
        //             ],
        //           ),
        //           const Divider(height: 1),
        //         ],
        //       ),
        //     ),
        //   );
      },
    );
  }
}
