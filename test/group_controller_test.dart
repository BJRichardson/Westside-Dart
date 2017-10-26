import 'harness/app.dart';
import 'dart:convert';

Future main() async {
  group("Success cases", () {
    TestApplication app = new TestApplication();

    List<String> tokens;

    setUp(() async {
      await app.start();

      tokens = [];
      var user1 = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "bob@westside.com",
          "password": "foobaraxegrind12%",
          "name": "Bobby",
          "roles": "admin,moderator"
        }).post();

      tokens.add(JSON.decode(user1.body)["access_token"]);

      var user2 = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "ted@westside.com",
          "password": "foobaraxegrind12%",
          "name": "Teddy"
        }).post();

      tokens.add(JSON.decode(user2.body)["access_token"]);

      var speaker1Query = new Query<User>()..where.name = "Bobby";
      await speaker1Query.fetchOne();

      var speaker2Query = new Query<User>()..where.name = "Teddy";
      await speaker2Query.fetchOne();

      var query1 = new Query<Group>()
        ..values.name = "New Group 1"
        ..values.description = "New description"
        ..values.chairperson = "Chairperson"
        ..values.email = "group@westside.com"
        ..values.phone = "404-231-8888";

      await query1.insert();

      var query2 = new Query<Group>()
        ..values.name = "New Group 2"
        ..values.description = "New description 2"
        ..values.chairperson = "Chairperson"
        ..values.email = "group@westside.com"
        ..values.phone = "404-231-8888";

      await query2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("GET /groups returns 401 without client_id secret", () async {
      var req = app.client.request("/groups");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /groups returns 401 with invalid client_id secret", () async {
      var req = app.client.clientAuthenticatedRequest(
          "/groups", clientID: "wrongID", clientSecret: "wrongsecret");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /groups returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/groups");
      var result = await req.get();

      expect(result, hasResponse(200, [
        {
          "id": 1,
          "name": "New Group 1",
          "description": "New description",
          "chairperson": "Chairperson",
          "email": "group@westside.com",
          "phone": "404-231-8888",
          "imageUrl": null
        },
        {
          "id": 2,
          "name": "New Group 2",
          "description": "New description 2",
          "chairperson": "Chairperson",
          "email": "group@westside.com",
          "phone": "404-231-8888",
          "imageUrl": null
        }
      ]));
    });

    test("GET /groups by Id returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/groups/1");
      var result = await req.get();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "name": "New Group 1",
            "description": "New description",
            "chairperson": "Chairperson",
            "email": "group@westside.com",
            "phone": "404-231-8888",
            "imageUrl": null
          }
      ));
    });

  });
}