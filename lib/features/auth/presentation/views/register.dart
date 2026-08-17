import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/permissions/prominent_user_data_disclosure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/register_document.dart';
import 'dart:io';
import '../../domain/entities/document_definition.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/auth_error_extensions.dart';

/// Android 13+ (API 33): system photo picker — no READ_MEDIA_IMAGES (Play policy).
Future<int?> _androidSdkInt() async {
  if (!Platform.isAndroid) return null;
  return (await DeviceInfoPlugin().androidInfo).version.sdkInt;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _nameError;
  String? _phoneError;
  String? _addressError;
  final List<RegisterDocument> documents = [];
  List<DocumentDefinition> documentDefinitions = [];
  bool agree = false;
  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(const AuthGetDocumentsRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera({required int documentId}) async {
    final l10n = AppLocalizations.of(context)!;

    // Check camera permission
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

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 720,
    );

    if (image != null && mounted) {
      setState(() {
        documents.add(
          RegisterDocument(
            documentId: documentId,
            filePath: image.path,
            expiryDate: DateTime.now().add(const Duration(days: 365)),
          ),
        );
      });
    }
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

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 720,
    );

    if (image != null && mounted) {
      setState(() {
        documents.add(
          RegisterDocument(
            documentId: documentId,
            filePath: image.path,
            expiryDate: DateTime.now().add(const Duration(days: 365)),
          ),
        );
      });
    }
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
            onPressed: () {
              Navigator.pop(context);
            },
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

  void _validateFields(AppLocalizations l10n) {
    final loginError = _validatePhone(l10n);
    setState(() {
      _phoneError = loginError;
      if (_nameController.text.trim().isEmpty) {
        _nameError = l10n.enterYourFullName;
      }
      if (_addressController.text.trim().isEmpty) {
        _addressError = l10n.enterYourAddress;
      }
    });
  }

  String? _validatePhone(AppLocalizations l10n) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      return l10n.enterYourPhone;
    }
    if (phone.length != 11) return l10n.enterValidPhone11Digits;
    if (!phone.startsWith('01')) return l10n.enterValidPhone01;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          _showSuccessDialog();
        } else if (state is AuthError) {
          // Show error dialog
          final displayMessage = state.getDisplayMessage(l10n);
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(l10n.error),
              content: Text(displayMessage),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) context.go(AppRoutePaths.firstChoose);
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              child: const Icon(CupertinoIcons.back),
              onPressed: () => context.go(AppRoutePaths.firstChoose),
            ),
            middle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.checkmark_shield,
                  color: AppColors.mainBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  l10n.uploadYourDocuments,
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
                    l10n.contractorInformation,
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
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _nameError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  _label(l10n.phoneNumber),

                  const SizedBox(height: 5),

                  _phoneField(placeholder: l10n.phoneNumber),
                  if (_phoneError != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _phoneError!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  _label(l10n.addressDetails),

                  const SizedBox(height: 5),

                  _addressField(placeholder: l10n.addressDetails),

                  const SizedBox(height: 24),

                  // =========================
                  // المستندات
                  // =========================
                  Text(
                    l10n.documents,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGray,
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
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is AuthDocumentsError) {
                        return Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      if (state is AuthDocumentsLoaded) {
                        documentDefinitions = state.documents;

                        return Column(
                          children: [
                            for (
                              int i = 0;
                              i < state.documents.length;
                              i++
                            ) ...[
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

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => setState(() {
                      agree = !agree;
                    }),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 25,
                          height: 25,
                          child: CupertinoCheckbox(
                            value: agree,
                            onChanged: (_) => setState(() {
                              agree = !agree;
                            }),
                            activeColor: AppColors.mainBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.registerConfirm,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================
                  // زر التأكيد
                  // =========================
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: agree
                              ? () {
                                  _validateFields(l10n);
                                  if (_nameError != null ||
                                      _phoneError != null ||
                                      _addressError != null) {
                                    return;
                                  }
                                  final phone = _phoneController.text.trim();
                                  final phoneWithCountryCode =
                                      phone.startsWith('+2')
                                      ? phone
                                      : '+2$phone';

                                  context.read<AuthBloc>().add(
                                    AuthRegisterRequested(
                                      fullName: _nameController.text.trim(),
                                      phone: phoneWithCountryCode,
                                      address: _addressController.text.trim(),
                                      documents: documents,
                                    ),
                                  );
                                }
                              : null,
                          loading: state is AuthLoading,
                          label: l10n.confirm,
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
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.darkGray,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

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
          if (_nameError != null) {
            setState(() => _nameError = null);
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

  // ============================================================
  // PHONE
  // ============================================================

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
                    '+2',
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
              onChanged: (value) {
                if (_phoneError != null) {
                  setState(() => _phoneError = null);
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              maxLength: 11,
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

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _addressField({required String placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _addressError != null
              ? CupertinoColors.systemRed
              : AppColors.lightGray,
        ),
      ),
      child: CupertinoTextField(
        controller: _addressController,
        maxLines: 4,
        placeholder: placeholder,
        onChanged: (_) {
          if (_addressError != null) {
            setState(() => _addressError = null);
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

  // ============================================================
  // DOCUMENT SECTION
  // ============================================================

  Widget _documentSection({
    required String title,
    required int documentId,
    required AppLocalizations l10n,
    bool required = false,
  }) {
    final uploadedDocuments = documents
        .where((doc) => doc.documentId == documentId)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  color: Colors.red,
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

  // ============================================================
  // UPLOAD BOX
  // ============================================================

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
        // child: Container(
        //   height: 70,
        //   decoration: BoxDecoration(
        //     color: AppColors.white,
        //     borderRadius: BorderRadius.circular(7),
        //     border: Border.all(color: const Color(0xff70ace0), width: 1.2),
        //   ),
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

  // ============================================================
  // UPLOADED FILE
  // ============================================================

  Widget _uploadedFile(RegisterDocument document) {
    final file = File(document.filePath);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(file, width: 42, height: 42, fit: BoxFit.cover),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              file.path.split(Platform.pathSeparator).last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xff222222)),
            ),
          ),

          const SizedBox(width: 8),

          // Delete
          GestureDetector(
            onTap: () {
              setState(() {
                documents.remove(document);
              });
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xffffeeee),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 19,
                color: Color(0xffef3d3d),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xff1D2A3A), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 8,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الدائرة الخضراء
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xff3BA957),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'لقد رفعت معلوماتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff222222),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "You'll check and open your account to receive trips\n"
                  "from shayel very soon\n"
                  "maybe check your paper take 2 days",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.5,
                    color: Color(0xff777777),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutePaths.firstChoose);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff006BB6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'الذهاب لصفحة الدخول',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
