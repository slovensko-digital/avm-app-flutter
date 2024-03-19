import 'package:autogram/bloc/present_signed_document_cubit.dart';
import 'package:test/test.dart';

/// Tests for the [PresentSignedDocumentCubit].
void main() {
  group('getTargetFileName', () {
    test('getTargetFileName returns name without suffix with timestamp', () {
      // Hardcoded clock
      clock() => DateTime.parse("2024-03-19T07:55:40");
      fn(String name) {
        return PresentSignedDocumentCubit.getTargetFileName(name, clock);
      }

      expect(
        fn("container-signed-xades-baseline-b.sce"),
        "container-signed-20240319075540.sce",
      );
      expect(
        fn("container-signed-xades-baseline-t.sce"),
        "container-signed-20240319075540.sce",
      );
      expect(
        fn("container-signed-cades-baseline-t.sce"),
        "container-signed-20240319075540.sce",
      );
      expect(
        fn("71580000-technicky-nakres-signed-pades-baseline-b.pdf"),
        "71580000-technicky-nakres-signed-20240319075540.pdf",
      );
      expect(
        fn("KPZ Mrkvička Hraško Final-signed-pades-baseline-t.pdf"),
        "KPZ Mrkvička Hraško Final-signed-20240319075540.pdf",
      );
    });
  });
}
