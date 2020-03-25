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
} & IDataStoreService & $ {
    _Path str

    [CreateAsync (T BaseModel)] : (item T ->>) {
        ! ctx : SQLiteContext(_Path)
        ctx.[Set T]().Add(item)
        << ctx.SaveChangesAsync()
    }

    [UpdateAsync (T BaseModel)] : (item T ->>) {
        ! ctx : SQLiteContext(_Path)
        ctx.[Set T]().Update(item)
        << ctx.SaveChangesAsync()
    }

    [DeleteAsync (T BaseModel)] : (id str ->>) {
        ! ctx : SQLiteContext(_Path)
        dbset : ctx.[Set T]()
        r : dbset.First{i->i.Id==id}
        ? r >< nil {
            dbset.Remove(r)
            << ctx.SaveChangesAsync()
        }
    }

    [QueryAsync (T BaseModel)] : (id str ->> r ?T) {
        ! ctx : SQLiteContext(_Path)
        <- ctx.[Set T]().First{i->i.Id==id}
    }

    [QueryAllAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        ! ctx : SQLiteContext(_Path)
        <- ctx.[Set T]().Where(match).to_list()
    }
}
#:SQLiteContext
