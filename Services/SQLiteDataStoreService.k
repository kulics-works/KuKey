Kulics.KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    Kulics.KuKey.Models
    Kulics.KuKey.Databases
}
# SQLite 数据存储服务
SQLiteDataStoreService : (path str->$) {
    _Context = SQLiteContext(path)
} & $ IDataStoreService {
    _Context SQLiteContext

    [GetAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        <- _Context.[Set T]().Where{i->match(i)}.ToList()
    }

    [PostAsync (T BaseModel)] : (item T ->>) {
        _Context.[Set T]().Add(item)
        << _Context.SaveChangesAsync()
    }

    [PutAsync (T BaseModel)] : (match (T->bool), item T ->>) {
        Set : _Context.[Set T]()
        ? Set.Where{i->match(i)}.Count() > 0 {
            Set.Update(item)
            << _Context.SaveChangesAsync()
        } _ {
            << PostAsync(item)
        }
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->>) {
        Set : _Context.[Set T]()
        r : Set.Where{i->match(i)}.ToList()
        ? r.Count > 0 {
            Set.RemoveRange(r)
            << _Context.SaveChangesAsync()
        }
    }
}
#:SQLiteContext
