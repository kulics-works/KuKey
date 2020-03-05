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
    _Path = path
} & $ IDataStoreService {
    _Path str

    [GetAsync (T BaseModel)] : (match (T->bool) ->> r []T) {
        ! ctx : SQLiteContext(_Path)
        <- ctx.[Set T]().Where(match).to_list()
    }

    [PostAsync (T BaseModel)] : (item T ->>) {
        ! ctx : SQLiteContext(_Path)
        ctx.[Set T]().Add(item)
        << ctx.SaveChangesAsync()
    }

    [PutAsync (T BaseModel)] : (item T ->>) {
        ! ctx : SQLiteContext(_Path)
        dbset : ctx.[Set T]()
        ? dbset.Where{i->i.Id==item.Id}.Count() > 0 {
            dbset.Update(item)
        } _ {
            dbset.Add(item)
        }
        << ctx.SaveChangesAsync()
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->>) {
        ! ctx : SQLiteContext(_Path)
        dbset : ctx.[Set T]()
        r : dbset.Where(match).ToList()
        ? r.Count > 0 {
            dbset.RemoveRange(r)
            << ctx.SaveChangesAsync()
        }
    }
}
#:SQLiteContext
