import '../westside_backend.dart';

class UserController extends QueryController<User> {
  UserController(this.authServer);

  AuthServer authServer;

  @httpGet
  Future<Response> getUsers() async {
    var query = new Query<User>()
      ..sortBy((e) => e.lastName, QuerySortOrder.ascending);

    var events = await query.fetch();
    return new Response.ok(events);
  }

  @httpGet
  Future<Response> getUser(@HTTPPath("id") int id) async {
    var u = await query.fetchOne();
    if (u == null) {
      return new Response.notFound();
    }

    if (request.authorization.resourceOwnerIdentifier != id) {
      // Filter out stuff for non-owner of user
    }

    return new Response.ok(u);
  }

  @httpPut
  Future<Response> updateUser(@HTTPPath("id") int id) async {
    var userQuery = new Query<User>()
      ..where.id = request.authorization.resourceOwnerIdentifier;

    var user = await userQuery.fetchOne();
    if (user == null) {
      return new Response.unauthorized();
    }

    bool isAdmin = user.containsRole("admin");

    if (request.authorization.resourceOwnerIdentifier != id && !isAdmin) {
      return new Response.unauthorized();
    }

//    if (query.values.asMap().keys.contains("roles") && !isAdmin) {
//      return new Response.unauthorized();
//    }

    var u = await query.updateOne();
    if (u == null) {
      return new Response.notFound();
    }

    return new Response.ok(u);
  }

  @httpDelete
  Future<Response> deleteUser(@HTTPPath("id") int id) async {
    if (request.authorization.resourceOwnerIdentifier != id) {
      return new Response.unauthorized();
    }

    await authServer.revokeAuthenticatableAccessForIdentifier(id);
    var q = new Query<User>()
      ..where.id = id;
    await q.delete();

    return new Response.ok(null);
  }
}
