import '../westside_backend.dart';

class PrayerController extends HTTPController {
  @httpGet
  Future<Response> getPrayers() async {
    var query = new Query<Prayer>()
      ..sortBy((e) => e.createdDate, QuerySortOrder.descending);

    query.joinMany((e) => e.userPrayers)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.name]);

    var prayers = await query.fetch();
    prayers.forEach((prayer) {
      prayer.poster = prayer.userPrayers.map((s) => s.user.asMap()).first;
    });

    return new Response.ok(prayers);
  }

  @httpGet
  Future<Response> getPrayer(@HTTPPath("id") int id) async {
    var query = new Query<Prayer>()
      ..where.id = whereEqualTo(id);

    query.joinMany((e) => e.userPrayers)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.name]);

    var prayer = await query.fetchOne();
    if (prayer == null) {
      return new Response.notFound();
    }

    prayer.poster = prayer.userPrayers.map((s) => s.user.asMap()).first;
    return new Response.ok(prayer);
  }
}