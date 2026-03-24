import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/schedulecallmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/responsive_helper.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/video_audio_call/videocall.dart';
import 'package:fanbae/video_audio_call/videocallmanager.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/nodata.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/successmodel.dart';
import '../utils/color.dart';
import '../utils/dimens.dart';
import '../webservice/apiservice.dart';
import '../widget/mytext.dart';
import 'incomingcalldialog.dart';

class ScheduleCall extends StatefulWidget {
  final bool isCreator;
  final String? creatorId;

  const ScheduleCall({super.key, required this.isCreator, this.creatorId});

  @override
  State<ScheduleCall> createState() => _ScheduleCallState();
}

class _ScheduleCallState extends State<ScheduleCall> {
  final TextEditingController dateController = TextEditingController();
  List<Slots>? slots;
  List<BookedData>? bookedSlots;
  Slots? selectedSlot;
  List<String> type = ["Video Call", "Audio Call"];
  String? selectedType;
  String? selectedStatus;
  final DateTime today = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  List<String> filterTypes = [
    "Pending",
    "Accepted",
    "Completed",
    "Declined",
    "Expired"
  ];
  String filterType = "Pending";
  final ScrollController _scrollController = ScrollController();
  int selectedIndex = 0;
  DateTime? selectedDate;
  int? selectedYear;
  String? year;
  String? month;
  String? monthName;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDay);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getScheduleData(widget.creatorId);
    });
  }

  void _onFilterTap(int index, String type) {
    setState(() {
      selectedIndex = index;
      filterType = type;
    });

    // Scroll a bit to show next item if available
    // Each item width is assumed around 100-120px
    double scrollOffset = index * 100.0 - 40; // adjust to taste
    if (scrollOffset < 0) scrollOffset = 0;
    _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    getScheduleData(widget.creatorId);
  }

  Future<void> getScheduleData(String? creatorId) async {
    Utils.showProgress(context);
    setState(() {
      selectedSlot = null;
      slots = null;
      bookedSlots = null;
    });
    ScheduleCallModel scheduleData = await ApiService().getScheduleCallData(
        creatorId, dateController.text, filterType, month, year);
    setState(() {
      slots = scheduleData.data.slots;
      bookedSlots = scheduleData.data.bookedSlots;
    });
    Utils().hideProgress(context);
  }

  String formatTime(String time24) {
    final dateTime = DateFormat("HH:mm:ss").parse(time24);
    return DateFormat("h:mm a").format(dateTime);
  }

  showAlertDialog(scheduleId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: colorPrimaryDark,
            title: MyText(
              text: "Are you sure want to $selectedStatus this call?",
              multilanguage: false,
              fontsizeNormal: 16,
              maxline: 2,
              fontwaight: FontWeight.bold,
              color: white,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: MyText(
                    text: "no",
                    color: pureBlack,
                  )),
              ElevatedButton(
                  onPressed: () {
                    scheduleCallAction(scheduleId);
                  },
                  child: MyText(text: "yes", color: pureBlack)),
            ],
          );
        });
  }

  scheduleCallAction(scheduleId) async {
    Utils.showProgress(context);

    final rating = await ApiService().scheduleCallAction(
      scheduleId,
      selectedStatus == "Accept" ? "accept" : "declined",
    );
    // widget might have been disposed while awaiting — bail out if so
    if (!mounted) return;

    Utils().hideProgress(context);
    if (mounted) {
      Utils().showSnackBar(context, "${rating.message}", false);
    }
    if (rating.status == 200) {
      Navigator.pop(context);
      setState(() {
        init();
      });
    }
  }

  Future<void> monthPicker(BuildContext context) async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: selectedDate ?? DateTime.now(),
      monthStylePredicate: (DateTime val) {
        return null;
      },
      yearStylePredicate: (int val) {
        return null;
      },
      monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: const PickerDialogSettings(
            verticalScrolling: false, dialogRoundedCornersRadius: 8),
        headerSettings: PickerHeaderSettings(
          headerBackgroundColor: textColor,
          headerCurrentPageTextStyle:
              const TextStyle(fontSize: 14, color: Colors.black),
          headerSelectedIntervalTextStyle: const TextStyle(fontSize: 16),
          headerIconsColor: Colors.black,
        ),
        dateButtonsSettings: const PickerDateButtonsSettings(
          selectedMonthBackgroundColor: pureBlack,
          unselectedMonthsTextColor: pureBlack,
        ),
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: black,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: pureWhite,
              ),
            ),
          ),
          cancelWidget: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.red[900],
            ),
          ),
        ),
      ),
    ).then((DateTime? date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
          year = date.year.toString();
          month = date.month.toString().padLeft(2, '0');
          monthName = DateFormat('MMM').format(date);
          getScheduleData(widget.creatorId);
        });
      }
    });
  }

  void makeCall(BuildContext context, CallType callType, otherUserId,
      otherUserName, otherUserPic) {
    final videoCallManager = VideoCallManager();

    videoCallManager.makeCall(
      targetUserId: otherUserId,
      targetUserName: otherUserName,
      currentUserId: Constant.userID ?? '',
      currentUserName: Constant.userName ?? '',
      currentUserImage: Constant.userImage ?? '',
      callType: callType,
    );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCall(
              isCaller: true,
              targetUserName: otherUserName,
              targetUserImage: otherUserPic),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.videoSearch)
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
              title: MyText(text: "schedulecall", color: white),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          init();
        },
        child: ResponsiveHelper.checkIsWeb(context)
            ? Utils.sidePanelWithBody(
                myWidget: buildBody(),
              )
            : buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Utils().pageBg(context,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isCreator) ...[
                        TableCalendar(
                          focusedDay: _selectedDay,
                          firstDay: today,
                          lastDay:
                              DateTime(today.year + 5, today.month, today.day),
                          calendarFormat: _calendarFormat,
                          headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              headerPadding: EdgeInsets.zero,
                              headerMargin:
                                  const EdgeInsets.only(top: 25, bottom: 30),
                              titleTextStyle: TextStyle(
                                  color: white, fontWeight: FontWeight.w700),
                              leftChevronMargin: EdgeInsets.zero,
                              leftChevronIcon: Container(
                                padding: const EdgeInsets.all(6.5),
                                decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.arrow_back,
                                  size: 15,
                                ),
                              ),
                              rightChevronMargin: EdgeInsets.zero,
                              rightChevronIcon: Container(
                                padding: const EdgeInsets.all(6.5),
                                decoration: BoxDecoration(
                                    gradient: Constant.gradientColor,
                                    shape: BoxShape.circle),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  size: 15,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: buttonDisable,
                                  borderRadius: BorderRadius.circular(35))),
                          calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(
                                color: white,
                                fontSize: 13.5,
                              ),
                              todayDecoration: BoxDecoration(
                                  color: buttonDisable, shape: BoxShape.circle),
                              weekendTextStyle: TextStyle(
                                color: white,
                                fontSize: 13.5,
                              ),
                              todayTextStyle: TextStyle(
                                  color: white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              selectedDecoration: BoxDecoration(
                                  gradient: Constant.gradientColor,
                                  shape: BoxShape.circle),
                              selectedTextStyle: const TextStyle(
                                  color: pureBlack,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              cellMargin: const EdgeInsets.only(
                                  top: 10, bottom: 5, right: 6, left: 6)),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: white),
                            weekendStyle: TextStyle(color: white),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                dateController.text = DateFormat('dd/MM/yyyy')
                                    .format(selectedDay);
                                getScheduleData(widget.creatorId);
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                        ),
                      ],
                      widget.isCreator
                          ? GestureDetector(
                              onTap: () async => await monthPicker(context),
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35, vertical: 15),
                                decoration: BoxDecoration(
                                    color: buttonDisable,
                                    borderRadius: BorderRadius.circular(35)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: "Month Filter",
                                      multilanguage: false,
                                      color: white,
                                      fontwaight: FontWeight.bold,
                                      fontsizeNormal: 16,
                                    ),
                                    MyText(
                                      text: year != null && monthName != null
                                          ? "$monthName $year"
                                          : "Select",
                                      multilanguage: false,
                                      fontwaight: FontWeight.w600,
                                      fontsizeNormal: 13.5,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      if (!widget.isCreator) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 20),
                          child: SizedBox(
                            height: 50, // height for horizontal list
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: slots
                                      ?.where(
                                          (slot) => slot.status == "Available")
                                      .length ??
                                  0,
                              itemBuilder: (context, index) {
                                final availableSlots = slots
                                        ?.where((slot) =>
                                            slot.status == "Available")
                                        .toList() ??
                                    [];
                                final slot = availableSlots[index];
                                final isSelected =
                                    selectedSlot?.startTime == slot.startTime;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSlot = slot;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 7),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? null : buttonDisable,
                                      gradient: isSelected
                                          ? Constant.gradientColor
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        formatTime(slot.startTime),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 13.5,
                                              color: isSelected
                                                  ? pureBlack
                                                  : white,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          dropdownColor: colorPrimaryDark,
                          hint: MyText(
                              text: "selectcalltype",
                              color: white,
                              fontsizeNormal: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 11),
                            filled: true,
                            fillColor: buttonDisable,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: transparent),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: type.map((type) {
                            return DropdownMenuItem<String>(
                              value: type, // only use ID
                              child: Text(
                                type,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: white),
                              ), // display name
                            );
                          }).toList(),
                          onChanged: (String? newId) {
                            setState(() {
                              selectedType = newId!;
                            });
                          },
                        ),
                      ],
                      widget.isCreator
                          ? SizedBox(
                              height: 50,
                              child: ListView.builder(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: filterTypes.length,
                                itemBuilder: (context, index) {
                                  final isSelected = selectedIndex == index;
                                  return GestureDetector(
                                    onTap: () =>
                                        _onFilterTap(index, filterTypes[index]),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 7),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? Constant.gradientColor
                                            : null,
                                        color:
                                            isSelected ? null : buttonDisable,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          filterTypes[index],
                                          style: TextStyle(
                                            color:
                                                isSelected ? pureBlack : white,
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox(),
                      if (widget.isCreator) ...[
                        Utils().titleText("bookedslots"),
                        bookedSlots != null
                            ? bookedSlots!.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: bookedSlots?.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 8,
                                            right: 14),
                                        decoration: BoxDecoration(
                                            color: buttonDisable,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 85,
                                                  width: 92,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: MyNetworkImage(
                                                      imagePath: bookedSlots?[i]
                                                              .userImage ??
                                                          '',
                                                      fit: BoxFit.fill),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MyText(
                                                        text: bookedSlots?[i]
                                                                .userName ??
                                                            '',
                                                        color: white,
                                                        multilanguage: false,
                                                        fontsizeNormal: 14.5,
                                                        fontwaight:
                                                            FontWeight.bold,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 7,
                                                        ),
                                                        child: MyText(
                                                          text: bookedSlots?[i]
                                                                  .date ??
                                                              '',
                                                          color: white,
                                                          multilanguage: false,
                                                          fontsizeNormal: 12,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 7,
                                                                bottom: 7),
                                                        child: MyText(
                                                          text:
                                                              '${formatTime(bookedSlots?[i].startTime ?? '')} - ${formatTime(bookedSlots?[i].endTime ?? '')}',
                                                          color: white,
                                                          multilanguage: false,
                                                          fontsizeNormal: 12,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            bookedSlots?[i]
                                                                        .type ==
                                                                    "audio_call"
                                                                ? Icons.call
                                                                : CupertinoIcons
                                                                    .video_camera_solid,
                                                            color: white,
                                                            size: 19,
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          MyText(
                                                            text: bookedSlots?[
                                                                            i]
                                                                        .type ==
                                                                    "audio_call"
                                                                ? "Audio Call"
                                                                : "Video Call",
                                                            color: white,
                                                            fontsizeNormal: 12,
                                                            multilanguage:
                                                                false,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        if (bookedSlots?[i]
                                                                    .status !=
                                                                "pending" &&
                                                            Constant.isCreator ==
                                                                '1') ...[
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 3,
                                                                    horizontal:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                color: bookedSlots?[i]
                                                                            .status ==
                                                                        "declined"
                                                                    ? Colors.red
                                                                        .withOpacity(
                                                                            0.3)
                                                                    : Colors
                                                                        .green
                                                                        .withOpacity(
                                                                            0.3),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6)),
                                                            child: MyText(
                                                              text: bookedSlots?[
                                                                              i]
                                                                          .status ==
                                                                      "declined"
                                                                  ? 'Declined'
                                                                  : filterType ==
                                                                          "Completed"
                                                                      ? "Completed"
                                                                      : 'Accepted',
                                                              color: bookedSlots?[
                                                                              i]
                                                                          .status ==
                                                                      "declined"
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              multilanguage:
                                                                  false,
                                                              fontsizeNormal:
                                                                  11.5,
                                                              fontwaight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                        if (Constant
                                                                .isCreator ==
                                                            '0') ...[
                                                          MyText(
                                                            text: filterType ==
                                                                    "Completed"
                                                                ? "Completed"
                                                                : filterType ==
                                                                        "Expired"
                                                                    ? "Expired"
                                                                    : bookedSlots?[i].status ==
                                                                            "declined"
                                                                        ? 'Declined'
                                                                        : bookedSlots?[i].status ==
                                                                                "pending"
                                                                            ? 'Pending'
                                                                            : 'Accepted',
                                                            color: bookedSlots?[i]
                                                                            .status ==
                                                                        "declined" ||
                                                                    filterType ==
                                                                        "Expired"
                                                                ? Colors.red
                                                                : bookedSlots?[i]
                                                                            .status ==
                                                                        "pending"
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .green,
                                                            multilanguage:
                                                                false,
                                                            fontsizeNormal: 13,
                                                            fontwaight:
                                                                FontWeight.w600,
                                                          ),
                                                          /* ),*/
                                                        ],
                                                        if (bookedSlots?[i]
                                                                    .status ==
                                                                "pending" &&
                                                            Constant.isCreator ==
                                                                '1') ...[
                                                          filterType !=
                                                                  "Expired"
                                                              ? Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          selectedStatus =
                                                                              "Accept";
                                                                        });
                                                                        showAlertDialog(
                                                                            bookedSlots?[i].id);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                4,
                                                                            horizontal:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.green,
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.check,
                                                                              color: pureWhite,
                                                                              size: 13.5,
                                                                            ),
                                                                            MyText(
                                                                              text: " Accept",
                                                                              color: pureWhite,
                                                                              fontsizeNormal: 12,
                                                                              fontwaight: FontWeight.w600,
                                                                              multilanguage: false,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          selectedStatus =
                                                                              "Decline";
                                                                        });
                                                                        showAlertDialog(
                                                                            bookedSlots?[i].id);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                12),
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                4,
                                                                            horizontal:
                                                                                7),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.circular(5)),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.close,
                                                                              color: pureWhite,
                                                                              size: 13.5,
                                                                            ),
                                                                            MyText(
                                                                              text: " Decline",
                                                                              color: pureWhite,
                                                                              fontsizeNormal: 12,
                                                                              fontwaight: FontWeight.w600,
                                                                              multilanguage: false,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              : Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3,
                                                                      horizontal:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      color: filterType ==
                                                                              "Expired"
                                                                          ? Colors.red.withOpacity(
                                                                              0.3)
                                                                          : Colors.green.withOpacity(
                                                                              0.3),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6)),
                                                                  child: MyText(
                                                                    text: filterType ==
                                                                            "Expired"
                                                                        ? "Expired"
                                                                        : '',
                                                                    color: filterType ==
                                                                            "Expired"
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .green,
                                                                    multilanguage:
                                                                        false,
                                                                    fontsizeNormal:
                                                                        11.5,
                                                                    fontwaight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                        ],
                                                      ],
                                                    ),
                                                    if (bookedSlots?[i]
                                                                .status
                                                                .toLowerCase() ==
                                                            "accept" &&
                                                        filterType !=
                                                            "Completed" &&
                                                        Constant.isCreator ==
                                                            '0') ...[
                                                      (DateTime.parse(bookedSlots![
                                                                          i]
                                                                      .dateTimeStart)
                                                                  .isBefore(DateTime
                                                                      .now()) &&
                                                              DateTime.parse(
                                                                      bookedSlots![
                                                                              i]
                                                                          .dateTimeEnd)
                                                                  .isAfter(
                                                                      DateTime
                                                                          .now()))
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                if (!kIsWeb) {
                                                                  makeCall(
                                                                      context,
                                                                      bookedSlots?[i].type ==
                                                                              "audio_call"
                                                                          ? CallType
                                                                              .audio
                                                                          : CallType
                                                                              .video,
                                                                      bookedSlots?[
                                                                              i]
                                                                          .userId
                                                                          .toString(),
                                                                      bookedSlots?[
                                                                              i]
                                                                          .userName,
                                                                      bookedSlots?[
                                                                              i]
                                                                          .userImage);
                                                                } else {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      barrierColor:
                                                                          transparent,
                                                                      builder:
                                                                          (context) {
                                                                        return Dialog(
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                                          insetPadding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              50,
                                                                              25,
                                                                              50,
                                                                              25),
                                                                          clipBehavior:
                                                                              Clip.antiAliasWithSaveLayer,
                                                                          backgroundColor:
                                                                              colorPrimaryDark,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(20),
                                                                            constraints:
                                                                                const BoxConstraints(
                                                                              minWidth: 230,
                                                                              maxWidth: 375,
                                                                              minHeight: 130,
                                                                              maxHeight: 175,
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                MyText(
                                                                                  color: white,
                                                                                  text: 'web_dialog',
                                                                                  multilanguage: true,
                                                                                  textalign: TextAlign.center,
                                                                                  fontsizeNormal: Dimens.textTitle,
                                                                                  fontsizeWeb: Dimens.textTitle,
                                                                                  fontwaight: FontWeight.w500,
                                                                                  maxline: 2,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  fontstyle: FontStyle.normal,
                                                                                ),
                                                                                Container(
                                                                                  alignment: Alignment.centerRight,
                                                                                  child: InkWell(
                                                                                    hoverColor: colorPrimary,
                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                                                                                      margin: const EdgeInsets.all(1),
                                                                                      alignment: Alignment.center,
                                                                                      decoration: BoxDecoration(
                                                                                        color: buttonDisable,
                                                                                        borderRadius: BorderRadius.circular(15),
                                                                                      ),
                                                                                      child: MyText(
                                                                                        color: white,
                                                                                        text: "Ok",
                                                                                        multilanguage: false,
                                                                                        textalign: TextAlign.center,
                                                                                        fontsizeNormal: Dimens.textDesc,
                                                                                        fontsizeWeb: Dimens.textDesc,
                                                                                        maxline: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        fontwaight: FontWeight.w500,
                                                                                        fontstyle: FontStyle.normal,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                }
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(6),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6)),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      bookedSlots?[i].type ==
                                                                              "audio_call"
                                                                          ? Icons
                                                                              .call
                                                                          : Icons
                                                                              .video_call,
                                                                      color:
                                                                          pureWhite,
                                                                      size: 16,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    MyText(
                                                                      text:
                                                                          'Call Now',
                                                                      multilanguage:
                                                                          false,
                                                                      color:
                                                                          white,
                                                                      fontsizeNormal:
                                                                          11,
                                                                      fontwaight:
                                                                          FontWeight
                                                                              .w600,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                : const NoData()
                            : Container()
                      ]
                    ],
                  ),
                ),
              ),
              !widget.isCreator
                  ? GestureDetector(
                      onTap: () async {
                        if (selectedSlot == null) {
                          return Utils().showSnackBar(
                              context, "Slot field is required", false);
                        }
                        if (selectedType == null) {
                          return Utils().showSnackBar(
                              context, "Type field is required", false);
                        }
                        Utils.showProgress(context);
                        SuccessModel request = await ApiService().callRequest(
                            widget.creatorId ?? '',
                            dateController.text,
                            selectedSlot!.startTime,
                            selectedType == "Audio Call"
                                ? "audio_call"
                                : "video_call");

                        if (!mounted) return;
                        Utils().hideProgress(context);
                        if (mounted) {
                          Utils().showSnackBar(
                              context, "${request.message}", false);
                        }
                        if (request.status == 200) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(
                          top: 15,
                          bottom: 20,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            gradient: Constant.gradientColor),
                        child: MyText(
                            color: pureBlack,
                            text: "sendrequest",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsizeNormal: Dimens.textMedium,
                            maxline: 1,
                            fontwaight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ));
  }
}
