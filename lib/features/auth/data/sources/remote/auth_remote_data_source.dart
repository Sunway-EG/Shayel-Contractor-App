import 'package:dio/dio.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_response_parser.dart';
import '../../models/login_request_dto.dart';
import '../../models/login_response_dto.dart';
import '../../models/send_login_otp_response_dto.dart';
import '../../models/login_with_otp_request_dto.dart';
import '../../models/send_mfa_code_request_dto.dart';
import '../../models/verify_mfa_request_dto.dart';
import '../../models/enable_mfa_request_dto.dart';
import '../../models/update_profile_request_dto.dart';
import '../../models/register_document_model.dart';
import '../../models/document_definition_dto.dart';

abstract interface class AuthRemoteDataSource {
  /// Returns [LoginResponseDto] parsed from data envelope.
  /// Sends [lang] header: 'ar' when RTL (Arabic), else 'en'.
   Future<List<DocumentDefinitionDto>> getDocuments();
  Future<LoginResponseDto> login(LoginRequestDto request, {String? lang});
  Future<SendLoginOtpResponseDto> sendLoginOtp(LoginRequestDto request);
  Future<LoginResponseDto> loginWithOtp(LoginWithOtpRequestDto request);
  Future<void> logout();
  Future<DriverProfileDto> getProfile();
  Future<void> forgetPassword({
    required String identifier,
    required int channel,
  });
  Future<void> register({
    required String fullName,
    required String phone,
    required String address,
    required List<RegisterDocumentModel> documents,
  });
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> resetPasswordWithCode({
    required String code,
    required String login,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> sendMfaCode({required int channel});
  Future<LoginResponseDto> verifyMfa({required String code});
  Future<void> enableMfa({required int channel});
  Future<void> disableMfa();
  Future<DriverProfileDto> updateProfile(UpdateProfileRequestDto request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> _postDataMap(
    String path, {
    Object? body,
    Options? options,
    String missingDataMessage = 'Missing data in response',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: options,
    );
    return requireEnvelopeDataMap(
      response,
      missingDataMessage: missingDataMessage,
    );
  }

  Future<void> _postSuccess(
    String path, {
    Object? body,
    Options? options,
    String fallbackMessage = 'Request failed',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: options,
    );
    throwIfEnvelopeFailed(response, fallbackMessage: fallbackMessage);
  }

  @override
  Future<LoginResponseDto> login(
    LoginRequestDto request, {
    String? lang,
  }) async {
    final headers = <String, dynamic>{'lang': ?lang};
    final dataObj = await _postDataMap(
      ApiEndpoints.login,
      body: request.toJson(),
      options: Options(headers: headers),
      missingDataMessage: 'Missing data in login response',
    );
    return LoginResponseDto.fromJson(dataObj);
  }

  @override
  Future<SendLoginOtpResponseDto> sendLoginOtp(LoginRequestDto request) async {
    final dataObj = await _postDataMap(
      ApiEndpoints.sendLoginOtp,
      body: request.toJson(),
      missingDataMessage: 'Missing data in send-login-otp response',
    );
    return SendLoginOtpResponseDto.fromJson(dataObj);
  }

  @override
  Future<LoginResponseDto> loginWithOtp(LoginWithOtpRequestDto request) async {
    final dataObj = await _postDataMap(
      ApiEndpoints.loginWithOtp,
      body: request.toJson(),
      missingDataMessage: 'Missing data in login-with-otp response',
    );
    return LoginResponseDto.fromJson(dataObj);
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  @override
  Future<DriverProfileDto> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.profile);
    final dataObj = requireEnvelopeDataMap(
      response,
      missingDataMessage: 'Missing data in profile response',
    );
    return DriverProfileDto.fromJson(dataObj);
  }
  @override
Future<List<DocumentDefinitionDto>> getDocuments() async {
  final response = await _dio.get<Map<String, dynamic>>(
    ApiEndpoints.documents,
    queryParameters: {
      'Page': 1,
      'PageSize': 100,
      'Search': '',
      'Required': '',
      'Status': 1,
    },
  );

  final envelope = requireEnvelope(response);

  final data = envelope['data'];

  if (data is! List) {
    throw Exception('Invalid documents response');
  }

  return data
      .whereType<Map<String, dynamic>>()
      .map(DocumentDefinitionDto.fromJson)
      .toList();
}

  @override
  Future<void> forgetPassword({
    required String identifier,
    required int channel,
  }) async {
    await _postSuccess(
      ApiEndpoints.forgetPassword,
      body: {'identifier': identifier, 'channel': channel},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _postSuccess(
      ApiEndpoints.resetPassword,
      body: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> resetPasswordWithCode({
    required String code,
    required String login,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _postSuccess(
      ApiEndpoints.resetPasswordWithCode,
      body: {
        'code': code,
        'login': login,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _postSuccess(
      ApiEndpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> sendMfaCode({required int channel}) async {
    await _postSuccess(
      ApiEndpoints.sendMfaCode,
      body: SendMfaCodeRequestDto(channel: channel).toJson(),
    );
  }

  @override
  Future<LoginResponseDto> verifyMfa({required String code}) async {
    final dataObj = await _postDataMap(
      ApiEndpoints.verifyMfa,
      body: VerifyMfaRequestDto(code: code).toJson(),
      missingDataMessage: 'Missing data in verify-mfa response',
    );
    return LoginResponseDto.fromJson(dataObj);
  }

  @override
  Future<void> enableMfa({required int channel}) async {
    await _postSuccess(
      ApiEndpoints.enableMfa,
      body: EnableMfaRequestDto(channel: channel).toJson(),
    );
  }

  @override
  Future<void> disableMfa() async {
    await _postSuccess(ApiEndpoints.disableMfa);
  }

  @override
  Future<DriverProfileDto> updateProfile(
    UpdateProfileRequestDto request,
  ) async {
    final formData = request.toFormData();
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: formData,
    );
    final envelope = requireEnvelope(response);
    if ((envelope['success'] as bool? ?? false) != true) {
      throwIfEnvelopeFailed(response);
    }
    final dataObj = envelope['data'] as Map<String, dynamic>?;
    if (dataObj != null) {
      return DriverProfileDto.fromJson(dataObj);
    }
    // API returns success with data: null (e.g. "Authentication operation completed")
    // Fetch the profile to return updated data
    return getProfile();
  }

  @override
  Future<void> register({
    required String fullName,
    required String phone,
    required String address,
    required List<RegisterDocumentModel> documents,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('FullName', fullName));

    formData.fields.add(MapEntry('Phone', phone));

    formData.fields.add(MapEntry('Address', address));

    for (var i = 0; i < documents.length; i++) {
      final document = documents[i];

      formData.fields.add(
        MapEntry('Documents[$i].DocumentId', document.documentId.toString()),
      );

      formData.fields.add(
        MapEntry(
          'Documents[$i].ExpiryDate',
          document.expiryDate.toUtc().toIso8601String(),
        ),
      );

      formData.files.add(
        MapEntry(
          'Documents[$i].File',
          await MultipartFile.fromFile(document.filePath),
        ),
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: formData,
    );

    throwIfEnvelopeFailed(response, fallbackMessage: 'Registration failed');
  }
}
