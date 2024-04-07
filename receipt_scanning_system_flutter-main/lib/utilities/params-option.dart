class ParamsOption {
  int? page;
  int? offset;
  int? limit;
  String? fields;
  String? text;
  String? filter;
  String? s;
  String? from;
  String? to;
  String? sort;
  String? isFullText;

  ParamsOption({this.page, this.offset, this.limit, this.fields, this.text, this.filter, this.s, this.from, this.to, this.sort, this.isFullText});

  Map toJson() => {
        'page': page,
        'offset': offset,
        'limit': limit,
        'fields': fields,
        'text': text,
        'filter': filter,
        's': s,
        'from': from,
        'to': to,
        'sort': sort,
        'is_full_text': isFullText,
      };

  String toParams(Map jsonParams) {
    try {
      String params = '';
      jsonParams.keys.toList().forEach((element) {
        // print(jsonParams[element]);
        if (jsonParams[element] != null) {
          params += '$element=${jsonParams[element]}&';
        }
      });
      params = '?${params.substring(0, params.length - 1)}';
      return params;
    } catch (ex) {
      // print('ParamsOption toParams ===> $ex');
      return '';
    }
  }
}
