String requiredValidator(String value) {
  if(value.trim() == "")
    return "This field is required";
  return null;
}

Function requiredLengthValidator({double min = 0, double max = 1/0}) {
  return (String value) {
    if(value.trim().length < min)
      return "This field should be at least ${min.toInt()} characters long";
    else if (value.length > max)
      return "This field should not exceed ${max.toInt()} characters";
    else return null;
  };
}

String emailValidator(String value) {
  if(!RegExp(r"^[a-zA-Z0-9]{3,}@[a-zA-Z0-9]{3,}\.[a-zA-Z0-9]{2,}$").hasMatch(value.trim()))
    return "A valid email address is required";
  return null;
}

String usernameValidator(String value) {
  if(!RegExp(r"^[a-zA-Z0-9]{3,20}$").hasMatch(value.trim()))
    return "Invalid username";
  return null;
}