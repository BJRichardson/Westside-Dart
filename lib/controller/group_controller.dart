import '../westside_backend.dart';

class GroupController extends HTTPController {
  @httpGet
  Future<Response> getGroups() async {
    var query = new Query<Group>()
      ..sortBy((e) => e.name, QuerySortOrder.ascending);

    attachUserGroups(query);

    var groups = await query.fetch();

    groups.forEach((group) {
      group.users = group.userGroups.map((s) => s.user.asMap()).toList();
    });

    if (groups == null) {
      return new Response.notFound();
    }

    return new Response.ok(groups);
  }

  @httpGet
  Future<Response> getGroup(@HTTPPath("id") int id) async {
    var query = new Query<Group>()
      ..where.id = whereEqualTo(id);

    attachUserGroups(query);

    var group = await query.fetchOne();
    if (group == null) {
      return new Response.notFound();
    }

    group.users = group.userGroups.map((s) => s.user.asMap()).toList();

    return new Response.ok(group);
  }

  void attachUserGroups(Query<Group> query) {
    query.joinMany((e) => e.userGroups)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.firstName, s.lastName]);
  }
}