import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable implements Exception {
  const Failure();

  @override
  List<Object?> get props => [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class ServerFailure extends Failure {
  const ServerFailure([this.statusCode]);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}
