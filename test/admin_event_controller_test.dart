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
          "firstName": "Teddy",
        }).post();

      tokens.add(JSON.decode(user2.body)["access_token"]);

      var speaker1Query = new Query<User>()..where.firstName = "Bobby";
      await speaker1Query.fetchOne();

      var speaker2Query = new Query<User>()..where.firstName = "Teddy";
      await speaker2Query.fetchOne();

      var query1 = new Query<Event>()
        ..values.title = "New Event 1"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(120000)
        ..values.description = "New description"
        ..values.creatorId = 1
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(122000)
        ..values.moreInformation = "Nothing"
        ..values.imageUrl = "Nothing";
      var event1 = await query1.insert();

      var query2 = new Query<Event>()
        ..values.title = "New Event 2"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.description = "New description 2"
        ..values.creatorId = 2
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(212000)
        ..values.moreInformation = "Nothing 2"
        ..values.imageUrl = "Nothing";
      var event2 = await query2.insert();

      var query5 = new Query<Event>()
        ..values.title = "Future Event 3"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(2500000009999)
        ..values.description = "New description 3"
        ..values.creatorId = 1
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(2540000009999)
        ..values.moreInformation = "Nothing 3"
        ..values.imageUrl = "Nothing";
      var event3 = await query5.insert();

      var query3 = new Query<Group>()
        ..values.name = "New Group"
        ..values.description = "description"
        ..values.chairperson = "Chairperson"
        ..values.phone = "1234567890"
        ..values.email = "email";
      var group1 = await query3.insert();

      var query4 = new Query<Group>()
        ..values.name = "New Group 2"
        ..values.description = "description"
        ..values.chairperson = "Chairperson"
        ..values.phone = "1234567890"
        ..values.email = "email";
      var group2 = await query4.insert();

      var groupEventQuery = new Query<GroupEvent>()
        ..values.event = event1
        ..values.group = group1;

      await groupEventQuery.insert();

      var groupEventQuery2 = new Query<GroupEvent>()
        ..values.event = event2
        ..values.group = group2;

      await groupEventQuery2.insert();

      var groupEventQuery3 = new Query<GroupEvent>()
        ..values.event = event3
        ..values.group = group2;
      await groupEventQuery3.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("GET /events returns data", () async {
      var req =app.client.authenticatedRequest("admin/events", accessToken: tokens[0]);
      var result = await req.get();

      expect(result, hasResponse(200, [
        {
          "id": 3,
          "creatorId": 1,
          "title": "Future Event 3",
          "startTime": "2049-03-22T04:26:49.999Z",
          "description": "New description 3",
          "endTime": "2050-06-28T03:33:29.999Z",
          "moreInformation": "Nothing 3",
          "imageUrl": "Nothing",
          "groups": [{"id":2,"name":"New Group 2"}],
          "users": []
        }
      ]));
    });

    test("PUT /events by Id returns data", () async {
      var req = app.client.authenticatedRequest("admin/events/1", accessToken: tokens[0])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "creatorId": 1,
            "title": "New Event 1",
            "startTime": "1970-01-01T00:02:00.000Z",
            "description": "updated description",
            "endTime": "1970-01-01T00:02:02.000Z",
            "imageUrl": "Nothing",
            "moreInformation": "Nothing"
          }
      ));
    });

    test("PUT /events by Id fails with bad Id", () async {
      var req = app.client.authenticatedRequest("admin/events/9001", accessToken: tokens[0])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("PUT /events by Id fails for non-admin with 401", () async {
      var req = app.client.authenticatedRequest("admin/events/1", accessToken: tokens[1])
        ..json = {
          "description": "updated description"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("DELETE /events by Id for user with admin role", () async {
      var req = app.client.authenticatedRequest("admin/events/1", accessToken: tokens[0]);
      var result = await req.delete();

      expect(result, hasStatus(200));

      var req2 = app.client.clientAuthenticatedRequest("/events/1");
      var result2 = await req2.get();

      expect(result2, hasStatus(404));

      var req3 = app.client.authenticatedRequest("admin/events/2", accessToken: "Fake Token");
      var result3 = await req3.delete();

      expect(result3, hasStatus(401));
    });

    test("POST /event posts data", () async {
      var req = app.client.authenticatedRequest("admin/events", accessToken: tokens[0])
        ..json = {
          "title": "New Event 3",
          "startTime": "1970-01-01T00:04:00.000Z",
          "description": "New description 3",
          "creatorId": 1,
          "endTime": "1970-01-01T00:06:02.000Z",
          "moreInformation": "Nothing 3",
          "imageUrl": "Nothing",
          "groupIds": [1]
        };
      var result = await req.post();

      expect(result, hasResponse(200,
          {
            "id": 4,
            "creatorId": 1,
            "title": "New Event 3",
            "startTime": "1970-01-01T00:04:00.000Z",
            "description": "New description 3",
            "endTime": "1970-01-01T00:06:02.000Z",
            "moreInformation": "Nothing 3",
            "imageUrl": "Nothing",
            "groups": [{"id": 1, "name": "New Group"}]
          }
      ));

      var req2 = app.client.authenticatedRequest("admin/events", accessToken: tokens[1])
        ..json = {
          "title": "New Event 4",
          "startTime": "1970-01-01T00:04:00.000Z",
          "description": "New description 3",
          "endTime": "1970-01-01T00:06:02.000Z",
          "moreInformation": "Nothing 3",
          "imageUrl": "Nothing",
          "groupIds": [1]
        };
      var result2 = await req2.post();

      expect(result2, hasStatus(401));

    });
  });
}