import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/cancel_dialogue.dart';
import 'package:rendezvous_beta_v3/dialogues/comfirm_dialogue.dart';
import 'package:rendezvous_beta_v3/dialogues/error_dialogue.dart';
import 'package:rendezvous_beta_v3/models/users.dart';
import 'package:rendezvous_beta_v3/services/discover_service.dart';
import 'package:rendezvous_beta_v3/services/google_places_service.dart';
import '../dialogues/date_time_dialogue.dart';
import '../services/match_data_service.dart';

class DatesModel {
  DatesModel({this.discoverData, this.dateData});
  final DiscoverData? discoverData;
  final DateData? dateData;
  DateTime? _dateTime;

  void setDateTime(DateTime date, TimeOfDay time) {
    _dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<List<String>> get commonDates async {
    List<String> commonDates = [];
    if (discoverData != null) {
      for (String date in discoverData!.dates) {
        if (UserData.dates.contains(date)) {
          commonDates.add(date);
        }
      }
    } else if (dateData != null) {
      for (var date in dateData!.dateTypes!) {
        if (UserData.dates.contains(date)) {
          commonDates.add(date.toString());
        }
      }
    }
    return commonDates;
  }

  Future<Map> get venueData async {
    final List<String> _commonDates = await commonDates;
    for (String date in _commonDates) {
      final Map _venue = await GooglePlacesService(venueType: date).venue;
      if (_venue["status"] == "ok") {
        return {"venue": _venue, "venueType": date};
      }
    }
    throw ("No venues found");
  }

  Future<Map> get matchData async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    if (discoverData != null) {
      final DocumentSnapshot _matchSnapshot =
          await _db.collection("userData").doc(discoverData!.uid).get();
      final Map _matchData = _matchSnapshot.data() as Map;
      return _matchData;
    } else if (dateData != null) {
      final DocumentSnapshot _matchSnapshot =
          await _db.collection("userData").doc(dateData!.matchID).get();
      final Map _matchData = _matchSnapshot.data() as Map;
      return _matchData;
    } else {
      throw ('must have either discover or date data to preform this operation');
    }
  }

  Future<void> getDate(BuildContext context,
      {double? userRating, bool pickAnother = false}) async {
    try {
      final Map _venueData = await venueData;
      final Map _matchData = await matchData;
      if (_venueData["venue"]["status"] == "ok") {
        await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
            context,
            pickAnother: pickAnother,
            matchName: _matchData["name"],
            venueName: _venueData["venue"]["name"],
            openHours: _venueData["venue"]["weekdayText"]);
        if (_dateTime != null &&
            await GooglePlacesService.checkDateTime(
                _dateTime!, _venueData["venue"])) {
          await MatchDataService.updateMatchData(
                  otherUserUID: discoverData != null
                      ? discoverData!.uid
                      : dateData != null
                          ? dateData!.matchID
                          : throw ("must have either discover or date data to preform this operation"),
                  dateType: _venueData['venueType'],
                  dateTime: _dateTime!,
                  venue: _venueData["venue"]["name"],
                  venueID: _venueData["venue"]["id"],
                  userRating: userRating)
              .then((value) => showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, _) => value
                      ? ConfirmDialogue(
                          dateTime: _dateTime!,
                          venueName: _venueData["venue"]["name"],
                          animation: animation,
                          matchName: _matchData["name"])
                      : ErrorDialogue(animation: animation)));
        } else if (_dateTime == null) {
          showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, _) =>
                  CancelDialogue(animation: animation));
        } else if (!await GooglePlacesService.checkDateTime(
            _dateTime!, _venueData["venue"])) {
          _dateTime = null;
          getDate(context, pickAnother: true);
        }
      } else {
        showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, _) =>
                ErrorDialogue(animation: animation));
      }
    } catch (e) {
      await MatchDataService.createMatch(
          otherUserUID: discoverData != null
              ? discoverData!.uid
              : dateData != null
                  ? dateData!.matchID
                  : throw ("must have either discover or date data to preform this operation"));
    }
  }

  Future<void> rescheduleDate(BuildContext context,
      {bool pickAnother = false}) async {
    if (dateData != null && dateData?.venueID != null) {
      final Map _venueData =
          await GooglePlacesService().venueFromId(dateData!.venueID!);
      final Map _matchData = await matchData;
      if (_venueData["venue"]["status"] == "ok") {
        await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
            context,
            venueName: _venueData["venue"]["name"],
            matchName: _matchData["name"],
            openHours: _venueData["venue"]["weekdayText"],
            initialDialogue: false);
        if (_dateTime != null &&
            await GooglePlacesService.checkDateTime(
                _dateTime!, _venueData["venue"])) {
          await MatchDataService.rescheduleDate(
                  otherUserUID: dateData != null
                      ? dateData!.matchID
                      : throw ("must have date data to preform this operation"),
                  dateTime: _dateTime!)
              .then((value) => showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, _) => value
                      ? CongratsDialogue(
                          animation: animation,
                          venueName: _venueData["venue"]["name"],
                          matchName: _matchData["name"],
                          openHours: _venueData["venue"]["weekdayText"],
                        )
                      : ErrorDialogue(animation: animation)));
        } else if (_dateTime == null) {
          showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, _) =>
                  CancelDialogue(animation: animation));
        } else if (!await GooglePlacesService.checkDateTime(
            _dateTime!, _venueData["venue"])) {
          getDate(context, pickAnother: true);
        }
      } else {
        showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, _) =>
                ErrorDialogue(animation: animation));
      }
    } else {
      throw ("dateData required for this operation");
    }
  }

  Future<void> deleteData(BuildContext context) async {
    if (dateData != null) {
      await MatchDataService.deleteDate(otherUserUID: dateData!.matchID);
    } else {
      throw ("need dateData");
    }
  }
}
