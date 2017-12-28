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

      var user1Query = new Query<User>()..where.firstName = "Bobby";
      var userOne = await user1Query.fetchOne();

      var user2Query = new Query<User>()..where.firstName = "Teddy";
      var userTwo = await user2Query.fetchOne();

      var query1 = new Query<Prayer>()
        ..values.prayer = "New Prayer 1"
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(120000)
        ..values.posterId = 1;
      var prayer1 = await query1.insert();

      var query2 = new Query<Prayer>()
        ..values.prayer = "New Prayer 2"
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(210000)
        ..values.posterId = 2;
      var prayer2 = await query2.insert();

      var userAnnounncementQuery = new Query<UserPrayer>()
        ..values.user = userOne
        ..values.prayer = prayer1;
      await userAnnounncementQuery.insert();

      var userAnnouncementQuery2 = new Query<UserPrayer>()
        ..values.user = userTwo
        ..values.prayer = prayer2;
      await userAnnouncementQuery2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("GET /prayers returns 401 without client_id secret", () async {
      var req = app.client.request("/prayers");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test(
        "GET /prayers returns 401 with invalid client_id secret", () async {
      var req = app.client.clientAuthenticatedRequest(
          "/prayers", clientID: "wrongID", clientSecret: "wrongsecret");
      var result = await req.get();

      expect(result, hasStatus(401));
    });

    test("GET /prayers returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/prayers");
      var result = await req.get();

      expect(result, hasResponse(200, [
        {
          "id": 2,
          "prayer": "New Prayer 2",
          "createdDate": "1970-01-01T00:03:30.000Z",
          "updatedDate": null,
          "poster": "{'id': 2, 'firstName': 'Teddy', 'lastName': null}"
        },
        {
          "id": 1,
          "prayer": "New Prayer 1",
          "createdDate": "1970-01-01T00:02:00.000Z",
          "updatedDate": null,
          "poster": "{'id': 1, 'firstName': 'Bobby', 'lastName': null}"
        }
      ]));
    });

    test("GET /prayers by Id returns data", () async {
      var req = app.client.clientAuthenticatedRequest("/prayers/1");
      var result = await req.get();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "prayer": "New Prayer 1",
            "createdDate": "1970-01-01T00:02:00.000Z",
            "updatedDate": null,
            "poster": "{'id': 1, 'firstName': 'Bobby', 'lastName': null}"
          }
      ));
    });
  });
}
