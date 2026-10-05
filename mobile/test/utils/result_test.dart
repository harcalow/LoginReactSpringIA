import 'package:flutter_test/flutter_test.dart';
import 'package:login_gym/utils/result.dart';

void main() {
  test('AppException lee el detalle y los errores por campo de un Problem Detail', () {
    final error = AppException.fromProblem(400, {
      'detail': 'Datos de entrada inválidos',
      'errors': {'email': 'El correo es obligatorio'},
    });

    expect(error.status, 400);
    expect(error.message, 'Datos de entrada inválidos');
    expect(error.fieldErrors, {'email': 'El correo es obligatorio'});
    expect(error.isUnauthorized, isFalse);
  });
}
