import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:muffed/domain/lemmy/models/models.dart';
import 'package:muffed/domain/lemmy/models/image_upload_state.dart';
import 'package:muffed/domain/lemmy_keychain/bloc.dart';
import 'package:muffed/utils/url.dart';

import 'package:lemmy_api_client/v3.dart';

final _log = Logger('LemmyRepo');

/// Used to interact with the lemmy http api
class LemmyRepo {
  /// initialize lemmy repo
  LemmyRepo({required this.lemmyKeychainBloc}) : dio = Dio();

  final LemmyKeychainBloc lemmyKeychainBloc;

  /// The dio client that will be used to send requests
  final Dio dio;

  String get instanceAddress =>
      lemmyKeychainBloc.state.activeKey.instanceAddress
          .replaceFirst('https://', '');

  String? get authToken => lemmyKeychainBloc.state.activeKey.authToken;

  LemmyApiV3 get lemmyApi => LemmyApiV3(instanceAddress);

  Future<T> run<T>(LemmyApiQuery<T> query) =>
      lemmyApi.run(query, authToken: authToken);

  Stream<ImageUploadState> uploadImage({
    required String filePath,
    int? id,
  }) async* {
    if (authToken != null) {
      throw Exception('Not logged in');
    }

    final streamController = StreamController<ImageUploadState>();

    final baseUrl = instanceAddress;

    final response = dio
        .post<Map<String, dynamic>>(
          '$baseUrl/pictrs/image',
          data: FormData.fromMap({
            'images[]': await MultipartFile.fromFile(filePath),
          }),
          options: Options(
            headers: {
              'Cookie': 'jwt=${authToken}',
            },
          ),
          onSendProgress: (int sent, int total) {
            final double progress = sent / total;
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

  /// Creates a post request to the lemmy api, If logged in auth parameter will
  /// be added automatically
  Future<Map<String, dynamic>> postRequest({
    required String path,
    Map<String, dynamic> data = const {},
    bool mustBeLoggedIn = true,
    String? serverAddress,
  }) async {
    if (authToken != null && mustBeLoggedIn) {
      throw Exception('Not logged in');
    }

    final Response<Map<String, dynamic>> response = await dio.post(
      '${serverAddress ?? instanceAddress}/api/v3$path',
      data: {
        if (authToken != null && mustBeLoggedIn) 'auth': authToken,
        ...data,
      },
    );

    if (response.data == null) {
      throw 'null returned in response';
    }

    return response.data!;
  }

  Future<Map<String, dynamic>> putRequest({
    required String path,
    Map<String, dynamic> data = const {},
    bool mustBeLoggedIn = true,
    String? serverAddress,
  }) async {
    try {
      if (authToken == null && mustBeLoggedIn) {
        throw Exception('Not logged in');
      }

      final Response<Map<String, dynamic>> response = await dio.put(
        '${serverAddress ?? instanceAddress}/api/v3$path',
        data: {
          if (authToken != null && mustBeLoggedIn) 'auth': authToken,
          ...data,
        },
      );

      if (response.statusCode != 200) {
        throw HttpException('${response.statusCode}');
      }

      if (response.data == null) {
        throw 'null returned in response';
      }

      return response.data!;
    } catch (err) {
      if (err is DioException) {
        _log.severe('Dio error: ${err.response?.data}');
        return Future.error(err.response?.data);
      }
      return Future.error(err);
    }
  }

  /// Sends a get request to the lemmy api, If logged in auth parameter will be
  /// added automatically
  Future<Map<String, dynamic>> getRequest({
    required String path,
    Map<String, dynamic> queryParameters = const {},
    bool mustBeLoggedIn = false,
    String? serverAddress,

    /// The jwt to use for the request
    String? jwt,
  }) async {
    if (mustBeLoggedIn && authToken != null) {
      throw Exception('Not logged in');
    }

    _log.info(
      'Sending get request to ${instanceAddress}, Path: $path, Data: $queryParameters',
    );

    final Response<Map<String, dynamic>> response = await dio.get(
      '${serverAddress ?? instanceAddress}/api/v3$path',
      queryParameters: {
        if (jwt != null)
          'auth': jwt
        else if (authToken != null)
          'auth': authToken,
        ...queryParameters,
      },
    );

    if (response.data == null) {
      throw 'response returned null';
    }

    return response.data!;
  }

  Future<List<LemmyPost>> getPosts({
    LemmySortType sortType = LemmySortType.hot,
    int page = 1,
    int? communityId,
    LemmyListingType listingType = LemmyListingType.all,
    bool savedOnly = false,
  }) async {
    final Map<String, dynamic> response = await getRequest(
      path: '/post/list',
      queryParameters: {
        'page': page,
        'sort': lemmySortTypeToJson[sortType],
        if (communityId != null) 'community_id': communityId,
        'type_': lemmyListingTypeToJson[listingType],
        'saved_only': savedOnly,
      },
    );

    final List<dynamic> jsonPosts = response['posts'];

    return List.generate(
      jsonPosts.length,
      (index) => LemmyPost.fromPostViewJson(jsonPosts[index]),
    );
  }

  /// Gets comments from lemmy api
  Future<List<LemmyComment>> getComments({
    int? postId,
    int? parentId,
    int page = 1,
    int? limit = 50,
    LemmyListingType listingType = LemmyListingType.all,
    LemmyCommentSortType sortType = LemmyCommentSortType.hot,
  }) async {
    if (parentId == null && postId == null) {
      throw 'No id provided';
    }

    final Map<String, dynamic> response = await getRequest(
      path: '/comment/list',
      queryParameters: {
        if (postId != null) 'post_id': postId,
        if (parentId != null) 'parent_id': parentId,
        if (limit != null) 'limit': limit,
        'page': page,
        'type_': lemmyListingTypeToJson[listingType],
        'sort': lemmyCommentSortTypeToJson[sortType],
        'max_depth': 8,
      },
    );

    final List<dynamic> rawComments = response['comments'];

    return List.generate(
      rawComments.length,
      (index) => LemmyComment.fromCommentViewJson(rawComments[index]),
    );
  }

  Future<LemmyGetPersonDetailsResponse> getPersonDetails({
    int? id,
    String? username,
    int page = 1,
    LemmySortType? sortType,
  }) async {
    if (id == null && username == null) {
      throw 'Both id and username equals null';
    }
    final response = await getRequest(
      path: '/user',
      queryParameters: {
        if (id != null) 'person_id': id,
        if (username != null) 'username': username,
        'page': page,
        'sort': lemmySortTypeToJson[sortType ?? LemmySortType.hot],
      },
    );

    return LemmyGetPersonDetailsResponse(
      person: LemmyPerson.fromJson(response),
      posts: List.generate(
        (response['posts'] as List).length,
        (index) => LemmyPost.fromPostViewJson(
          (response['posts'] as List)[index],
        ),
      ),
      comments: List.generate(
        (response['comments'] as List).length,
        (index) => LemmyComment.fromCommentViewJson(
          (response['comments'] as List)[index],
        ),
      ),
      moderates: List.generate(
        (response['moderates'] as List).length,
        (index) => response['moderates'][index]['community']['title'],
      ),
    );
  }

  Future<LemmySearchResponse> search({
    required String query,
    int page = 1,
    LemmySearchType searchType = LemmySearchType.all,
    LemmySortType sortType = LemmySortType.topAll,
    int? communityId,
    int? creatorId,
    LemmyListingType listingType = LemmyListingType.all,
  }) async {
    final response = await getRequest(
      path: '/search',
      queryParameters: {
        'page': page,
        'q': query,
        'type_': lemmySearchTypeToJson[searchType],
        'sort': lemmySortTypeToJson[sortType],
        if (communityId != null) 'community_id': communityId.toString(),
        if (creatorId != null) 'creator_id': creatorId.toString(),
        'listing_type': lemmyListingTypeToJson[listingType],
      },
    );

    final List<dynamic> rawComments = response['comments'];
    final List<dynamic> rawCommunities = response['communities'];
    final List<dynamic> rawPersons = response['users'];
    final List<dynamic> rawPosts = response['posts'];

    return LemmySearchResponse(
      lemmyComments: List.generate(
        rawComments.length,
        (index) => LemmyComment.fromCommentViewJson(rawComments[index]),
      ),
      lemmyCommunities: List.generate(
        rawCommunities.length,
        (index) => LemmyCommunity.fromJson(rawCommunities[index]),
      ),
      lemmyPersons: List.generate(
        rawPersons.length,
        (index) => LemmyPerson.fromJson(rawPersons[index]),
      ),
      lemmyPosts: List.generate(
        rawPosts.length,
        (index) => LemmyPost.fromPostViewJson(rawPosts[index]),
      ),
    );
  }

  Future<GetCommunityResponse> getCommunity({int? id, String? name}) async {
    if (id == null && name == null) {
      throw 'Both community id and name are not provided';
    }

    final response = await LemmyApiV3(instanceAddress)
        .run(GetCommunity(id: id, name: name, auth: authToken));

    return response;
  }

  Future<LemmyLoginResponse> login(
    String password,
    String? totp,
    String usernameOrEmail,
    String serverAddr,
  ) async {
    final Map<String, dynamic> response = await postRequest(
      path: '/user/login',
      data: {
        'username_or_email': usernameOrEmail,
        'password': password,
        if (totp != null) 'totp_2fa_token': totp,
      },
      mustBeLoggedIn: false,
      serverAddress: serverAddr,
    );

    return LemmyLoginResponse(
      registrationCreated: response['registration_created'],
      verifyEmailSent: response['verify_email_sent'],
      jwt: response['jwt'],
    );
  }

  Future<void> votePost(
    int postId,
    LemmyVoteType vote,
  ) =>
      postRequest(
        path: '/post/like',
        data: {
          'post_id': postId,
          'score': lemmyVoteTypeJson[vote],
        },
      );

  Future<void> voteComment(
    int commentId,
    LemmyVoteType vote,
  ) =>
      postRequest(
        path: '/comment/like',
        data: {
          'comment_id': commentId,
          'score': lemmyVoteTypeJson[vote],
        },
      );

  Future<void> createComment(
    String content,
    int postId,
    int? parentId,
  ) =>
      postRequest(
        path: '/comment',
        data: {
          'post_id': postId,
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );

  Future<LemmySubscribedType> followCommunity({
    required int communityId,
    required bool follow,
  }) async {
    final response = await postRequest(
      path: '/community/follow',
      data: {'community_id': communityId, 'follow': follow},
    );

    return jsonToLemmySubscribedType[response['community_view']['subscribed']]!;
  }

  /// Used to block and unblock a person, returns whether the user is now
  /// blocked
  Future<bool> BlockPerson({required int personId, required bool block}) async {
    final response = await postRequest(
      path: '/user/block',
      data: {
        'block': block,
        'person_id': personId,
      },
    );
    return response['blocked'];
  }

  Future<bool> getIsPersonBlocked(int personId) async {
    final response = await getRequest(path: '/site', mustBeLoggedIn: true);

    for (final block in response['my_user']['person_blocks']) {
      if (block['target']['id'] == personId) {
        return true;
      }
    }

    return false;
  }

  /// User to block and unblock a community, returns whether the community is
  /// now blocked
  Future<bool> BlockCommunity({required int id, required bool block}) async {
    final response = await postRequest(
      path: '/community/block',
      data: {'community_id': id, 'block': block},
    );
    return response['blocked'];
  }

  Future<bool> getIsCommunityBlocked(int communityId) async {
    final response = await getRequest(path: '/site', mustBeLoggedIn: true);

    for (final block in response['my_user']['community_blocks']) {
      if (block['community']['id'] == communityId) {
        return true;
      }
    }

    return false;
  }

  /// saves post, returns whether the post is now saved or not
  Future<bool> savePost({required int postId, required bool save}) async {
    final response = await putRequest(
      path: '/post/save',
      data: {
        'post_id': postId,
        'save': save,
      },
    );

    return response['post_view']['saved'];
  }

  /// Gets the current lemmy site
  Future<LemmySite> getSite() async {
    final response = await getRequest(path: '/site');

    return LemmySite.fromGetSiteResponse(response);
  }

  Future<LemmyPerson> getPersonWithJwt({
    String? jwt,
    String? serverAddress,
  }) async {
    final response =
        await getRequest(path: '/site', jwt: jwt, serverAddress: serverAddress);

    return LemmyPerson.fromJson(
      response['my_user']['local_user_view'],
    );
  }

  /// Gets any lemmy site
  Future<LemmySite> getSpecificSite(String url) async {
    final Response<Map<String, dynamic>> response = await dio.get(
      '${cleanseUrl(url)}/api/v3/site',
    );

    if (response.data == null) {
      throw 'response returned null';
    }

    return LemmySite.fromGetSiteResponse(response.data!);
  }

  /// Creates a post, returns the post that was created
  Future<LemmyPost> createPost({
    required String name,
    required int communityId,
    String? body,
    String? url,
    bool? nsfw,
  }) async {
    final response = await postRequest(
      path: '/post',
      data: {
        'name': name,
        'community_id': communityId,
        if (body != null) 'body': body,
        if (url != null) 'url': url,
        if (nsfw != null) 'nsfw': nsfw,
      },
    );

    return LemmyPost.fromPostViewJson(response['post_view']);
  }

  Future<List<LemmyInboxReply>> getReplies({
    int page = 1,
    LemmyCommentSortType sort = LemmyCommentSortType.latest,
    bool unreadOnly = true,
  }) async {
    final response = await getRequest(
      mustBeLoggedIn: true,
      path: '/user/replies',
      queryParameters: {
        'page': page,
        'sort': lemmyCommentSortTypeToJson[sort],
        'unread_only': unreadOnly,
      },
    );

    return List.generate(
      response['replies'].length,
      (index) => LemmyInboxReply.fromReplyViewJson(response['replies'][index]),
    );
  }

  Future<List<LemmyInboxMention>> getMention({
    int page = 1,
    LemmyCommentSortType sort = LemmyCommentSortType.latest,
    bool unreadOnly = true,
  }) async {
    final response = await getRequest(
      path: '/user/mention',
      mustBeLoggedIn: true,
      queryParameters: {
        'page': page,
        'sort': lemmyCommentSortTypeToJson[sort],
        'unread_only': unreadOnly,
      },
    );

    return List.generate(
      response['mentions'].length,
      (index) => LemmyInboxMention.fromPersonMentionViewJson(
        response['mentions'][index],
      ),
    );
  }

  Future<void> markReplyAsRead({required int id, bool read = true}) async {
    await postRequest(
      path: '/comment/mark_as_read',
      data: {'comment_reply_id': id, 'read': read},
    );
  }

  Future<void> markMentionAsRead({required int id, bool read = true}) async {
    await postRequest(
      path: '/user/mention/mark_as_read',
      data: {'person_mention_id': id, 'read': read},
    );
  }

  Future<LemmyPost> getPost({required int id}) async {
    final response = await getRequest(
      path: '/post',
      queryParameters: {'id': id},
    );

    return LemmyPost.fromPostViewJson(response['post_view']);
  }

  Future<LemmyPost> editPost({
    required int id,
    required String name,
    String? url,
    bool? nsfw,
    int? languageId,
    String? body,
  }) async {
    final response = await putRequest(
      path: '/post',
      data: {
        'post_id': id,
        'name': name,
        if (url != null) 'url': url,
        if (nsfw != null) 'nsfw': nsfw,
        if (languageId != null) 'language_id': languageId,
        if (body != null) 'body': body,
      },
    );

    return LemmyPost.fromPostViewJson(response['post_view']);
  }

  Future<LemmyComment> editComment({
    required int id,
    String? content,
    int? formId,
  }) async {
    final response = await putRequest(
      path: '/comment',
      data: {
        'comment_id': id,
        if (content != null) 'content': content,
        if (formId != null) 'form_id': formId,
      },
    );

    return LemmyComment.fromCommentViewJson(response['comment_view']);
  }
}
