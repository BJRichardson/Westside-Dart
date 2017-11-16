import '../westside_backend.dart';

class EventController extends HTTPController {
  @httpGet
  Future<Response> getEvents() async {
    var query = new Query<Event>()
      ..where.startTime = whereGreaterThan(new DateTime.now())
      ..sortBy((e) => e.startTime, QuerySortOrder.ascending);

    attachUsersAndGroups(query);

    var events = await query.fetch();

    events.forEach((event) {
      event.groups = event.groupEvents.map((s) => s.group.asMap()).toList();
      event.users = event.userEvents.map((s) => s.user.asMap()).toList();
    });

    return new Response.ok(events);
  }

  @httpGet
  Future<Response> getEvent(@HTTPPath("id") int id) async {
    var query = new Query<Event>()
      ..where.id = whereEqualTo(id);

    attachUsersAndGroups(query);

    var event = await query.fetchOne();
    if (event == null) {
      return new Response.notFound();
    }

    event.groups = event.groupEvents.map((s) => s.group.asMap())?.toList();
    event.users = event.userEvents.map((s) => s.user.asMap()).toList();

    return new Response.ok(event);
  }

  void attachUsersAndGroups(Query<Event> query) {
    query.joinMany((e) => e.groupEvents)
        .joinOne((s) => s.group)
        .returningProperties((s) => [s.id, s.name]);

    query.joinMany((e) => e.userEvents)
        .joinOne((s) => s.user)
        .returningProperties((s) => [s.id, s.firstName, s.lastName]);
  }
}