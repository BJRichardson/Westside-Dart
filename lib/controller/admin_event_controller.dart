import '../westside_backend.dart';

class AdminEventController extends HTTPController {

  @httpGet
  Future<Response> getEvents() async {
    var query = new Query<Event>()
      ..where.creatorId = request.authorization.resourceOwnerIdentifier
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

  @httpPost
  Future<Response> addEvent() async {
    var userQuery = new Query<User>()
      ..where.id = request.authorization.resourceOwnerIdentifier;

    var user = await userQuery.fetchOne();
    if (!isAdminUser(user)) {
      return new Response.unauthorized();
    }

    var event = new Event()
      ..readMap(request.body.asMap());

    var eventQuery = new Query<Event>()
      ..values = event;

    var groupIds = event.groupIds;

    event = await eventQuery.insert();

    if (groupIds != null) {
      var groupQuery = new Query<Group>()
        ..where.id = whereIn(groupIds)
        ..returningProperties((s) => [s.id, s.name]);

      var groups = await groupQuery.fetch();

      if (groups.length != groupIds.length) {
        return new Response.notFound();
      }

      await Future.forEach(groups, (s) async {
        var groupEventQuery = new Query<GroupEvent>()
          ..values.event = event
          ..values.group = s;

        await groupEventQuery.insert();
      });

      event.groups = groups.map((s) => s.asMap()).toList();
    } else {
      event.groups = [];
    }

    return new Response.ok(event);
  }

  @httpPut
  Future<Response> updateEvent(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var event = new Event()
      ..readMap(request.body.asMap());

    var query = new Query<Event>()
      ..where.id = whereEqualTo(id)
      ..values = event;

    event = await query.updateOne();

    if (event == null) {
      return new Response.notFound();
    }

    return new Response.ok(event);
  }

  @httpDelete
  Future<Response> deleteEvent(@HTTPPath("id") int id) async {
    if (!(await hasAuthorization(
        request.authorization.resourceOwnerIdentifier, id))) {
      return new Response.unauthorized();
    };

    var query = new Query<Event>()
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

  Future<bool> hasAuthorization(int groupId, int eventId) async {
    var groupQuery = new Query<Group>()
      ..where.id = groupId;

    var group = await groupQuery.fetchOne();
    var groupEventQuery = new Query<GroupEvent>()
      ..where.group.id = group.id
      ..where.event.id = eventId;

    var groupEvent = await groupEventQuery.fetchOne();
    return groupEvent != null;
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