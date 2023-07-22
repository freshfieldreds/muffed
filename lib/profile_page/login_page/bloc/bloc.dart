import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muffed/repo/server_repo.dart';

part 'event.dart';

part 'state.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  LoginPageBloc(this.repo) : super(LoginPageState()) {
    on<UserNameOrEmailChanged>((event, emit) {
      emit(state.copyWith(usernameOrEmail: event.value));
    });
    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.value));
    });
    on<TotpChanged>((event, emit) {
      emit(state.copyWith(totp: event.value));
    });
    on<ServerAddrChanged>((event, emit) {
      emit(state.copyWith(serverAddr: event.value));
    });
    on<Submitted>((event, emit) async {
      final totp = (state.totp == '') ? null : state.totp;

      final result = await repo.lemmyRepo
          .login(state.password, totp, state.usernameOrEmail, state.serverAddr);

      print((result as LemmyLoginResponse).jwt);
    });
  }

  final ServerRepo repo;
}
