// String when (num timestamp) {
//   num delta = (new DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
//   DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
//   if (delta > 3600 * 24 * 7) {
//     return "${date.day.toString()}/${date.month.toString()}/${date.year.toString()} ${date.hour.toString()}:${date.minute.toString()}";
//   } else if (delta > 3600 * 24 * 2) {
//     return "${(delta / (3600 * 24)).floor().toString()} days ago";
//   } else if (delta > 3600 * 24) {
//     return 'yesterday';
//   } else if (delta > 3600) {
//     return "${(delta / 3600).floor()} hour${(delta / 3600).floor() == 1 ? '' : 's'} ago";
//   } else if (delta > 60) {
//     return "${(delta / 60).floor()} minute${(delta / 60).floor() == 1 ? '' : 's'} ago";
//   } else if (delta > 0) {
//     return "${delta.floor()} second${delta.floor() == 1 ? '' : 's'} ago";
//   }
//   return null;
// }

String date (num timestamp) {
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day.toString()}/${date.month.toString()}/${date.year.toString()}";
}

String datetime (num timestamp) {
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day.toString()}/${date.month.toString()}/${(date.year).toString()} ${date.hour < 10 ? ('0' + date.hour.toString()) : date.hour.toString()}:${date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString()}";
}

List<num> duration (num timestamp) {
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
  return [
    date.year - 1970,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second
  ];
}

String when(num timestamp) {
  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
  var now = new DateTime.now();
  if(now.difference(date).inDays > 1) {
    var weekday = [
      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ][date.weekday - 1];
    var month = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ][date.month - 1];
    return "$weekday, ${date.day} $month";
  }
  else if(now.difference(date).inDays == 1)
    return "yesterday";
  else return "";
}