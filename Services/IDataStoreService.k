Kulics.KuKey.Services . {
    System
    
    Kulics.KuKey.Models
}

IDataStoreService : $$ {
    [CreateAsync (T BaseModel)] (item T ->>)
    [UpdateAsync (T BaseModel)] (item T ->>)
    [DeleteAsync (T BaseModel)] (id str ->>)
    [QueryAsync (T BaseModel)] (id str ->> r ?T)
    [QueryAllAsync (T BaseModel)] (match (T->bool) ->> @ r T)
}
