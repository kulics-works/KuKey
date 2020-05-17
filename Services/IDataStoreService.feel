<- Kulics.KuKey.Services

-> {
    System
    System.Linq
    
    Kulics.KuKey.Models
}

IDataStoreService : $$ {
    QueryAsync (func (IQueryContext->>) ->>)
    SaveAsync (func (ISaveContext->>) ->>)
}

IQueryContext : $$ {
    [Set (T BaseModel)] (-> r [IQueryable T])
}

ISaveContext : $$ {
    [Set (T BaseModel)] (-> r [IQueryable T])
    [Create (T BaseModel)] (item T ->)
    [Update (T BaseModel)] (item T ->)
    [Delete (T BaseModel)] (id str ->)
}
