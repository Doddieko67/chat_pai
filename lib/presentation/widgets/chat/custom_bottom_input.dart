import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';

class CustomBottomInput extends StatefulWidget {
  final Function(types.PartialText, {List<XFile> images}) onSend;
  final Function()? onAttachmentPressed;

  const CustomBottomInput({
    super.key,
    required this.onSend,
    this.onAttachmentPressed,
  });

  @override
  State<CustomBottomInput> createState() => _CustomBottomInputState();
}

class _CustomBottomInputState extends State<CustomBottomInput> {
  String text = '';
  final TextEditingController controller = TextEditingController();
  List<XFile> images = [];

  @override
  Widget build(BuildContext context) {
    void onTextChanged(String value) {
      setState(() {
        text = value;
      });
    }

    void onSend() {
      if (text.isEmpty) return;
      final partialText = types.PartialText(text: text);

      widget.onSend(partialText, images: images);
      setState(() {
        text = '';
        controller.clear();
        images = [];
      });
    }

    void onAttachmentPressed() async {
      ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(limit: 4);
      if (images.isEmpty) return;

      setState(() {
        this.images = images;
      });
    }

    void onDeleteImage(String path) {
      setState(() {
        images.removeWhere((element) => element.path == path);
      });
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Column(
          children: [
            // Imágenes adjuntas
            if (images.isNotEmpty)
              _ImageAttachments(images: images, onDeleteImage: onDeleteImage),

            Row(
              children: [
                // Botón para adjuntar archivos
                IconButton(
                  onPressed: onAttachmentPressed,
                  icon: const Icon(Icons.add_a_photo, color: Colors.black),
                ),
                // Campo de texto expandible
                _TextInput(
                  onTextChanged: onTextChanged,
                  controller: controller,
                ),
                // Botón de enviar con ícono de avión
                IconButton(
                  onPressed: text.isEmpty ? null : onSend,
                  icon: Icon(
                    Icons.send,
                    color: text.isEmpty ? Colors.grey : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final Function(String) onTextChanged;
  final TextEditingController controller;

  const _TextInput({required this.onTextChanged, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: TextField(
        controller: controller,
        // Función que se ejecuta cuando el texto cambia
        onChanged: onTextChanged,

        maxLines: 4, // Permite múltiples líneas
        minLines: 1, // Comienza con una línea

        decoration: InputDecoration(
          hintText: 'Escribe un mensaje...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.primaryContainer,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),

        // Limita a 4 líneas máximo
      ),
    );
  }
}

class _ImageAttachments extends StatelessWidget {
  final List<XFile> images;
  final Function(String) onDeleteImage;

  const _ImageAttachments({required this.images, required this.onDeleteImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: images
            .map(
              (e) =>
                  _ImageAttachment(path: e.path, onDeleteImage: onDeleteImage),
            )
            .toList(),
      ),
    );
  }
}

class _ImageAttachment extends StatelessWidget {
  final String path;
  final Function(String) onDeleteImage;

  const _ImageAttachment({required this.path, required this.onDeleteImage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Mostrar imagen en pantalla completa o realizar alguna acción
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path)),
              ),
            ),
          ),
        );
      },
      onDoubleTap: () {
        onDeleteImage(path);
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
