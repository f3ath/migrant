import 'package:migrant/migrant.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Equality', () {
    expect(Migration('00', 'Hello'), equals(Migration('00', 'Hello')));
    expect(Migration('00', 'Hello'), isNot(equals(Migration('00', 'World'))));
    expect(Migration('00', 'Hello'), isNot(equals(Migration('01', 'Hello'))));
    expect(Migration('00', 'Hello'), isNot(equals(Migration('01', 'World'))));
  });
}