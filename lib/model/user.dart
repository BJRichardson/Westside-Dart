import '../westside_backend.dart';

class User extends ManagedObject<_User> implements _User, ManagedAuthResourceOwner {
  @managedTransientInputAttribute
  String password;

  bool containsRole(String role) {
    if (roles == null || roles.length == 0) {
      return false;
    }

    return roles.split(",").contains(role);
  }
}

class _User extends ManagedAuthenticatable {
  @ManagedColumnAttributes(unique: true)
  String email;

  @ManagedColumnAttributes(nullable: true)
  String firstName;

  @ManagedColumnAttributes(nullable: true)
  String lastName;

  @ManagedColumnAttributes(nullable: true)
  String phone;

  @ManagedColumnAttributes(nullable: true)
  String address;

  @ManagedColumnAttributes(nullable: true)
  String imageUrl;

  @ManagedColumnAttributes(nullable: true)
  String roles;

  ManagedSet<UserEvent> events;
  ManagedSet<UserGroup> groups;
  ManagedSet<UserAnnouncement> announcements;
  ManagedSet<UserPrayer> prayers;

/* This class inherits the following from ManagedAuthenticatable:

  @managedPrimaryKey
  int id;

  @ManagedColumnAttributes(unique: true, indexed: true)
  String username;

  @ManagedColumnAttributes(omitByDefault: true)
  String hashedPassword;

  @ManagedColumnAttributes(omitByDefault: true)
  String salt;

  ManagedSet<ManagedAuthCode> authorizationCodes;
  ManagedSet<ManagedToken> tokens;
 */
}
