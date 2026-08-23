import 'package:dartz/dartz.dart';

import '../entities/register_document.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class RegisterParams {
  const RegisterParams({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.NationalId,
    required this.documents,
  });

  final String fullName;
  final String phone;
  final String address;
  final String NationalId;
  final List<RegisterDocument> documents;
}

class RegisterUseCase implements UseCase<void, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, void>> call(RegisterParams params) {
    return _repository.register(
      fullName: params.fullName,
      phone: params.phone,
      address: params.address,
      NationalId: params.NationalId,
      documents: params.documents,
    );
  }
}