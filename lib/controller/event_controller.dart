import '../westside_backend.dart';

class EventController extends HTTPController {
  @httpGet
  Future<Response> getEvents() async {
    var query = new Query<Event>()
      ..where.startTime = whereGreaterThan(new DateTime.now())
      ..sortBy((e) => e.startTime, QuerySortOrder.ascending);

    query.joinMany((e) => e.groupEvents)
        .joinOne((s) => s.group)
        .returningProperties((s) => [s.id, s.name]);

    var events = await query.fetch();

    events.forEach((event) {
      event.groups = event.groupEvents.map((s) => s.group.asMap()).toList();
    });

    return new Response.ok(events);
  }

  @httpGet
  Future<Response> getEvent(@HTTPPath("id") int id) async {
    var query = new Query<Event>()
      ..where.id = whereEqualTo(id);

    query.joinMany((e) => e.groupEvents)
        .joinOne((s) => s.group)
        .returningProperties((s) => [s.id, s.name]);

    var event = await query.fetchOne();
    if (event == null) {
      return new Response.notFound();
    }

    event.groups = event.groupEvents.map((s) => s.group.asMap())?.toList();

    return new Response.ok(event);
  }
}