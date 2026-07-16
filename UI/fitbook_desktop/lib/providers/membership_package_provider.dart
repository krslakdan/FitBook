import '../models/responses/membership_package_response.dart';
import 'base_crud_provider.dart';

/// Talks to `MembershipPackagesController` (`api/membershippackages`).
class MembershipPackageProvider extends BaseCrudProvider<MembershipPackageResponse> {
  MembershipPackageProvider() : super('MembershipPackages');

  @override
  MembershipPackageResponse fromJson(Map<String, dynamic> json) =>
      MembershipPackageResponse.fromJson(json);
}
