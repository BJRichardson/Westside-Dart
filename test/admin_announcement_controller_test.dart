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
          "firstName": "Bobby",
          "roles": "admin,moderator"
        }).post();

      tokens.add(JSON.decode(user1.body)["access_token"]);

      var user2 = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "ted@westside.com",
          "password": "foobaraxegrind12%",
          "firstName": "Teddy"
        }).post();

      tokens.add(JSON.decode(user2.body)["access_token"]);

      var speaker1Query = new Query<User>()..where.firstName = "Bobby";
      var user3 = await speaker1Query.fetchOne();

      var speaker2Query = new Query<User>()..where.firstName = "Teddy";
      var user4 = await speaker2Query.fetchOne();

      var query1 = new Query<Announcement>()
        ..values.announcement = "Test Announcement"
        ..values.posterId = 1
        ..values.groupId = 1
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(120000)
        ..values.imageUrl = "Nothing";

      var announcement1 = await query1.insert();

      var query2 = new Query<Announcement>()
        ..values.announcement = "Test Announcement 2"
        ..values.posterId = 2
        ..values.groupId = 2
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.imageUrl = "Nothing 2";

      var announcement2 = await query2.insert();

      var groupEventQuery = new Query<UserAnnouncement>()
        ..values.announcement = announcement1
        ..values.user = user3;
      await groupEventQuery.insert();

      var groupEventQuery2 = new Query<UserAnnouncement>()
        ..values.announcement = announcement2
        ..values.user = user4;
      await groupEventQuery2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("PUT /announcements by Id returns data", () async {
      var req = app.client.authenticatedRequest("admin/announcements/1", accessToken: tokens[0])
        ..json = {
          "announcement": "updated announcement",
          "updatedDate": "1970-01-01T00:02:02.000Z"
        };
      var result = await req.put();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "announcement": "updated announcement",
            "groupId": 1,
            "createdDate": "1970-01-01T00:02:00.000Z",
            "imageUrl": "Nothing",
            "updatedDate": "1970-01-01T00:02:02.000Z"
          }
      ));
    });

    test("PUT /announcements by Id fails with bad Id", () async {
      var req = app.client.authenticatedRequest("admin/announcements/9001", accessToken: tokens[0])
        ..json = {
          "announcement": "updated announcement",
          "updatedDate": "1970-01-01T00:02:02.000Z"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("PUT /announcements by Id fails for non-admin with 401", () async {
      var req = app.client.authenticatedRequest("admin/announcements/1", accessToken: tokens[1])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("DELETE /announcements by Id for user with admin role", () async {
      var req = app.client.authenticatedRequest("admin/announcements/1", accessToken: tokens[0]);
      var result = await req.delete();

      expect(result, hasStatus(200));

      var req2 = app.client.clientAuthenticatedRequest("/announcements/1");
      var result2 = await req2.get();

      expect(result2, hasStatus(404));

      var req3 = app.client.authenticatedRequest("admin/announcements/2", accessToken: "Fake Token");
      var result3 = await req3.delete();

      expect(result3, hasStatus(401));
    });

    test("POST /announcements posts data", () async {
      var req = app.client.authenticatedRequest("admin/announcements", accessToken: tokens[0])
        ..json = {
          "announcement": "updated announcement",
          "groupId": 1,
          "posterId": 1,
          "updatedDate": null,
          "createdDate": "1970-01-01T00:02:00.000Z",
          "imageUrl": "Nothing"
        };
      var result = await req.post();

      expect(result, hasResponse(200,
          {
            "id": 3,
            "announcement": "updated announcement",
            "groupId": 1,
            "createdDate": "1970-01-01T00:02:00.000Z",
            "updatedDate": null,
            "imageUrl": "Nothing",
            "poster": {"id": 1, "firstName": "Bobby"}
          }
      ));

      var req2 = app.client.authenticatedRequest("admin/announcements", accessToken: tokens[1])
        ..json = {
          "announcement": "updated announcement",
          "groupId": 1,
          "posterId": 1,
          "createdDate": "1970-01-01T00:02:00.000Z",
          "imageUrl": "Nothing"
        };
      var result2 = await req2.post();

      expect(result2, hasStatus(401));

    });
  });
}