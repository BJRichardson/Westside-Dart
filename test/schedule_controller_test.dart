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

      var query1 = new Query<Event>()
        ..values.title = "New Event 1"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(120000)
        ..values.description = "New description"
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(122000)
        ..values.moreInformation = "Nothing";

      var event1 = await query1.insert();

      var query2 = new Query<Event>()
        ..values.title = "New Event 2"
        ..values.startTime = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.description = "New description 2"
        ..values.endTime = new DateTime.fromMillisecondsSinceEpoch(212000)
        ..values.moreInformation = "Nothing 2";

      var event2 = await query2.insert();

      var userEvent = new Query<UserEvent>()
        ..values.user = user
        ..values.event = event1;

      await userEvent.insert();

      userEvent = new Query<UserEvent>()
        ..values.user = user
        ..values.event = event2;

      await userEvent.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("/GET UserEvent", () async {
      var req = app.client.authenticatedRequest("/schedule");
      var result = await req.get();

      expect(result, hasResponse(200, [
        {"id": 1, "isAttending": null, "user": {"id": 1}, "event": {"id": 1}},
        {"id": 2, "isAttending": null, "user": {"id": 1}, "event": {"id": 2}}
      ]));
    });

    test("/POST UserEvent", () async {
      var req = app.client.authenticatedRequest("/schedule/2");
      var result = await req.post();

      expect(result, hasResponse(200,
          {"id": 3, "isAttending": null, "user": {"id": 1}, "event": {"id": 2}}
      ));
    });

    test("/DELETE UserEvent", () async {
      var req = app.client.authenticatedRequest("/schedule/1");
      var result = await req.delete();

      expect(result, hasStatus(200));

      req = app.client.authenticatedRequest("/schedule");
      result = await req.get();

      expect(result, hasResponse(200, [
        {"id": 2, "isAttending": null, "user": {"id": 1}, "event": {"id": 2}}
      ]));
    });

    test("Can't DELETE other users' events", () async {
      var tokenResponse = await (app.client.clientAuthenticatedRequest("/register")
        ..json = {
          "username": "test@westside.com",
          "password": "l3tm31n"
        }).post();

      var token = JSON.decode(tokenResponse.body)["access_token"];

      var req = app.client.authenticatedRequest("/schedule/1", accessToken: token);
      var result = await req.delete();

      expect(result, hasStatus(404));
    });
  });
}