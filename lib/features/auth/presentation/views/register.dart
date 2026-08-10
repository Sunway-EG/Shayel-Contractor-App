import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../../domain/entities/register_document.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController(text: 'أحمد');
  final phoneController = TextEditingController(text: '10 234 5678');
  final addressController = TextEditingController(
    text: '102 طريق أولين شرقي موبين، VIC 3000',
  );
  final List<RegisterDocument> documents = [];
  bool agree = false;
  Future<void> _pickDocument({required int documentId}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = result.files.single;

    final document = RegisterDocument(
      documentId: documentId,
      filePath: file.path!,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    );

    setState(() {
      documents.add(document);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xff333333),
            ),
          ),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Color(0xff006BB6),
                size: 21,
              ),
              SizedBox(width: 7),
              Text(
                'ارفع مستنداتك',
                style: TextStyle(
                  color: Color(0xff006BB6),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xffeeeeee)),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =========================
                // معلومات المقاول
                // =========================
                const Text(
                  'معلومات المقاول',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111111),
                  ),
                ),

                const SizedBox(height: 16),

                _label('الاسم الكامل'),

                const SizedBox(height: 6),

                _textField(controller: nameController),

                const SizedBox(height: 14),

                _label('رقم الهاتف'),

                const SizedBox(height: 6),

                _phoneField(),

                const SizedBox(height: 14),

                _label('تفاصيل العنوان'),

                const SizedBox(height: 6),

                _addressField(),

                const SizedBox(height: 24),

                // =========================
                // المستندات
                // =========================
                const Text(
                  'المستندات',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111111),
                  ),
                ),

                const SizedBox(height: 14),

                // الهوية الوطنية
                _documentSection(
                  title: 'الهوية الوطنية',
                  documentId: 31,

                  files: const ['صورة-الهوية.jpg'],
                ),

                const SizedBox(height: 20),

                // السجل التجاري
                _documentSection(
                  title: 'السجل التجاري',
                  documentId: 32,
                  files: const ['صورة-السجل.jpg', 'صورة-السجل.jpg'],
                ),

                const SizedBox(height: 20),

                // البطاقة الضريبية
                _documentSection(
                  title: 'البطاقة الضريبية',
                  documentId: 33,
                  files: const [],
                ),

                const SizedBox(height: 20),

                // =========================
                // الموافقة
                // =========================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: agree,
                        onChanged: (value) {
                          setState(() {
                            agree = value ?? false;
                          });
                        },
                        activeColor: const Color(0xff006BB6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        'أؤكد أن تفاصيل المستندات المقدمة صحيحة وأوافق '
                        'على معالجة هذه البيانات وفقاً لسياسة الخصوصية.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // =========================
                // زر التأكيد
                // =========================
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: agree
                        ? () {
                            context.read<AuthBloc>().add(
                              AuthRegisterRequested(
                                fullName: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                address: addressController.text.trim(),
                                documents: documents,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff006BB6),
                      disabledBackgroundColor: const Color(0xff006BB6),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
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
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 13,
        color: Color.fromARGB(255, 0, 0, 0),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({required TextEditingController controller}) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xff222222),
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xffdddddd)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xffdddddd)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xff006BB6)),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHONE
  // ============================================================

  Widget _phoneField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xfff4f4f4),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('🇪🇬', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  '+20',
                  style: TextStyle(fontSize: 13, color: Color(0xff222222)),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Color(0xff777777),
                ),
              ],
            ),
          ),

          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
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

  Widget _addressField() {
    return TextField(
      controller: addressController,
      maxLines: 4,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 7, 7, 7),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xffdddddd)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xffdddddd)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xff006BB6)),
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
    required List<String> files,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 13,
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        _uploadBox(documentId: documentId),

        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),

          ...files.map(
            (file) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _uploadedFile(file),
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // UPLOAD BOX
  // ============================================================

  Widget _uploadBox({required int documentId}) {
    return GestureDetector(
      onTap: () => _pickDocument(documentId: documentId),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xff70ace0), width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xffeef7ff),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 22,
                color: Color(0xff0071C8),
              ),
            ),

            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'رفع صورة أو تصفح',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff222222),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PNG, JPG بحد أقصى 10 ميجابايت',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff777777),
                      fontWeight: FontWeight.bold,
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

  Widget _uploadedFile(String fileName) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          // thumbnail
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffe1e1e1)),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
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

                const SizedBox(height: 3),

                const Text(
                  '2.4 MB',
                  style: TextStyle(fontSize: 10, color: Color(0xff888888)),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // upload
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xffedf7ff),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_outlined,
              size: 18,
              color: Color(0xff0071C8),
            ),
          ),

          const SizedBox(width: 7),

          // delete
          Container(
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
        ],
      ),
    );
  }
}
