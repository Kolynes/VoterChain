String shortenInteger(int value) {
  if(value == null)
    return "...";
	else if(value >= 1000000000)
		return "${(value / 1000000000).toStringAsFixed(1)}B";
	else if(value >= 1000000)
		return "${(value / 1000000).toStringAsFixed(1)}M";
	else if(value >= 1000)
    return "${(value / 1000).toStringAsFixed(1)}K";
  else return value.toString();
}