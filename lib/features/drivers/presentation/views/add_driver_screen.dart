import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/permissions/prominent_user_data_disclosure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog_presenter.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/domain/entities/document_definition.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/driver_document_input.dart';
import '../../data/models/driver_model.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';
import '../bloc/driver_state.dart';

Future<int?> _androidSdkInt() async {
  if (!Platform.isAndroid) return null;
  return (await DeviceInfoPlugin().androidInfo).version.sdkInt;
}

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  String? _nameError;
  String? _phoneError;
  String? _nationalIdError;
  String? _documentsError;
  final List<DriverDocumentInput> _documents = [];
  List<DocumentDefinition> _documentDefinitions = [];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthGetDocumentsRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog({required int documentId}) async {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera(documentId: documentId);
            },
            child: Text(l10n.takePhoto),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery(documentId: documentId);
            },
            child: Text(l10n.chooseFromGallery),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera({required int documentId}) async {
    final l10n = AppLocalizations.of(context)!;
    final cameraStatus = await Permission.camera.status;
    if (!mounted) return;
    if (cameraStatus.isDenied) {
      final disclosed = await showProminentUserDataDisclosure(
        context,
        title: l10n.cameraPermissionDisclosureTitle,
        body: l10n.cameraPermissionDisclosureBody,
      );
      if (!disclosed || !mounted) return;
      final result = await Permission.camera.request();
      if (result.isDenied) {
        _showPermissionDeniedDialog(
          l10n.cameraPermissionRequired,
          l10n.permissionDenied,
        );
        return;
      }
    }

    if (cameraStatus.isPermanentlyDenied) {
      _showPermissionDeniedDialog(
        l10n.cameraPermissionRequired,
        l10n.permissionDenied,
      );
      return;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 720,
    );
    _addPickedImage(image, documentId);
  }

  Future<void> _pickImageFromGallery({required int documentId}) async {
    final l10n = AppLocalizations.of(context)!;

    if (Platform.isAndroid) {
      final sdk = await _androidSdkInt();
      if (!mounted) return;
      if (sdk != null && sdk < 33) {
        var storageStatus = await Permission.storage.status;
        if (!mounted) return;
        if (storageStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog(
            l10n.photoLibraryPermissionRequired,
            l10n.permissionDenied,
          );
          return;
        }
        if (storageStatus.isDenied) {
          final disclosed = await showProminentUserDataDisclosure(
            context,
            title: l10n.photosPermissionDisclosureTitle,
            body: l10n.photosPermissionDisclosureBody,
          );
          if (!disclosed || !mounted) return;
          storageStatus = await Permission.storage.request();
        }
        if (!storageStatus.isGranted) {
          _showPermissionDeniedDialog(
            l10n.photoLibraryPermissionRequired,
            l10n.permissionDenied,
          );
          return;
        }
      }
    } else {
      var photoStatus = await Permission.photos.status;
      if (!mounted) return;
      if (photoStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
          l10n.photoLibraryPermissionRequired,
          l10n.permissionDenied,
        );
        return;
      }
      if (photoStatus.isDenied) {
        final disclosed = await showProminentUserDataDisclosure(
          context,
          title: l10n.photosPermissionDisclosureTitle,
          body: l10n.photosPermissionDisclosureBody,
        );
        if (!disclosed || !mounted) return;
        photoStatus = await Permission.photos.request();
      }
      if (photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog(
          l10n.photoLibraryPermissionRequired,
          l10n.permissionDenied,
        );
        return;
      }
      if (!photoStatus.isGranted && !photoStatus.isLimited) {
        _showPermissionDeniedDialog(
          l10n.photoLibraryPermissionRequired,
          l10n.permissionDenied,
        );
        return;
      }
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 720,
    );
    _addPickedImage(image, documentId);
  }

  void _addPickedImage(XFile? image, int documentId) {
    if (image == null || !mounted) return;
    setState(() {
      _documents.add(
        DriverDocumentInput(
          documentId: documentId,
          filePath: image.path,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
      _documentsError = null;
    });
  }

  void _showPermissionDeniedDialog(String message, String title) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.openSettings),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  bool _validateFields(AppLocalizations l10n) {
    final phoneError = _validatePhone(l10n);
    final nationalId = _nationalIdController.text.trim();
    String? nationalIdError;
    if (nationalId.isEmpty) {
      nationalIdError = l10n.enterYourId;
    } else if (nationalId.length != 14) {
      nationalIdError = l10n.invalidNationalId;
    }

    final missingRequired = _documentDefinitions
        .where((definition) => definition.required)
        .any(
          (definition) =>
              !_documents.any((doc) => doc.documentId == definition.id),
        );

    setState(() {
      _phoneError = phoneError;
      _nationalIdError = nationalIdError;
      _nameError = _nameController.text.trim().isEmpty
          ? l10n.enterYourFullName
          : null;
      _documentsError = missingRequired
          ? l10n.pleaseUploadRequiredDocuments
          : null;
    });

    return _nameError == null &&
        _phoneError == null &&
        _nationalIdError == null &&
        _documentsError == null;
  }

  String? _validatePhone(AppLocalizations l10n) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return l10n.enterYourPhone;
    if (phone.length != 11) return l10n.enterValidPhone11Digits;
    if (!phone.startsWith('01')) return l10n.enterValidPhone01;
    return null;
  }

  void _submit(AppLocalizations l10n) {
    if (!_validateFields(l10n)) return;

    final name = _nameController.text.trim();
    context.read<DriverBloc>().add(
      CreateDriver(
        fullNameEn: name,
        fullNameAr: name,
        phone: _phoneController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        documents: List<DriverDocumentInput>.from(_documents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DriverBloc, DriverState>(
      listenWhen: (previous, current) =>
          current is DriverCreated || current is DriverCreateError,
      listener: (context, state) {
        if (state is DriverCreated) {
          context.read<DriverBloc>().add(GetDrivers());
          context.pop<DriverModel?>(state.driver);
        } else if (state is DriverCreateError) {
          showAppAlertDialog(
            context: context,
            title: l10n.addNewDriver,
            message: state.message,
          );
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.transparent,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.pop(),
            child: const Icon(CupertinoIcons.back),
          ),
          middle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.creditcard, color: AppColors.mainBlue),
              const SizedBox(width: 5),
              Text(
                l10n.addNewDriver,
                style: const TextStyle(
                  color: AppColors.mainBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xffeeeeee)),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 15),
                _label(l10n.fullName),
                const SizedBox(height: 5),
                _nameField(placeholder: l10n.fullName),
                if (_nameError != null) ...[
                  const SizedBox(height: 8),
                  _errorText(_nameError!),
                ],
                const SizedBox(height: 15),
                _label(l10n.phone),
                const SizedBox(height: 5),
                _phoneField(placeholder: l10n.phone),
                if (_phoneError != null) ...[
                  const SizedBox(height: 8),
                  _errorText(_phoneError!),
                ],
                const SizedBox(height: 15),
                _label(l10n.enterYourId),
                const SizedBox(height: 5),
                _nationalIdField(placeholder: l10n.enterYourId),
                if (_nationalIdError != null) ...[
                  const SizedBox(height: 8),
                  _errorText(_nationalIdError!),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.documents,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.driverDocumentsHint,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 14),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      current is AuthDocumentsLoading ||
                      current is AuthDocumentsLoaded ||
                      current is AuthDocumentsError,
                  builder: (context, state) {
                    if (state is AuthDocumentsLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }
                    if (state is AuthDocumentsError) {
                      return Text(
                        state.message,
                        style: const TextStyle(color: AppColors.red),
                      );
                    }
                    if (state is AuthDocumentsLoaded) {
                      _documentDefinitions = state.documents;
                      return Column(
                        children: [
                          for (int i = 0; i < state.documents.length; i++) ...[
                            _documentSection(
                              title:
                                  Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? state.documents[i].nameAr
                                  : state.documents[i].nameEn,
                              documentId: state.documents[i].id,
                              l10n: l10n,
                              required: state.documents[i].required,
                            ),
                            if (i != state.documents.length - 1)
                              const SizedBox(height: 20),
                          ],
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (_documentsError != null) ...[
                  const SizedBox(height: 8),
                  _errorText(_documentsError!),
                ],
                const SizedBox(height: 24),
                BlocBuilder<DriverBloc, DriverState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        loading: state is DriverCreating,
                        onPressed: () => _submit(l10n),
                        label: l10n.addDriver,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorText(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 13),
      ),
    );
  }

  Widget _label(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.red,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _nameField({required String placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _nameError != null
              ? CupertinoColors.systemRed
              : AppColors.lightGray,
        ),
      ),
      child: CupertinoTextField(
        controller: _nameController,
        placeholder: placeholder,
        onChanged: (_) {
          if (_nameError != null) setState(() => _nameError = null);
        },
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: null,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _phoneField({required String placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _phoneError != null
              ? CupertinoColors.systemRed
              : AppColors.lightGray,
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🇪🇬',
                    style: TextStyle(fontSize: 20, height: 1.2),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '+20',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.mediumBlueGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: AppColors.lightGray),
                ],
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: _phoneController,
              placeholder: placeholder,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: null,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nationalIdField({required String placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _nationalIdError != null
              ? CupertinoColors.systemRed
              : AppColors.lightGray,
        ),
      ),
      child: CupertinoTextField(
        controller: _nationalIdController,
        placeholder: placeholder,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(14),
        ],
        onChanged: (_) {
          if (_nationalIdError != null) {
            setState(() => _nationalIdError = null);
          }
        },
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: null,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _documentSection({
    required String title,
    required int documentId,
    required AppLocalizations l10n,
    bool required = false,
  }) {
    final uploadedDocuments = _documents
        .where((doc) => doc.documentId == documentId)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _uploadBox(documentId: documentId, l10n: l10n),
        if (uploadedDocuments.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...uploadedDocuments.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _uploadedFile(document),
            ),
          ),
        ],
      ],
    );
  }

  Widget _uploadBox({required int documentId, required AppLocalizations l10n}) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(documentId: documentId),
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          radius: Radius.circular(10),
          color: AppColors.mainBlue,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          dashPattern: [10, 5],
          strokeWidth: 1,
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mainBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.cloud_upload,
                size: 20,
                color: AppColors.mainBlue,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.uploadImageOrBrowse,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.pngJpgUpTo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _uploadedFile(DriverDocumentInput document) {
    final file = File(document.filePath);
    final fileName = file.path.split(Platform.pathSeparator).last;
    final sizeLabel = _fileSizeLabel(file);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(file, width: 42, height: 42, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff222222),
                  ),
                ),
                if (sizeLabel != null)
                  Text(
                    sizeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff888888),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _documents.remove(document));
              _showImageSourceDialog(documentId: document.documentId);
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.mainBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.refresh,
                size: 15,
                color: AppColors.mainBlue,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _documents.remove(document)),
            child: Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Color(0xffffeeee),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.delete,
                size: 15,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _fileSizeLabel(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return null;
    }
  }
}
