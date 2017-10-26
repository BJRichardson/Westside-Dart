import '../westside_backend.dart';

class UserGroup extends ManagedObject<_UserGroup> implements _UserGroup {

}

class _UserGroup {
  @managedPrimaryKey
  int id;

  @ManagedRelationship(#groups, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  User user;

  @ManagedRelationship(#userGroups, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Group group;
}