import '../westside_backend.dart';

class Event extends ManagedObject<_Event> implements _Event {

    @managedTransientInputAttribute
    List<int> groupIds;

    @managedTransientOutputAttribute
    List<Map> groups;

    Map<String, dynamic> asMap() {
      var map = super.asMap();
      map.remove("groupEvents");
      return map;
    }
}

class _Event {
  @managedPrimaryKey
  int id;

  String title;
  DateTime startTime;
  String description;

  @ManagedColumnAttributes(nullable: true)
  DateTime endTime;

  @ManagedColumnAttributes(nullable: true)
  String moreInformation;

  @ManagedColumnAttributes(nullable: true)
  String imageUrl;

  ManagedSet<UserEvent> userEvents;

  ManagedSet<GroupEvent> groupEvents;
}
