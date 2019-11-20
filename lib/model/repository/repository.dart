abstract class Repository<T, ID> {
  
  Future<T> save(T entity);
  
  Future<T> update(T entity);

  Future<T> findById(ID id);

  Future<void> delete(T entity);
}
