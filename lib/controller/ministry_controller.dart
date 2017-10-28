import '../westside_backend.dart';

class MinistryController extends HTTPController {
  @httpGet
  Future<Response> getMinistries() async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var query = new Query<UserGroup>()
      ..where.user = whereRelatedByValue(forUserId);

    query.joinOne((s) => s.group)
        .returningProperties((s) => [s.id, s.name]);

    var result = await query.fetch();

    return new Response.ok(result);
  }

  @httpPost
  Future<Response> addGroupToMinistries(@HTTPPath("id") int id) async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var groupQuery = new Query<Group>()
      ..where.id = whereEqualTo(id);

    var group = await groupQuery.fetchOne();

    if (group == null) {
      return new Response.notFound();
    }

    var userGroupQuery = new Query<UserGroup>()
      ..values.user = (new User()..id = forUserId)
      ..values.group = group;

    var result = await userGroupQuery.insert();

    return new Response.ok(result);
  }

  @httpDelete
  Future<Response> deleteEventFromSchedule(@HTTPPath("id") int id) async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var userEventQuery = new Query<UserGroup>()
      ..where.id = whereEqualTo(id)
      ..where.user = whereRelatedByValue(forUserId);

    var result = await userEventQuery.delete();

    if (result == 0) {
      return new Response.notFound();
    } else {
      return new Response.ok(null);
    }
  }
}