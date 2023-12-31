import 'dart:async';

import 'package:dio/dio.dart';
import 'package:muffed/global_state/bloc.dart';
import 'package:muffed/repo/pictrs/models.dart';

class PictrsRepo {
  PictrsRepo({required this.globalBloc}) : dio = Dio();

  final GlobalBloc globalBloc;

  final Dio dio;

  Stream<ImageUploadState> uploadImage({
    required String filePath,
    int? id,
  }) async* {
    if (!globalBloc.state.isLoggedIn) {
      throw Exception('Not logged in');
    }

    final streamController = StreamController<ImageUploadState>();

    final baseUrl = globalBloc.state.lemmyBaseUrl;

    final response = dio
        .post<Map<String, dynamic>>(
          '$baseUrl/pictrs/image',
          data: FormData.fromMap({
            'images[]': await MultipartFile.fromFile(filePath),
          }),
          options: Options(
            headers: {
              'Cookie': 'jwt=${globalBloc.state.selectedLemmyAccount!.jwt}',
            },
          ),
          onSendProgress: (int sent, int total) {
            final progress = sent / total;
            streamController
                .add(ImageUploadState(uploadProgress: progress, id: id));
          },
        )
        .then((response) {
          streamController.add(
            ImageUploadState(
              id: id,
              deleteToken: response.data!['files'][0]['delete_token'],
              uploadProgress: 1,
              imageName: response.data!['files'][0]['file'],
              imageLink:
                  '$baseUrl/pictrs/image/${response.data!['files'][0]['file']}',
              baseUrl: baseUrl,
            ),
          );
        })
        .catchError(streamController.addError)
        .whenComplete(streamController.close);

    yield* streamController.stream;
  }

  Future<void> deleteImage(
    String deleteToken,
    String fileName,
    String baseUrl,
  ) async {
    final response = await dio.get<Map<String, dynamic>>(
      '$baseUrl/pictrs/image/delete/$deleteToken/$fileName',
    );
  }
}
