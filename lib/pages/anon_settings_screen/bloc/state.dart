part of 'bloc.dart';

class AnonSettingsState extends Equatable {
  const AnonSettingsState({
    this.urlInput = '',
    this.siteOfInputted,
    this.isLoading = false,
    this.error,
  });

  final String urlInput;
  final LemmySite? siteOfInputted;
  final bool isLoading;
  final Object? error;

  @override
  List<Object?> get props => [
        urlInput,
        siteOfInputted,
        isLoading,
        error,
      ];

  AnonSettingsState copyWith({
    String? urlInput,
    LemmySite? siteOfInputted,
    bool? setSiteToNull,
    bool? isLoading,
    Object? error,
  }) {
    return AnonSettingsState(
      urlInput: urlInput ?? this.urlInput,
      siteOfInputted:
          setSiteToNull == true ? null : siteOfInputted ?? this.siteOfInputted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
