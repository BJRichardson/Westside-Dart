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

      var user1Query = new Query<User>()..where.name = "Bobby";
      var user3 = await user1Query.fetchOne();

      var user2Query = new Query<User>()..where.name = "Teddy";
      var user4 = await user2Query.fetchOne();

      var query1 = new Query<Group>()
        ..values.name = "New Group 1"
        ..values.description = "New description"
        ..values.chairperson = "Chairperson"
        ..values.email = "group@westside.com"
        ..values.imageUrl = "Nothing"
        ..values.phone = "404-231-8888";

      var group1 = await query1.insert();

      var query2 = new Query<Group>()
        ..values.name = "New Group 2"
        ..values.description = "New description 2"
        ..values.chairperson = "Chairperson"
        ..values.email = "group@westside.com"
        ..values.imageUrl = "Nothing"
        ..values.phone = "404-231-8888";

      var group2 = await query2.insert();

      var userGroupQuery = new Query<UserGroup>()
        ..values.user = user3
        ..values.group = group1;

      await userGroupQuery.insert();

      var userGroupQuery2 = new Query<UserGroup>()
        ..values.user = user4
        ..values.group = group2;

      await userGroupQuery2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("PUT /groups by Id returns data", () async {
      var req = app.client.authenticatedRequest("admin/groups/1", accessToken: tokens[0])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "name": "New Group 1",
            "description": "updated description",
            "chairperson": "Chairperson",
            "email": "group@westside.com",
            "imageUrl": "Nothing",
            "phone": "404-231-8888"
          }
      ));
    });

    test("PUT /groups by Id fails with bad Id", () async {
      var req = app.client.authenticatedRequest("admin/groups/9001", accessToken: tokens[0])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasStatus(404));
    });

    test("PUT /groups by Id fails for non-admin with 401", () async {
      var req = app.client.authenticatedRequest("admin/groups/1", accessToken: tokens[1])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("DELETE /groups by Id for user with admin role", () async {
      var req = app.client.authenticatedRequest("admin/groups/1", accessToken: tokens[0]);
      var result = await req.delete();

      expect(result, hasStatus(200));

      var req2 = app.client.clientAuthenticatedRequest("/groups/1");
      var result2 = await req2.get();

      expect(result2, hasStatus(404));

      var req3 = app.client.authenticatedRequest("admin/groups/2", accessToken: "Fake Token");
      var result3 = await req3.delete();

      expect(result3, hasStatus(401));
    });

    test("POST /event posts data", () async {
      var req = app.client.authenticatedRequest("admin/groups", accessToken: tokens[0])
        ..json = {
          "name": "New Group 3",
          "description": "New description 3",
          "chairperson": "Chairperson",
          "email": "group@westside.com",
          "imageUrl": "Nothing",
          "phone": "404-231-8888",
          "userIds": [1]
        };
      var result = await req.post();

      expect(result, hasResponse(200,
          {
            "id": 3,
            "name": "New Group 3",
            "description": "New description 3",
            "chairperson": "Chairperson",
            "email": "group@westside.com",
            "imageUrl": "Nothing",
            "phone": "404-231-8888",
            "users": [{"id": 1, "name": "Bobby"}]
          }
      ));

      var req2 = app.client.authenticatedRequest("admin/groups", accessToken: tokens[1])
        ..json = {
          "name": "New Group 4",
          "description": "New description 3",
          "userIds": [1]
        };
      var result2 = await req2.post();

      expect(result2, hasStatus(401));

    });
  });
}