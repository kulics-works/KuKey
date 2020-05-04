<- Kulics.KuKey.Services

-> {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    Kulics.KuKey.Models
    Kulics.KuKey.Databases
}
# "SQLite 数据存储服务"
SQLiteDataStoreService : IDataStoreService \/ (path str->$) {
    _Path = path
} \/ $ {
    _Path str

    QueryAsync : (func (IQueryContext->>) ->>) {
        ! ctx : SQLiteContext(_Path) {
            func~>(SQLiteDataContext(ctx))
        }
    }

    SaveAsync : (func (ISaveContext->>) ->>) {
        ! ctx : SQLiteContext(_Path) {
            func~>(SQLiteDataContext(ctx))
            ctx.SaveChangesAsync~>()
        }
    }
}

SQLiteDataContext : IQueryContext \/ ISaveContext \/ $ {
    _ctx SQLiteContext

    [Set (T BaseModel)] : (-> r [IQueryable T]) {
        <- _ctx.[Set T]()
    }

    [Create (T BaseModel)] : (item T ->) {
        _ctx.[Set T]().Add(item)
    }

    [Update (T BaseModel)] : (item T ->) {
        _ctx.[Set T]().Update(item)
    }

    [Delete (T BaseModel)] : (id str ->) {
        @ item : _ctx.[Set T]().Where{i->i.Id==id} {
            _ctx.[Set T]().Remove(item)
        }
    }
} \/ (ctx SQLiteContext->$) {
    _ctx = ctx
}

##SQLiteContext
