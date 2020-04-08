Kulics.KuKey.Services . {
    System
    System.Linq
    
    Kulics.KuKey.Models
}

IDataStoreService : $$ {
    [CreateAsync (T BaseModel)] (item T ->>)
    [UpdateAsync (T BaseModel)] (item T ->>)
    [DeleteAsync (T BaseModel)] (id str ->>)
    [QueryAsync (T BaseModel)] (id str ->> r ?T)
    [LINQ T] (query (IDataContext->T) -> r T)
}

IDataContext : $$ {
    [Set (T BaseModel)] (-> r [IQueryable T])
}
