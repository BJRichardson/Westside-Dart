import 'harness/app.dart';
import 'dart:convert';

Future main() async {
  group("Success cases", () {
    TestApplication app = new TestApplication();

    setUp(() async {
      await app.start();

      var req = app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "bob@westside.com",
          "password": "foobaraxegrind12%"
        };

      app.client.defaultAccessToken = (await req.post()).asMap["access_token"];

      var userQuery = new Query<User>()
        ..values.username = "bob@westside.com";

      var user = await userQuery.fetchOne();

      var query1 = new Query<Group>()
        ..values.name = "New Group 1"
        ..values.description = "New description";

      var group1 = await query1.insert();

      var query2 = new Query<Group>()
        ..values.name = "New Group 2"
        ..values.description = "New description 2";

      var group2 = await query2.insert();

      var userGroup = new Query<UserGroup>()
        ..values.user = user
        ..values.group = group1;

      await userGroup.insert();

      userGroup = new Query<UserGroup>()
        ..values.user = user
        ..values.group = group2;

      await userGroup.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("/GET UserGroup", () async {
      var req = app.client.authenticatedRequest("/ministries");
      var result = await req.get();

      expect(result, hasResponse(200, [
        {"id": 1, "user": {"id": 1}, "group": {"id": 1}},
        {"id": 2, "user": {"id": 1}, "group": {"id": 2}}
      ]));
    });

    test("/POST UserGroup", () async {
      var req = app.client.authenticatedRequest("/ministries/2");
      var result = await req.post();

      expect(result, hasResponse(200,
          {"id": 3, "user": {"id": 1}, "group": {"id": 2}}
      ));
    });

    test("/DELETE UserGroup", () async {
      var req = app.client.authenticatedRequest("/ministries/1");
      var result = await req.delete();

      expect(result, hasStatus(200));

      req = app.client.authenticatedRequest("/ministries");
      result = await req.get();

      expect(result, hasResponse(200, [
        {"id": 2, "user": {"id": 1}, "group": {"id": 2}}
      ]));
    });

    test("Can't DELETE other users' events", () async {
      var tokenResponse = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "test@westside.com",
          "password": "l3tm31n"
        }).post();

      var token = JSON.decode(tokenResponse.body)["access_token"];

      var req = app.client.authenticatedRequest("/ministries/1", accessToken: token);
      var result = await req.delete();

      expect(result, hasStatus(404));
    });
  });
}