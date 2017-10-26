import '../westside_backend.dart';

class UserPrayer extends ManagedObject<_UserPrayer> implements _UserPrayer {

}

class _UserPrayer {
  @managedPrimaryKey
  int id;

  @ManagedRelationship(#prayers, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  User user;

  @ManagedRelationship(#userPrayers, isRequired: true, onDelete: ManagedRelationshipDeleteRule.cascade)
  Prayer prayer;
}