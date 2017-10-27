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
      var user3 = await user1Query.fetchOne();

      var user2Query = new Query<User>()..where.firstName = "Teddy";
      var user4 = await user2Query.fetchOne();

      var query1 = new Query<Prayer>()
        ..values.prayer = "Test Prayer"
        ..values.posterId = 1
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(120000);

      var prayer1 = await query1.insert();

      var query2 = new Query<Prayer>()
        ..values.prayer = "Test Prayer 2"
        ..values.posterId = 2
        ..values.createdDate = new DateTime.fromMillisecondsSinceEpoch(210000);

      var prayer2 = await query2.insert();

      var userPrayerQuery = new Query<UserPrayer>()
        ..values.prayer = prayer1
        ..values.user = user3;
      await userPrayerQuery.insert();

      var userPrayerQuery2 = new Query<UserPrayer>()
        ..values.prayer = prayer2
        ..values.user = user4;
      await userPrayerQuery2.insert();
    });

    tearDown(() async {
      await app.stop();
    });

    test("PUT /prayers by Id returns data", () async {
      var req = app.client.authenticatedRequest("admin/prayers/1", accessToken: tokens[0])
        ..json = {
          "prayer": "updated prayer",
          "updatedDate": "1970-01-01T00:02:02.000Z"
        };
      var result = await req.put();

      expect(result, hasResponse(200,
          {
            "id": 1,
            "prayer": "updated prayer",
            "createdDate": "1970-01-01T00:02:00.000Z",
            "updatedDate": "1970-01-01T00:02:02.000Z"
          }
      ));
    });

    test("PUT /prayers by Id fails with bad Id", () async {
      var req = app.client.authenticatedRequest("admin/prayers/9001", accessToken: tokens[0])
        ..json = {
          "prayer": "updated prayer",
          "updatedDate": "1970-01-01T00:02:02.000Z"
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("PUT /prayers by Id fails for non-admin with 401", () async {
      var req = app.client.authenticatedRequest("admin/prayers/1", accessToken: tokens[1])
        ..json = {
          "prayer": "updated prayer",
        };
      var result = await req.put();

      expect(result, hasStatus(401));
    });

    test("DELETE /prayers by Id for user with admin role", () async {
      var req = app.client.authenticatedRequest("admin/prayers/1", accessToken: tokens[0]);
      var result = await req.delete();

      expect(result, hasStatus(200));

      var req2 = app.client.clientAuthenticatedRequest("/prayers/1");
      var result2 = await req2.get();

      expect(result2, hasStatus(404));

      var req3 = app.client.authenticatedRequest("admin/prayers/2", accessToken: "Fake Token");
      var result3 = await req3.delete();

      expect(result3, hasStatus(401));
    });

    test("POST /prayers posts data", () async {
      var req = app.client.authenticatedRequest("admin/prayers", accessToken: tokens[0])
        ..json = {
          "prayer": "updated prayer",
          "posterId": 1,
          "updatedDate": null,
          "createdDate": "1970-01-01T00:02:00.000Z"
        };
      var result = await req.post();

      expect(result, hasResponse(200,
          {
            "id": 3,
            "prayer": "updated prayer",
            "createdDate": "1970-01-01T00:02:00.000Z",
            "updatedDate": null,
            "poster": {"id": 1, "firstName": "Bobby"}
          }
      ));

    });
  });
}