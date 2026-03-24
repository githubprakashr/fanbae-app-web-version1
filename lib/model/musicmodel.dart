class MusicModel {
  MusicModel({
    required this.status,
    required this.message,
    required this.result,
  });
  late final int status;
  late final String message;
  late final Result result;

  MusicModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    result = Result.fromJson(json['result']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['result'] = result.toJson();
    return _data;
  }
}

class Result {
  Result({
    required this.category,
    required this.language,
    required this.artist,
  });
  late final List<Category> category;
  late final List<Language> language;
  late final List<Artist> artist;

  Result.fromJson(Map<String, dynamic> json){
    category = List.from(json['category']).map((e)=>Category.fromJson(e)).toList();
    language = List.from(json['language']).map((e)=>Language.fromJson(e)).toList();
    artist = List.from(json['artist']).map((e)=>Artist.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['category'] = category.map((e)=>e.toJson()).toList();
    _data['language'] = language.map((e)=>e.toJson()).toList();
    _data['artist'] = artist.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Category {
  Category({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Category.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Language {
  Language({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Language.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

class Artist {
  Artist({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Artist.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}