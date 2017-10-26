import '../westside_backend.dart';

class HealthController extends HTTPController {
  @httpGet
  Future<Response> checkHealth() async {
    return new Response.ok("Westside CME Server is running.");
  }
}
