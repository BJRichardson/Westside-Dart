import '../westside_backend.dart';

class AnnouncementGroupController extends HTTPController {
  @httpGet
  Future<Response> getAnnouncementsForGroup(@HTTPPath("id") int groupId) async {
    var query = new Query<Announcement>()
      ..sortBy((e) => e.createdDate, QuerySortOrder.descending)
      ..where.groupId = whereEqualTo(groupId);

    var announcements = await query.fetchOne();
    if (announcements == null) {
      return new Response.ok([]);
    }

    return new Response.ok(announcements);
  }
}