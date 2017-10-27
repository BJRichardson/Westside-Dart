import 'harness/app.dart';
import 'dart:convert';

Future main() async {
  group("Success cases", () {
    TestApplication app = new TestApplication();
    List<String> tokens;

    setUp(() async {
      await app.start();

      tokens = [];
      for (var i = 0; i < 6; i++) {
        var response = await (app.client.clientAuthenticatedRequest("/register")
          ..json = {
            "username": "bob+@westside.com",
            "password": "foobaraxegrind12%",
            "lastName": "Washington"
          })
            .post();
        tokens.add(JSON.decode(response.body)["access_token"]);
      }

      var user = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "ted@westside.com",
          "password": "foobaraxegrind12%",
          "firstName": "Teddy",
          "roles": "admin,moderator",
          "lastName": "Alexander"
        }).post();

    });

    tearDown(() async {
      await app.stop();
    });

    test("Can get user with valid credentials", () async {
      var response = await (app.client
          .authenticatedRequest("/users/1", accessToken: tokens[0])
          .get());

      expect(response,
          hasResponse(200, partial({"username": "bob+0@westside.com"})));
    });

    test("Can get users with valid credentials", () async {
      var response = await (app.client.authenticatedRequest("/users", accessToken: tokens[0]).get());

      expect(response,
          hasResponse(200, [
            {
              "id": 7,
              "email": "ted@westside.com",
              "firstName": "Teddy",
              "lastName": "Alexander",
              "phone": null,
              "address": null,
              "imageUrl": null,
              "roles": "admin,moderator",
              "username": "ted@westside.com"
            },
            {
              "id": 1,
              "email": "bob+@westside.com",
              "firstName": null,
              "lastName": "Washington",
              "phone": null,
              "address": null,
              "imageUrl": null,
              "roles": null,
              "username": "bob+@westside.com"
            }
          ]));
    });

    test("Can get user with role", () async {
      var userQuery = new Query<User>()
        ..where.firstName = "Teddy";

      var user = await userQuery.fetchOne();

      expect(user.containsRole("admin"), true);
      expect(user.containsRole("superman"), false);
    });
  });

  group("Failure cases", () {
    TestApplication app = new TestApplication();
    var tokens;

    setUp(() async {
      await app.start();

      var responses = await Future.wait([0, 1, 2, 3, 4, 5].map((i) {
        return (app.client.clientAuthenticatedRequest("/register")
          ..json = {
            "username": "bob+$i@westside.com",
            "password": "foobaraxegrind$i%"
          })
            .post();
      }));

      tokens = responses
          .map((resp) => JSON.decode(resp.body)["access_token"])
          .toList();
    });

    tearDown(() async {
      await app.stop();
    });

    test("Updating user fails if not owner", () async {
      var response = await (app.client.authenticatedRequest("/users/1",
          accessToken: tokens[4])..json = {"email": "a@a.com"})
          .put();

      expect(response, hasStatus(401));
    });
  });
}
