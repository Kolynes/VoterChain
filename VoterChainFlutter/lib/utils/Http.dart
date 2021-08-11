import 'package:requests/requests.dart';

typedef Future<String> HeaderFunction();

class Settings {
  final Map<String, dynamic> headers;
  final String base;

  Settings(this.headers, this.base);
}

class Http {
  final Settings global;

  Http(this.global);

  Future<JsonResponse> post(String url, dynamic body, {String contentType: "", int timeout: 15000}) async {
    var requestHeaders = Map<String, String>();
    for(var entry in global.headers.entries)
      requestHeaders[entry.key] = entry.value.runtimeType == HeaderFunction
        ?await entry.value()
        :entry.value;
    var bodyEncoding = contentType == "application/json"
      ?RequestBodyEncoding.JSON
      :RequestBodyEncoding.FormURLEncoded;
    try {
      var response = await Requests.post(
        global.base + url, 
        bodyEncoding: bodyEncoding,
        headers: requestHeaders, 
        body: body, 
        timeoutSeconds: timeout
      );
      await Requests.setStoredCookies(response.url.host, Requests.extractResponseCookies(response.headers));
      return JsonResponse(baseResponse: response);
    } catch(error) {
      print(error.toString());
      return JsonResponse(errors: Errors(summary: "Connection to server refused. Please retry",));
    }
  }

  Future<JsonResponse> get(String url, {Map<String, dynamic> queryParameters: const {}, int timeout: 15000}) async {
    var requestHeaders = Map<String, String>();
    for(var entry in global.headers.entries)
      requestHeaders[entry.key] = entry.value.runtimeType == HeaderFunction
        ?await entry.value()
        :entry.value;
    try {
      var response = await Requests.get(
        global.base + url, 
        queryParameters: queryParameters, 
        headers: requestHeaders, 
        timeoutSeconds: timeout
      );
      await Requests.setStoredCookies(response.url.host, Requests.extractResponseCookies(response.headers));
      return JsonResponse(baseResponse: response);
    } catch(error) {
      print(error.toString());
      return JsonResponse(errors: Errors(summary: "Connection to server refused. Please retry"));
    }
  }

}

class Errors {
  final String summary; 
  final Map<String, dynamic> fields;

  Errors({this.summary, this.fields});
}

class JsonResponse<T> {
  Errors errors;
  int numberOfPages, nextPage, prevPage;
  bool hasNextPage;
  Response baseResponse;
  T data;

  int get status => baseResponse != null
    ?baseResponse.statusCode 
    :-1;

  JsonResponse({this.baseResponse, Errors errors}) {
    if(baseResponse != null){
      if(baseResponse.content().length > 0) {
        Map<String, dynamic> object = baseResponse.json();
        data = object["data"];
        if(object["errors"] != null)
          this.errors = Errors(
            summary: object["errors"]["summary"],
            fields: object["errors"]["fields"]
          );
        else this.errors = Errors(fields: {}, summary: "");
        numberOfPages = object["numberOfPages"];
        nextPage = object["nextPage"];
        prevPage = object["prevPage"];
        hasNextPage = object["nextPage"] != 0;
      }
    }
    else this.errors = errors;
  }

  Map<String, String> get headers => baseResponse.headers;
}
