import '../westside_backend.dart';

class AnnouncementController extends HTTPController {
  @httpGet
  Future<Response> getAnnouncments() async {
    var query = new Query<Announcement>()
      ..sortBy((e) => e.createdDate, QuerySortOrder.descending);

    query.joinMany((e) => e.userAnnouncements)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.name]);

    var announcements = await query.fetch();
    announcements.forEach((announcement) {
      announcement.poster = announcement.userAnnouncements.map((s) => s.user.asMap()).first;
    });

    return new Response.ok(announcements);
  }

  @httpGet
  Future<Response> getAnnouncement(@HTTPPath("id") int id) async {
    var query = new Query<Announcement>()
      ..where.id = whereEqualTo(id);

    query.joinMany((e) => e.userAnnouncements)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.name]);

    var announcement = await query.fetchOne();
    if (announcement == null) {
      return new Response.notFound();
    }

    announcement.poster = announcement.userAnnouncements.map((s) => s.user.asMap()).first;
    return new Response.ok(announcement);
  }
}