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
          "biography": "Chess Master",
          "roles": "admin,moderator"
        }).post();

      tokens.add(JSON.decode(user1.body)["access_token"]);

      var user2 = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "ted@westside.com",
          "password": "foobaraxegrind12%",
          "firstName": "Teddy",
          "biography": "Rough Rider"
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
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(122000)
        ..values.moreInformation = "Nothing"
        ..values.imageUrl = "Nothing";
      var event1 = await query1.insert();

      var query2 = new Query<Event>()
        ..values.title = "New Event 2"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.description = "New description 2"
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(212000)
        ..values.moreInformation = "Nothing 2"
        ..values.imageUrl = "Nothing";
      var event2 = await query2.insert();

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
    });

    tearDown(() async {
      await app.stop();
    });

    test("GET /events returns 401 without client_id secret", () async {
      var req = app.client.request("/events");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /events returns 401 with invalid client_id secret", () async {
      var req = app.client.clientAuthenticatedRequest(
          "/events", clientID: "wrongID", clientSecret: "wrongsecret");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /events returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/events");
      var result = await req.get();

      expect(result, hasResponse(200, [
          {
            "id": 2,
            "title": "New Event 2",
            "startTime": "1970-01-01T00:03:30.000Z",
            "description": "New description 2",
            "endTime": "1970-01-01T00:03:32.000Z",
            "moreInformation": "Nothing 2",
            "imageUrl": "Nothing",
            "groups": [{"id":2,"name":"New Group 2"}]
          },
          {
            "id": 1,
            "title": "New Event 1",
            "startTime": "1970-01-01T00:02:00.000Z",
            "description": "New description",
            "endTime": "1970-01-01T00:02:02.000Z",
            "moreInformation": "Nothing",
            "imageUrl": "Nothing",
            "groups": [{"id":1,"name":"New Group"}]

          }
      ]));
    });

    test("GET /events by Id returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/events/1");
      var result = await req.get();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "title": "New Event 1",
            "startTime": "1970-01-01T00:02:00.000Z",
            "description": "New description",
            "endTime": "1970-01-01T00:02:02.000Z",
            "moreInformation": "Nothing",
            "imageUrl": "Nothing",
            "groups": [{"id":1,"name":"New Group"}]
          }
      ));
    });

  });
}
