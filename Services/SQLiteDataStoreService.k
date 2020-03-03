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
} & $ IDataStore(me) {
    _Context SQLiteContext

    [CreateAsync (T BaseModel)] : (item T ->> r bool) {
        Set : _Context.[Set T]()
        Set.Add(item)
        << _Context.SaveChangesAsync()
        <<- Task.FromResult(true)
    }

    [UpdateAsync (T BaseModel)] : (item T ->> r bool) {
        Set : _Context.[Set T]()
        Set.Update(item)
        << _Context.SaveChangesAsync()
        <<- Task.FromResult(true)
    }

    [UpdateAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        Set : _Context.[Set T]()
        ? Set.Where{i->match(i)}.Count() > 0 {
            << me.UpdateItemAsync(item)
        } _ {
            << me.AddItemAsync(item)
        }
        DependencyService.[Get [MemoryStore T]]().reload()
        <<- Task.FromResult(true)
    }

    [RetrieveAsync (T BaseModel)] : (match (T->bool) ->> r T) {
        Set : _Context.[Set T]()
        r : Set.FirstOrDefault(match)
        <<- Task.FromResult(r)
    }

    [RetrieveAsync (T BaseModel)] : (forceRefresh bool ->> @ r T) {
        Set : _Context.[Set T]()
        r : (@ it : Set.. -> select it).ToList()
        <<- Task.FromResult(r)
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->> r bool) {
        Set : _Context.[Set T]()
        item : Set.FirstOrDefault(match)
        Set.Remove(item)
        << _Context.SaveChangesAsync()
        <<- Task.FromResult(true)
    }
}
#:SqliteContext
