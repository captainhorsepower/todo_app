abstract class Dao<T> {

  T fromJson(Map<String, dynamic> data);

  Map<String, dynamic> toJson(T object);
}
