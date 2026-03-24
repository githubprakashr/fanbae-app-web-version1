import 'package:fanbae/model/adspackagemodel.dart';
import 'package:fanbae/model/packagemodel.dart';
import 'package:fanbae/model/paymentoptionmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/utils/utils.dart';

class SubscriptionProvider extends ChangeNotifier {
  PackageModel packageModel = PackageModel();
  AdsPackageModel adsPackageModel = AdsPackageModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel rentTransectionModel = SuccessModel();
  SuccessModel adsTransectionModel = SuccessModel();
  PaymentOptionModel paymentOptionModel = PaymentOptionModel();
  bool loading = false, payLoading = false;
  bool isSelectpackage = false;
  int? selectPackagePosition = 0;
  String selectPackagePrice = "";
  String? currentPayment = "", finalAmount = "";
  bool adspackageLoading = false;

/* Package Api Start */
  getPackage() async {
    loading = true;
    packageModel = await ApiService().package();
    loading = false;
    notifyListeners();
  }

  getAdsPackage() async {
    adspackageLoading = true;
    adsPackageModel = await ApiService().adsPackage();
    adspackageLoading = false;
    notifyListeners();
  }
/* Package Api End */

/* Transections APi Start */
  Future<void> addTransaction(
      {int? packageid,
      int? price,
      String? description,
      String? paymentType,
      String? transactionId,
      int? autoRenewal,
      String? userId,
      List<int>? channelId,
      List<int>? categoryId}) async {
    payLoading = true;
    successModel = await ApiService().addTransaction(
      packageId: packageid,
      price: price,
      description: description,
      paymentType: paymentType,
      transactionId: transactionId,
      userId: userId,
      channelId: channelId,
      categoryId: categoryId,
      autoRenewal: autoRenewal,
    );
    payLoading = false;
    notifyListeners();
  }

  Future<void> getAdsTransaction(
      packageId, price, coin, transectionId, description) async {
    payLoading = true;
    adsTransectionModel = await ApiService()
        .adsTransection(packageId, price, coin, transectionId, description);
    payLoading = false;
    notifyListeners();
  }
/* Transections APi Start */

/* Payment Option Related Api Start */
  Future<void> getPaymentOption() async {
    payLoading = true;
    paymentOptionModel = await ApiService().getPaymentOption();
    payLoading = false;
    notifyListeners();
  }

  setFinalAmount(String? amount) {
    finalAmount = amount;
    printLog("setFinalAmount finalAmount :==> $finalAmount");
    notifyListeners();
  }

  setCurrentPayment(String? payment) {
    currentPayment = payment;
    notifyListeners();
  }
/* Payment Option Related Api End */

  clearProvider() async {
    packageModel = PackageModel();
    successModel = SuccessModel();
    adsPackageModel = AdsPackageModel();
    rentTransectionModel = SuccessModel();
    paymentOptionModel = PaymentOptionModel();
    loading = false;
    payLoading = false;
    isSelectpackage = false;
    selectPackagePosition = 0;
    currentPayment = "";
    finalAmount = "";
    selectPackagePrice = "";
  }
}
