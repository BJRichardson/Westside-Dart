import '../westside_backend.dart';

class Event extends ManagedObject<_Event> implements _Event {

    @managedTransientInputAttribute
    List<int> groupIds;

    @managedTransientOutputAttribute
    List<Map> groups;

    @managedTransientOutputAttribute
    List<Map> users;

    Map<String, dynamic> asMap() {
      var map = super.asMap();
      map.remove("groupEvents");
      map.remove("userEvents");
      return map;
    }
}

class _Event {
  @managedPrimaryKey
  int id;
  int creatorId;

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
