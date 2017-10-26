import '../westside_backend.dart';

class GroupController extends HTTPController {
  @httpGet
  Future<Response> getGroups() async {
    var query = new Query<Group>()
      ..sortBy((e) => e.id, QuerySortOrder.ascending);

    var events = await query.fetch();
    if (events == null) {
      return new Response.notFound();
    }

    return new Response.ok(events);
  }

  @httpGet
  Future<Response> getGroup(@HTTPPath("id") int id) async {
    var query = new Query<Group>()
      ..where.id = whereEqualTo(id);

    var event = await query.fetchOne();
    if (event == null) {
      return new Response.notFound();
    }

    return new Response.ok(event);
  }
}