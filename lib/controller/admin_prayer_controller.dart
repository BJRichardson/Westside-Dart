import '../westside_backend.dart';

class AdminPrayerController extends HTTPController {

  @httpPost
  Future<Response> addPrayer() async {
    var userQuery = new Query<User>()
      ..where.id = request.authorization.resourceOwnerIdentifier;

    var user = await userQuery.fetchOne();

    var prayer = new Prayer()
      ..readMap(request.body.asMap());

    var prayerQuery = new Query<Prayer>()
      ..values = prayer;

    var posterId = prayer.posterId;

    prayer = await prayerQuery.insert();

    if (posterId != null) {
      var userQuery2 = new Query<User>()
        ..where.id = user.id
        ..returningProperties((s) => [s.id, s.firstName]);

      var user2 = await userQuery2.fetchOne();

      var userPrayerQuery = new Query<UserPrayer>()
        ..values.user = user
        ..values.prayer = prayer;

      await userPrayerQuery.insert();

      prayer.poster = user2.asMap();
    } else {
      return new Response.notFound();
    }

    return new Response.ok(prayer);
  }

  @httpPut
  Future<Response> updatePrayer(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var prayer = new Prayer()
      ..readMap(request.body.asMap());

    var query = new Query<Prayer>()
      ..where.id = whereEqualTo(id)
      ..values = prayer;

    prayer = await query.updateOne();

    if (prayer == null) {
      return new Response.notFound();
    }

    return new Response.ok(prayer);
  }

  @httpDelete
  Future<Response> deletePrayer(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(
        request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var query = new Query<Prayer>()
      ..where.id = id;

    var result = await query.delete();

    if (result == 0) {
      return new Response.notFound();
    } else {
      return new Response.ok(null);
    }
  }

  Future<bool> hasAuthorization(int userId, int prayerId) async {
    var announcementQuery = new Query<Prayer>()
      ..where.id = prayerId;

    var prayer = await announcementQuery.fetchOne();
    if (prayer == null) {
      return false;
    }

    var userPrayerQuery = new Query<UserPrayer>()
      ..where.user.id = userId
      ..where.prayer.id = prayer.id;

    var userPrayer = await userPrayerQuery.fetchOne();
    return userPrayer != null;
  }
}