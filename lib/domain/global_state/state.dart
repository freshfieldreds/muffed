part of 'bloc.dart';

final class GlobalState extends Equatable {
  ///
  const GlobalState({
    this.lemmyAccounts = const [],
    this.lemmySelectedAccount = -1,
    this.lemmyDefaultHomeServer = 'https://lemmy.ml',
    this.showNsfw = false,
    this.blurNsfw = true,
    this.defaultSortType = LemmySortType.active,
  });

  factory GlobalState.fromMap(Map<String, dynamic> map) {
    return GlobalState(
      lemmyAccounts: List.generate(
        (map['lemmyAccounts'] as List).length,
        (index) => LemmyAccountData.fromMap(map['lemmyAccounts'][index]),
      ),
      lemmySelectedAccount: map['lemmySelectedAccount'] as int,
      lemmyDefaultHomeServer: map['lemmyDefaultHomeServer'],
      showNsfw: map['showNsfw'],
      blurNsfw: map['blurNsfw'],
      defaultSortType: LemmySortType.values[map['defaultSortType']],
    );
  }

  /// All the lemmy accounts the user has added
  final List<LemmyAccountData> lemmyAccounts;

  /// the index of the selected account on lemmyAccounts
  /// -1 mean anonymous/no account
  final int lemmySelectedAccount;

  /// the home server used if no account selected
  final String lemmyDefaultHomeServer;

  /// whether to show or hide nsfw posts
  final bool showNsfw;

  /// whether to blur nsfw posts
  final bool blurNsfw;

  final LemmySortType defaultSortType;

  bool isLoggedIn() => lemmySelectedAccount != -1;

  LemmyAccountData? getSelectedLemmyAccount() {
    return (lemmySelectedAccount == -1)
        ? null
        : lemmyAccounts[lemmySelectedAccount];
  }

  String getLemmyBaseUrl() {
    return (lemmySelectedAccount == -1)
        ? lemmyDefaultHomeServer
        : lemmyAccounts[lemmySelectedAccount].homeServer;
  }

  /// if the content the app gets may be different
  ///
  /// Used in content scroll view to see whether the posts should be reloaded
  bool requestUrlDifferent(GlobalState state) {
    if (state.getLemmyBaseUrl() != getLemmyBaseUrl() ||
        state.getSelectedLemmyAccount()?.jwt !=
            getSelectedLemmyAccount()?.jwt) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        lemmyAccounts,
        lemmySelectedAccount,
        lemmyDefaultHomeServer,
        showNsfw,
        blurNsfw,
        defaultSortType,
      ];

  Map<String, dynamic> toMap() {
    return {
      'lemmyAccounts': List.generate(
        lemmyAccounts.length,
        (index) => lemmyAccounts[index].toMap(),
      ),
      'lemmySelectedAccount': lemmySelectedAccount,
      'lemmyDefaultHomeServer': lemmyDefaultHomeServer,
      'showNsfw': showNsfw,
      'blurNsfw': blurNsfw,
      'defaultSortType': defaultSortType.index,
    };
  }

  GlobalState copyWith({
    List<LemmyAccountData>? lemmyAccounts,
    int? lemmySelectedAccount,
    String? lemmyDefaultHomeServer,
    ThemeMode? themeMode,
    bool? useDynamicColorScheme,
    Color? seedColor,
    bool? showNsfw,
    bool? blurNsfw,
    LemmySortType? defaultSortType,
    double? bodyTextScaleFactor,
    double? labelTextScaleFactor,
    double? titleTextScaleFactor,
  }) {
    return GlobalState(
      lemmyDefaultHomeServer:
          lemmyDefaultHomeServer ?? this.lemmyDefaultHomeServer,
      lemmyAccounts: lemmyAccounts ?? this.lemmyAccounts,
      lemmySelectedAccount: lemmySelectedAccount ?? this.lemmySelectedAccount,
      showNsfw: showNsfw ?? this.showNsfw,
      blurNsfw: blurNsfw ?? this.blurNsfw,
      defaultSortType: defaultSortType ?? this.defaultSortType,
    );
  }
}

final class LemmyAccountData extends Equatable {
  const LemmyAccountData({
    required this.jwt,
    required this.homeServer,
    required this.name,
    required this.id,
  });

  factory LemmyAccountData.fromMap(Map<String, dynamic> map) {
    return LemmyAccountData(
      jwt: map['jwt'] as String,
      homeServer: map['homeServer'] as String,
      name: map['userName'] as String,
      id: map['id'] as int,
    );
  }

  final String jwt;

  /// home server should include the "https://" and not end with "/"
  final String homeServer;
  final String name;

  final int id;

  Map<String, dynamic> toMap() {
    return {
      'jwt': jwt,
      'homeServer': homeServer,
      'userName': name,
      'id': id,
    };
  }

  @override
  List<Object?> get props => [
        jwt,
        homeServer,
        name,
        id,
      ];
}
