import '../westside_backend.dart';

class AdminGroupController extends HTTPController {

  @httpPost
  Future<Response> addGroup() async {
    var userQuery = new Query<User>()
      ..where.id = request.authorization.resourceOwnerIdentifier;

    var user = await userQuery.fetchOne();
    if (!isAdminUser(user)) {
      return new Response.unauthorized();
    }

    var group = new Group()
      ..readMap(request.body.asMap());

    var groupQuery = new Query<Group>()
      ..values = group;

    var userIds = group.userIds;

    group = await groupQuery.insert();

    if (userIds != null) {
      var userQuery1 = new Query<User>()
        ..where.id = whereIn(userIds)
        ..returningProperties((s) => [s.id, s.name]);

      var users = await userQuery1.fetch();

      if (users.length != userIds.length) {
        return new Response.notFound();
      }

      await Future.forEach(users, (s) async {
        var groupEventQuery = new Query<UserGroup>()
          ..values.user = user
          ..values.group = group;

        await groupEventQuery.insert();
      });

      group.users = users.map((s) => s.asMap()).toList();
    } else {
      group.users = [];
    }

    return new Response.ok(group);
  }

  @httpPut
  Future<Response> updateGroup(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(
        request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var group = new Group()
      ..readMap(request.body.asMap());

    var query = new Query<Group>()
      ..where.id = whereEqualTo(id)
      ..values = group;

    group = await query.updateOne();

    if (group == null) {
      return new Response.notFound();
    }

    return new Response.ok(group);
  }

  @httpDelete
  Future<Response> deleteGroup(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(
        request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var query = new Query<Group>()
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

  Future<bool> hasAuthorization(int userId, int groupId) async {
    //TODO Finish this when Board/Auxiliaries completed
    return true;
//    var userQuery = new Query<User>()
//      ..where.id = userId;
//
//    var user = await userQuery.fetchOne();
//    if (!isAdminUser(user)) {
//      var speakerGroupQuery = new Query<SpeakerGroup>()
//        ..where.speaker.id = user.id
//        ..where.group.id = groupId;
//
//      var speakerGroup = await speakerGroupQuery.fetchOne();
//      return speakerGroup != null;
//    } else {
//      return true;
//    }
  }
}