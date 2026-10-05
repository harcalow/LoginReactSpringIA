/// Cantidad de valores con contenido (ignorando espacios). Alimenta la barra de discos.
int countFilled(Iterable<String> values) => values.where((value) => value.trim().isNotEmpty).length;
