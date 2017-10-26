import '../westside_backend.dart';

class ScheduleController extends HTTPController {
  @httpGet
  Future<Response> getSchedule() async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var query = new Query<UserEvent>()
      ..where.user = whereRelatedByValue(forUserId);

    var result = await query.fetch();

    return new Response.ok(result);
  }

  @httpPost
  Future<Response> addEventToSchedule(@HTTPPath("id") int id) async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var eventQuery = new Query<Event>()
      ..where.id = whereEqualTo(id);

    var event = await eventQuery.fetchOne();

    if (event == null) {
      return new Response.notFound();
    }

    var userEventQuery = new Query<UserEvent>()
      ..values.user = (new User()..id = forUserId)
      ..values.event = event;

    var result = await userEventQuery.insert();

    return new Response.ok(result);

  }

  @httpDelete
  Future<Response> deleteEventFromSchedule(@HTTPPath("id") int id) async {
    var forUserId = request.authorization.resourceOwnerIdentifier;

    var userEventQuery = new Query<UserEvent>()
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