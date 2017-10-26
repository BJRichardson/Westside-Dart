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
      var userOne = await user1Query.fetchOne();

      var user2Query = new Query<User>()..where.name = "Teddy";
      var userTwo = await user2Query.fetchOne();

      var query1 = new Query<Announcement>()
        ..values.announcement = "New Announcement 1"
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(120000)
        ..values.posterId = 1
        ..values.groupId = 1
        ..values.imageUrl = "Nothing";
      var announcement1 = await query1.insert();

      var query2 = new Query<Announcement>()
        ..values.announcement = "New Announcement 2"
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.posterId = 2
        ..values.groupId = 2
        ..values.imageUrl = "Nothing";
      var announcement2 = await query2.insert();

      var query3 = new Query<Group>()
        ..values.name = "New Group"
        ..values.description = "description"
        ..values.chairperson = "Chairperson"
        ..values.phone = "1234567890"
        ..values.email = "email";
      await query3.insert();

      var query4 = new Query<Group>()
        ..values.name = "New Group 2"
        ..values.description = "description"
        ..values.chairperson = "Chairperson"
        ..values.phone = "1234567890"
        ..values.email = "email";
      await query4.insert();

      var userAnnounncementQuery = new Query<UserAnnouncement>()
        ..values.user = userOne
        ..values.announcement = announcement1;
      await userAnnounncementQuery.insert();

      var userAnnouncementQuery2 = new Query<UserAnnouncement>()
        ..values.user = userTwo
        ..values.announcement = announcement2;
      await userAnnouncementQuery2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("GET /announcements returns 401 without client_id secret", () async {
      var req = app.client.request("/announcements");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test(
        "GET /announcements returns 401 with invalid client_id secret", () async {
      var req = app.client.clientAuthenticatedRequest(
          "/announcements", clientID: "wrongID", clientSecret: "wrongsecret");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /announcements returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/announcements");
      var result = await req.get();

      expect(result, hasResponse(200, [
        {
          "id": 2,
          "announcement": "New Announcement 2",
          "createdDate": "1970-01-01T00:03:30.000Z",
          "updatedDate": null,
          "groupId": 2,
          "imageUrl": "Nothing",
          "poster": "{id: 2, name: Teddy}"
        },
        {
          "id": 1,
          "announcement": "New Announcement 1",
          "createdDate": "1970-01-01T00:02:00.000Z",
          "updatedDate": null,
          "groupId": 1,
          "imageUrl": "Nothing",
          "poster": "{id: 1, name: Bobby}"
        }
      ]));
    });

    test("GET /announcements by Id returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/announcements/1");
      var result = await req.get();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "announcement": "New Announcement 1",
            "createdDate": "1970-01-01T00:02:00.000Z",
            "updatedDate": null,
            "groupId": 1,
            "imageUrl": "Nothing",
            "poster": "{id: 1, name: Bobby}"
          }
      ));
    });

    test("GET /announcements/group by groupId returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/announcements/group/2");
      var result = await req.get();

      expect(result, hasResponse(200,
          {
            "id": 2,
            "announcement": "New Announcement 2",
            "createdDate": "1970-01-01T00:03:30.000Z",
            "updatedDate": null,
            "groupId": 2,
            "imageUrl": "Nothing",
            "poster": '{id: 2, name: Teddy}'
          }
      ));
    });
  });
}
