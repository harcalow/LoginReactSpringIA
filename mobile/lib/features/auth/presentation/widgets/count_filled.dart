import 'package:flutter/widgets.dart';

/// Cantidad de campos con contenido (ignorando espacios). Alimenta la barra de discos.
int countFilled(Iterable<TextEditingController> controllers) =>
    controllers.where((controller) => controller.text.trim().isNotEmpty).length;
