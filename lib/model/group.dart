import '../westside_backend.dart';

class Group extends ManagedObject<_Group> implements _Group {

  @managedTransientInputAttribute
  List<int> userIds;

  @managedTransientOutputAttribute
  List<Map> users;

  Map<String, dynamic> asMap() {
    var map = super.asMap();
    map.remove("userGroups");
    return map;
  }
}

class _Group {
  @managedPrimaryKey
  int id;

  String name;
  String description;

  @ManagedColumnAttributes(nullable: true)
  String chairperson;

  @ManagedColumnAttributes(nullable: true)
  String email;

  @ManagedColumnAttributes(nullable: true)
  String phone;

  @ManagedColumnAttributes(nullable: true)
  String imageUrl;

  ManagedSet<UserGroup> userGroups;

  ManagedSet<GroupEvent> groupEvents;
}