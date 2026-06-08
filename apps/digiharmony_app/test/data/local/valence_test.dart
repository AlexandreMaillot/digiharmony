import 'package:digiharmony_app/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('valencePour — mapping déterministe (DEC-SH-002)', () {
    // Positives : happy, calm, dynamic → >= 0
    test(
      'VAL-1 : happy → >= 0',
      () => expect(valencePour('happy'), greaterThanOrEqualTo(0)),
    );
    test(
      'VAL-2 : calm → >= 0',
      () => expect(valencePour('calm'), greaterThanOrEqualTo(0)),
    );
    test(
      'VAL-3 : dynamic → >= 0',
      () => expect(valencePour('dynamic'), greaterThanOrEqualTo(0)),
    );

    // Négatives : sad, angry, nervous, tired → < 0
    test('VAL-4 : sad → < 0', () => expect(valencePour('sad'), lessThan(0)));
    test(
      'VAL-5 : angry → < 0',
      () => expect(valencePour('angry'), lessThan(0)),
    );
    test(
      'VAL-6 : nervous → < 0',
      () => expect(valencePour('nervous'), lessThan(0)),
    );
    test(
      'VAL-7 : tired → < 0',
      () => expect(valencePour('tired'), lessThan(0)),
    );
  });
}
