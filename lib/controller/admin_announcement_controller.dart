import '../westside_backend.dart';

class AdminAnnouncementController extends HTTPController {

  @httpPost
  Future<Response> addAnnouncement() async {
    var userQuery = new Query<User>()
      ..where.id = request.authorization.resourceOwnerIdentifier;

    var user = await userQuery.fetchOne();
    if (!isAdminUser(user)) {
      return new Response.unauthorized();
    }

    var announcement = new Announcement()
      ..readMap(request.body.asMap());

    var announcentQuery = new Query<Announcement>()
      ..values = announcement;

    var posterId = announcement.posterId;

    announcement = await announcentQuery.insert();

    if (posterId != null) {
      var userQuery2 = new Query<User>()
        ..where.id = user.id
        ..returningProperties((s) => [s.id, s.firstName]);

      var user2 = await userQuery2.fetchOne();

      var userAnnouncementQuery = new Query<UserAnnouncement>()
        ..values.user = user
        ..values.announcement = announcement;

      await userAnnouncementQuery.insert();

      announcement.poster = user2.asMap();
    } else {
      return new Response.notFound();
    }

    return new Response.ok(announcement);
  }

  @httpPut
  Future<Response> updateAnnouncement(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var announcement = new Announcement()
      ..readMap(request.body.asMap());

    var query = new Query<Announcement>()
      ..where.id = whereEqualTo(id)
      ..values = announcement;

    announcement = await query.updateOne();

    if (announcement == null) {
      return new Response.notFound();
    }

    return new Response.ok(announcement);
  }

  @httpDelete
  Future<Response> deleteAnnouncement(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(
        request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var query = new Query<Announcement>()
      ..where.id = id;

    var result = await query.delete();

    if (result == 0) {
      return new Response.notFound();
    } else {
      return new Response.ok(null);
    }
  }

  bool isAdminUser(User user) {
    if (user == null) {
      return false;
    }

    return user.containsRole("admin");
  }

  Future<bool> hasAuthorization(int userId, int announcmentId) async {
    var announcementQuery = new Query<Announcement>()
      ..where.id = announcmentId;

    var announcement = await announcementQuery.fetchOne();
    if (announcement == null) {
      return false;
    }

    var userAnnouncementQuery = new Query<UserAnnouncement>()
      ..where.user.id = userId
      ..where.announcement.id = announcement.id;

    var userAnnouncement = await userAnnouncementQuery.fetchOne();
    return userAnnouncement != null;
  }
}