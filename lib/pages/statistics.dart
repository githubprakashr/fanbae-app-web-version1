import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';

import '../model/overallstatisticsmodel.dart';
import '../utils/color.dart';
import '../utils/constant.dart';
import '../utils/responsive_helper.dart';
import '../widget/mytext.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool isLoad = false;
  Result? statistics;
  bool isMonthly = true;

  @override
  void initState() {
    getStatistics();
    super.initState();
  }

  getStatistics() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    try {
      OverallStatisticsModel data = await ApiService()
          .getOverallStatistics()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timeout');
      });
      if (!mounted) return;
      if (data.status == 200 && data.result != null) {
        setState(() {
          statistics = data.result;
          isLoad = false;
        });
      } else {
        debugPrint('Statistics API Error: Status ${data.status}');
        setState(() {
          isLoad = false;
        });
      }
    } catch (e) {
      debugPrint('Statistics Error: $e');
      if (!mounted) return;
      setState(() {
        isLoad = false;
      });
    }
  }

  Widget buildBarChart(MonthlyChartViews views, YearChartViews yearViews) {
    final monthShortNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final monthValues = [
      views.january,
      views.february,
      views.march,
      views.april,
      views.may,
      views.june,
      views.july,
      views.august,
      views.september,
      views.october,
      views.november,
      views.december,
    ];

    final yearlyValues = [
      yearViews.ten,
      yearViews.nine,
      yearViews.eight,
      yearViews.seven,
      yearViews.six,
      yearViews.five,
      yearViews.four,
      yearViews.three,
      yearViews.two,
      yearViews.one,
    ];

    final currentYear = DateTime.now().year;
    final yearLabels = List.generate(
      10,
      (i) => (currentYear - 9 + i).toString(),
    );

    final now = DateTime.now();
    final currentMonthIndex = now.month;
    final startIndex = (currentMonthIndex) % 12;
    late List<Map<String, dynamic>> chartData;

    if (isMonthly) {
      chartData = List.generate(12, (i) {
        final index = (startIndex + i) % 12;
        return {
          'label': monthShortNames[index],
          'value': monthValues[index],
        };
      });
    } else {
      chartData = List.generate(10, (i) {
        return {
          'label': yearLabels[i],
          'value': yearlyValues[i],
        };
      });
    }

    final maxValue =
        chartData.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);

    final maxY = maxValue + (maxValue * 0.2); // Add 20% padding

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: !ResponsiveHelper.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.02
              : MediaQuery.of(context).size.width * 0.04),
      padding: const EdgeInsets.only(top: 12, left: 12, right: 0),
      decoration: BoxDecoration(
          color: Constant.darkMode == "true"
              ? buttonDisable
              : const Color(0xfff3f2f2),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: MyText(
                        text: "Content Performance Analytics",
                        color: white,
                        maxline: 2,
                        fontsizeNormal: 15,
                        fontwaight: FontWeight.bold,
                        multilanguage: false,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMonthly = !isMonthly;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 6.3),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      children: [
                        MyText(
                          text: isMonthly ? "monthly" : "yearly",
                          color: white,
                          fontsizeNormal: 12,
                          fontwaight: FontWeight.w600,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.swap_horiz,
                          color: white,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: button1color.withOpacity(0.15),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: !ResponsiveHelper.isMobile(context) ? 300 : 250,
            padding: const EdgeInsets.only(left: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: !ResponsiveHelper.isMobile(context)
                    ? isMonthly
                        ? chartData.length * 120.0
                        : chartData.length * 135.0
                    : chartData.length * 60.0,
                margin: const EdgeInsets.only(right: 11),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY.toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: white.withOpacity(0.08),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY == 0
                              ? 1
                              : !ResponsiveHelper.isMobile(context)
                                  ? (maxY / 4).ceilToDouble()
                                  : (maxY / 3).ceilToDouble(),
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 45,
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < chartData.length) {
                              return Container(
                                margin: const EdgeInsets.only(
                                    top: 15, right: 28, left: 5),
                                child: Text(
                                  chartData[index]['label']!,
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 12.5,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: const Color(0xff0FEDF7),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xff0FEDF7).withOpacity(0.8),
                                Constant.darkMode == "true"
                                    ? const Color(0xff0F0F0F).withOpacity(0.7)
                                    : const Color(0xffFFFFFF).withOpacity(0.85)
                              ]),
                        ),
                        spots: List.generate(
                          chartData.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            (chartData[i]['value'] as int).toDouble(),
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideVertically: true,
                        fitInsideHorizontally: true,
                        tooltipBgColor: Colors.black.withOpacity(
                            Constant.darkMode == "true" ? 0.7 : 0.15),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()} views',
                              TextStyle(
                                color: white,
                                fontSize: 11,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget withdrawTable(List<WithdrawalHistory> dataList) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: EdgeInsets.symmetric(
          horizontal: !ResponsiveHelper.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.02
              : MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Constant.darkMode == "true"
            ? buttonDisable
            : const Color(0xfff3f2f2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 15),
              child: MyText(
                text: "Withdrawal History",
                color: white,
                multilanguage: false,
                fontsizeNormal: 15.7,
                fontwaight: FontWeight.bold,
              ),
            ),
            Table(
              columnWidths: {
                0: FixedColumnWidth(!ResponsiveHelper.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.16
                    : MediaQuery.of(context).size.width * 0.33),
                1: FixedColumnWidth(!ResponsiveHelper.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.22
                    : MediaQuery.of(context).size.width * 0.38),
                2: FixedColumnWidth(!ResponsiveHelper.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.13
                    : MediaQuery.of(context).size.width * 0.3),
                3: FixedColumnWidth(!ResponsiveHelper.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.22
                    : MediaQuery.of(context).size.width * 0.38),
                4: FixedColumnWidth(!ResponsiveHelper.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.18
                    : MediaQuery.of(context).size.width * 0.35),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: Constant.darkMode == "true"
                        ? Colors.white24
                        : Colors.black26,
                    width: 0.5),
              ),
              children: [
                TableRow(
                  children: [
                    tableHeader("Withdraw ID"),
                    tableHeader("Date"),
                    tableHeader("Amount"),
                    tableHeader("Method"),
                    tableHeader("Status"),
                  ],
                ),
                for (var item in dataList)
                  TableRow(
                    children: [
                      tableCell(item.id.toString()),
                      tableCell(item.date),
                      tableCell(item.amount.toString()),
                      tableCell(item.paymentType),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.status == "Completed"
                                ? Constant.darkMode == "true"
                                    ? const Color(0xff69e34b)
                                    : const Color(0xff56a840)
                                : Constant.darkMode == "true"
                                    ? const Color(0xffF8D248)
                                    : const Color(0xffeda24c),
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: MyText(
        text: text,
        color: Constant.darkMode == "true" ? Colors.white70 : Colors.black54,
        fontwaight: FontWeight.bold,
        multilanguage: false,
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: MyText(
        text: text,
        color: white,
        fontsizeNormal: 14,
        multilanguage: false,
      ),
    );
  }

  buildBody() {
    return isLoad
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : statistics == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Colors.grey.shade400,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      MyText(
                        text: "Unable to Load Dashboard",
                        color: Colors.white,
                        multilanguage: false,
                        fontsizeNormal: 18,
                        fontwaight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      MyText(
                        text: "Check your internet connection and try again",
                        color: Colors.grey,
                        multilanguage: false,
                        fontsizeNormal: 14,
                        textalign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          getStatistics();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: !ResponsiveHelper.isMobile(context)
                                  ? MediaQuery.of(context).size.width * 0.02
                                  : MediaQuery.of(context).size.width * 0.04),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.5, vertical: 6.5),
                          decoration: BoxDecoration(
                              color: Constant.darkMode == "true"
                                  ? buttonDisable
                                  : const Color(0xfff3f2f2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Constant.darkMode == "true"
                                    ? white
                                    : const Color(0xff056AEB),
                                size: 18,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              MyText(
                                text: statistics!.totalView,
                                color: white,
                                multilanguage: false,
                              ),
                              const SizedBox(
                                width: 23,
                              ),
                              MyImage(
                                imagePath: "shorts_web.svg",
                                color: Constant.darkMode == "true"
                                    ? white
                                    : const Color(0xffFF3803),
                                width: 17.5,
                                height: 17.5,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              MyText(
                                text: statistics!.totalContentCount,
                                color: white,
                                multilanguage: false,
                              ),
                              const SizedBox(
                                width: 23,
                              ),
                              Icon(
                                Icons.thumb_up,
                                color: Constant.darkMode == "true"
                                    ? white
                                    : const Color(0xffF001B7),
                                size: 17.5,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              MyText(
                                text: statistics!.totalLike,
                                color: white,
                                multilanguage: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: !ResponsiveHelper.isMobile(context)
                                ? MediaQuery.of(context).size.width * 0.02
                                : MediaQuery.of(context).size.width * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 13, left: 15, right: 8),
                                decoration: BoxDecoration(
                                  color: Constant.darkMode == "true"
                                      ? buttonDisable
                                      : const Color(0xffFFDDC9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4.5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: const Color(0xff6EFF4A)
                                            .withOpacity(0.15),
                                      ),
                                      child: MyImage(
                                          width: 18,
                                          height: 18,
                                          color: Constant.darkMode == "true"
                                              ? const Color(0xff6EFF4A)
                                              : const Color(0xff41b125),
                                          imagePath: 'earning_web.svg'),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    MyText(
                                      text: "Earning Summary",
                                      color: Constant.darkMode != "true"
                                          ? pureBlack
                                          : const Color(0xffC4C4C4),
                                      fontsizeNormal: 11.5,
                                      multilanguage: false,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    MyText(
                                      text: statistics!.earningAmount,
                                      color: white,
                                      fontsizeNormal: 14,
                                      fontwaight: FontWeight.bold,
                                      multilanguage: false,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    MyText(
                                      text: "Total",
                                      color: Constant.darkMode != "true"
                                          ? pureBlack
                                          : const Color(0xff8B8B8B),
                                      fontsizeNormal: 10.5,
                                      multilanguage: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 13, left: 15, right: 8),
                                decoration: BoxDecoration(
                                  color: Constant.darkMode == "true"
                                      ? buttonDisable
                                      : const Color(0xffDBFFE6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4.5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: const Color(0xffFF4A4A)
                                            .withOpacity(0.15),
                                      ),
                                      child: MyImage(
                                          width: 18,
                                          height: 18,
                                          color: const Color(0xffFF5D5D),
                                          imagePath: 'subscription_web.svg'),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    MyText(
                                      text: "Subscription Count",
                                      color: Constant.darkMode != "true"
                                          ? pureBlack
                                          : const Color(0xffC4C4C4),
                                      fontsizeNormal: 11.5,
                                      multilanguage: false,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    MyText(
                                      text: statistics!.overallSubscribers
                                          .toString(),
                                      color: white,
                                      fontsizeNormal: 14,
                                      fontwaight: FontWeight.bold,
                                      multilanguage: false,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    MyText(
                                      text: "Total Subscribers",
                                      color: Constant.darkMode != "true"
                                          ? pureBlack
                                          : const Color(0xff8B8B8B),
                                      fontsizeNormal: 10.5,
                                      multilanguage: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!ResponsiveHelper.isMobile(context)) ...[
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 13, left: 15, right: 8),
                                  decoration: BoxDecoration(
                                    color: Constant.darkMode == "true"
                                        ? buttonDisable
                                        : const Color(0xffFCE5FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: const Color(0xffF8D248)
                                              .withOpacity(
                                                  Constant.darkMode == "true"
                                                      ? 0.15
                                                      : 0.3),
                                        ),
                                        child: MyImage(
                                            width: 18,
                                            height: 18,
                                            imagePath: 'ic_coin.png'),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      MyText(
                                        text: "Conversion Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xffC4C4C4),
                                        fontsizeNormal: 11.5,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text:
                                            '1 coin = \$${statistics!.coinValue}',
                                        color: white,
                                        fontsizeNormal: 14,
                                        fontwaight: FontWeight.bold,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: "Coin Value",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xff8B8B8B),
                                        fontsizeNormal: 10.5,
                                        multilanguage: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 13, left: 15, right: 8),
                                  decoration: BoxDecoration(
                                    color: Constant.darkMode == "true"
                                        ? buttonDisable
                                        : const Color(0xffE4F5FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: const Color(0xff71b6e1)
                                              .withOpacity(
                                                  Constant.darkMode == "true"
                                                      ? 0.4
                                                      : 0.15),
                                        ),
                                        child: const Icon(
                                          Icons.visibility,
                                          size: 18,
                                          color: Color(0xff7CCEFF),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      MyText(
                                        text: "Engagement Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xffC4C4C4),
                                        fontsizeNormal: 11.5,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: statistics!.overallSubscribers
                                            .toString(),
                                        color: white,
                                        fontsizeNormal: 14,
                                        fontwaight: FontWeight.bold,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: "Content Engagement Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xff8B8B8B),
                                        fontsizeNormal: 10.5,
                                        multilanguage: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (ResponsiveHelper.isMobile(context)) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 13, left: 15, right: 8),
                                  decoration: BoxDecoration(
                                    color: Constant.darkMode == "true"
                                        ? buttonDisable
                                        : const Color(0xffFCE5FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: const Color(0xffF8D248)
                                              .withOpacity(
                                                  Constant.darkMode == "true"
                                                      ? 0.15
                                                      : 0.3),
                                        ),
                                        child: MyImage(
                                            width: 18,
                                            height: 18,
                                            imagePath: 'ic_coin.png'),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      MyText(
                                        text: "Conversion Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xffC4C4C4),
                                        fontsizeNormal: 11.5,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text:
                                            '1 coin = \$${statistics!.coinValue}',
                                        color: white,
                                        fontsizeNormal: 14,
                                        fontwaight: FontWeight.bold,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: "Coin Value",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xff8B8B8B),
                                        fontsizeNormal: 10.5,
                                        multilanguage: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 13, left: 15, right: 8),
                                  decoration: BoxDecoration(
                                    color: Constant.darkMode == "true"
                                        ? buttonDisable
                                        : const Color(0xffE4F5FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: const Color(0xff71b6e1)
                                              .withOpacity(
                                                  Constant.darkMode == "true"
                                                      ? 0.4
                                                      : 0.15),
                                        ),
                                        child: const Icon(
                                          Icons.visibility,
                                          size: 18,
                                          color: Color(0xff7CCEFF),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      MyText(
                                        text: "Engagement Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xffC4C4C4),
                                        fontsizeNormal: 11.5,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: statistics!.overallSubscribers
                                            .toString(),
                                        color: white,
                                        fontsizeNormal: 14,
                                        fontwaight: FontWeight.bold,
                                        multilanguage: false,
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      MyText(
                                        text: "Content Engagement Rate",
                                        color: Constant.darkMode != "true"
                                            ? pureBlack
                                            : const Color(0xff8B8B8B),
                                        fontsizeNormal: 10.5,
                                        multilanguage: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(
                        height: 20,
                      ),
                      buildBarChart(statistics!.monthlyChartViews,
                          statistics!.yearChartViews),
                      const SizedBox(
                        height: 20,
                      ),
                      /*Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              width: MediaQuery.of(context).size.width * 0.92,
                              decoration: BoxDecoration(
                                  color: buttonDisable,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: "videos",
                                    color: white,
                                    fontwaight: FontWeight.bold,
                                    fontsizeNormal: Dimens.textBig,
                                  ),
                                  const SizedBox(
                                    height: 23,
                                  ),
                                  ListView.separated(
                                    itemCount: statistics!.videoList.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      var video = statistics!.videoList[i];
                                      return Row(
                                        children: [
                                          Container(
                                            height: 38,
                                            width: 38,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: MyNetworkImage(
                                                imagePath: video.portraitImg,
                                                fit: BoxFit.cover),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: MyText(
                                            text: video.title,
                                            color: white,
                                            multilanguage: false,
                                            fontwaight: FontWeight.w600,
                                          )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          MyText(
                                              text: video.totalView.toString(),
                                              color: white,
                                              multilanguage: false,
                                              fontsizeNormal: 12.5),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          MyText(
                                              text: "views",
                                              color: white,
                                              fontsizeNormal: 12.5)
                                        ],
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return const SizedBox(
                                        height: 13,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )*/
                      withdrawTable(statistics!.withdrawalHistory)
                    ],
                  ),
                ),
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.musicSearch)
          : AppBar(
              backgroundColor: appBarColor,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: white,
                ),
              ),
              title: MyText(text: "dashboard", color: white),
            ),
      body: !ResponsiveHelper.isMobile(context)
          ? Utils.sidePanelWithBody(
              myWidget: buildBody(),
            )
          : Utils().pageBg(context, child: buildBody()),
    );
  }
}
