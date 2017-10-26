import 'harness/app.dart';

Future main() async {
  group("Success cases", () {
    TestApplication app = new TestApplication();

    setUp(() async {
      await app.start();
    });

    tearDown(() async {
      await app.stop();
    });

    test("Health check returns 200", () async {
      var req = app.client.request("/health");
      var result = await req.get();

      expect(result, hasStatus(200));
    });
  });
}