import 'package:flutter/cupertino.dart';
import '../model/successmodel.dart';
import '../webservice/apiservice.dart';

class MembershipPlanProvider extends ChangeNotifier {
  SuccessModel membershipPlanModel = SuccessModel();
  bool loading = false;

  getMembershipPlan(
      String? id,
      String creatorid,
      String name,
      int price,
      int offerPrice,
      String planValue,
      String planType,
      Map<String, dynamic> planFeatures,
      ) async {
    loading = true;
    notifyListeners();

    membershipPlanModel = await ApiService().updateMembershipPlan(
      id,
      creatorid,
      name,
      price,
      offerPrice,
      planValue,
      planType,
      planFeatures,
    );

    loading = false;
    notifyListeners();
  }
}
