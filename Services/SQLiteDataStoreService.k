KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    KuKey.Models
    KuKey.Databases
}
# SQLite 服务
SQLiteDataStoreService : (path str->$) {
    _Context = SQLiteContext(path)
} & $ IDataStoreService(me) {
    _Context SQLiteContext

    [GetAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        Set : _Context.[Set T]()
        r : Set.Where{i->match(i)}.ToList()
        <<- Task.FromResult(r)
    }

    [PostAsync (T BaseModel)] : (item T ->> r bool) {
        Set : _Context.[Set T]()
        Set.Add(item)
        << _Context.SaveChangesAsync()
        <<- Task.FromResult(true)
    }

    [PutAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        Set : _Context.[Set T]()
        ? Set.Where{i->match(i)}.Count() > 0 {
            Set.Update(item)
            << _Context.SaveChangesAsync()
        } _ {
            << PostAsync(item)
        }
        <<- Task.FromResult(true)
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->> r bool) {
        Set : _Context.[Set T]()
        r : Set.Where{i->match(i)}.ToList()
        ? r.Count > 0 {
            Set.RemoveRange(r)
            << _Context.SaveChangesAsync()
        }
        <<- Task.FromResult(true)
    }
}
#:SQLiteContext
