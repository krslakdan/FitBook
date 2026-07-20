import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/requests/news_item_insert_request.dart';
import '../models/requests/news_item_update_request.dart';
import '../models/responses/news_item_response.dart';
import '../providers/file_provider.dart';
import '../providers/news_item_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../widgets/crud/form_dialog.dart';
import '../widgets/crud/image_picker_field.dart';

class NewsItemsDetailsScreen extends StatefulWidget {
  const NewsItemsDetailsScreen({super.key, this.newsItem});

  final NewsItemResponse? newsItem;

  bool get isEdit => newsItem != null;

  @override
  State<NewsItemsDetailsScreen> createState() => _NewsItemsDetailsScreenState();
}

class _NewsItemsDetailsScreenState extends State<NewsItemsDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _titleController = TextEditingController(
    text: widget.newsItem?.title ?? '',
  );
  late final _contentController = TextEditingController(
    text: widget.newsItem?.content ?? '',
  );

  late bool _isActive = widget.newsItem?.isActive ?? true;

  bool _saving = false;
  String? _serverError;

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _imageError;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Naslov je obavezno polje.';
    if (text.length < 3) return 'Naslov mora imati najmanje 3 karaktera.';
    if (text.length > 200) {
      return 'Naslov ne smije biti duži od 200 karaktera.';
    }
    return null;
  }

  String? _validateContent(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Sadržaj je obavezno polje.';
    if (text.length < 10) return 'Sadržaj mora imati najmanje 10 karaktera.';
    return null;
  }

  Future<void> _save() async {
    setState(() => _serverError = null);

    final formValid = _formKey.currentState!.validate();
    if (!widget.isEdit && _pickedImageBytes == null) {
      setState(() => _imageError = 'Slika novosti je obavezna.');
      return;
    }
    if (!formValid) return;

    setState(() => _saving = true);

    try {
      String? imageUrl = widget.newsItem?.imageUrl;
      if (_pickedImageBytes != null) {
        imageUrl = await context.read<FileProvider>().uploadImage(
          bytes: _pickedImageBytes!,
          fileName: _pickedImageName!,
          folder: 'news',
        );
      }

      if (!mounted) return;
      final provider = context.read<NewsItemProvider>();
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.isEdit) {
        await provider.update(
          widget.newsItem!.id,
          NewsItemUpdateRequest(
            title: title,
            content: content,
            imageUrl: imageUrl!,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pop('Novost "$title" je uspješno izmijenjena.');
      } else {
        await provider.insert(
          NewsItemInsertRequest(
            title: title,
            content: content,
            imageUrl: imageUrl!,
            isActive: _isActive,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop('Novost "$title" je uspješno dodana.');
      }
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialogShell(
      title: widget.isEdit ? 'Izmjena novosti' : 'Dodaj novost',
      saving: _saving,
      serverError: _serverError,
      onSave: _save,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: ImagePickerField(
                label: 'Slika novosti',
                enabled: !_saving,
                pickedBytes: _pickedImageBytes,
                existingImageUrl: widget.newsItem?.imageUrl,
                errorText: _imageError,
                onPicked: (bytes, name) {
                  setState(() {
                    if (bytes.length > FileProvider.maxFileSizeBytes) {
                      _imageError =
                          'Slika je prevelika. Maksimalna veličina je 5 MB.';
                      return;
                    }
                    _imageError = null;
                    _pickedImageBytes = bytes;
                    _pickedImageName = name;
                  });
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FormFieldLabel('Naslov', required: true),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      hintText: 'Unesite naslov novosti',
                    ),
                    validator: _validateTitle,
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Sadržaj', required: true),
                  TextFormField(
                    controller: _contentController,
                    enabled: !_saving,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Unesite sadržaj novosti',
                    ),
                    validator: _validateContent,
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Status', required: true),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SwitchListTile(
                      value: _isActive,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      title: Text(
                        _isActive ? 'Aktivna' : 'Neaktivna',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      activeTrackColor: AppColors.primary,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _isActive = value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
