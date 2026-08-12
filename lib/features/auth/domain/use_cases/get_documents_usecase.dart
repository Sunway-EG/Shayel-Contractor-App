import 'package:dartz/dartz.dart';

import '../entities/document_definition.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class GetDocumentsUseCase
    implements UseCase<List<DocumentDefinition>, void> {
  GetDocumentsUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, List<DocumentDefinition>>> call(void params) {
    return _repository.getDocuments();
  }
}