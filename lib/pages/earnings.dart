import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../model/earningmodel.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/responsive_helper.dart';
import '../widget/monthyearpicker.dart';
import 'wallet.dart';

class Earnings extends StatefulWidget {
  final bool? appBarView;

  const Earnings({super.key, this.appBarView});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  bool isLoad = false;
  Result? earnings;
  int selectedIndex = 0;
  final List<String> labels = ['Overall', 'Month', 'Year'];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getStatistics();
  }

  Future<void> getStatistics() async {
    setState(() {
      isLoad = true;
    });

    String type = selectedIndex == 1
        ? 'month'
        : selectedIndex == 2
            ? 'year'
            : 'overall';

    String formattedDate;
    if (selectedIndex == 0) {
      formattedDate = '2025-01-01';
    } else if (selectedIndex == 1) {
      formattedDate = DateFormat('yyyy-MM-01').format(selectedDate);
    } else {
      formattedDate = DateFormat('${selectedDate.year}-01-01')
          .format(DateTime(selectedDate.year, 1, 1));
    }

    try {
      EarningModel data = await ApiService().getEarnings(formattedDate, type);
      if (data.status == 200 && data.result != null) {
        setState(() {
          earnings = data.result!;
        });
      }
    } catch (e) {
      debugPrint('Error fetching earnings: $e');
    }

    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? Utils.webAppbarWithSidePanel(
                context: context, contentType: Constant.musicSearch)
            : null,
        body: RefreshIndicator(
          onRefresh: () => getStatistics(),
          child: ResponsiveHelper.checkIsWeb(context)
              ? Utils.sidePanelWithBody(
                  myWidget: buildBody(),
                )
              : Utils().pageBg(
                  context,
                  child: buildBody(),
                ),
        ));
  }

  Widget buildBody() {
    return SafeArea(
      child: isLoad
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 50),
                        _buildTabSelector(),
                        const SizedBox(height: 20),
                        if (selectedIndex == 1)
                          MonthYearSelector(
                            showMonths: true,
                            initialDate: selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                              getStatistics();
                            },
                          )
                        else if (selectedIndex == 2)
                          MonthYearSelector(
                            showMonths: false,
                            initialDate: selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                              getStatistics();
                            },
                          ),
                        const SizedBox(height: 20),
                        if (earnings != null) ...[
                          _buildEarningCard(
                            icon: Icons.currency_exchange_rounded,
                            title: "Withdraw Coins",
                            value: earnings!.withdrawalCoin ?? '',
                          ),
                          const SizedBox(height: 12),
                          _buildEarningCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: "Withdraw Amount",
                            value: earnings!.withdrawalAmount ?? '',
                          ),
                          const SizedBox(height: 12),
                          _buildEarningCard(
                            icon: Icons.monetization_on_rounded,
                            title: "Earning Coin",
                            value: earnings!.earningCoin.toString(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 180,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.black),
                              label: const Text(
                                "Wallet",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Wallet(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                    if (earnings != null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              top: 75, left: 13, right: 13),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2230),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.pinkAccent.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Coins",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on_rounded,
                                      color: Colors.amber, size: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    earnings!.earningCoin.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF96E1FF),
            Color(0xFFFFEE99),
            Color(0xFFFF88A1),
            Color(0xFFFF7DD3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Row(
        children: [
          if (widget.appBarView ?? false)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          Text(
            "Earnings",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              getStatistics();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEarningCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A38),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: buttonDisable,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amberAccent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
