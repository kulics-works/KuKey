Kulics.KuKey.Services . {
    System
    
    Kulics.KuKey.Models
}

IDataStoreService : $$ {
    [GetAsync (T BaseModel)] (match (T->bool) ->> @ r T)
    [PostAsync (T BaseModel)] (item T ->>)
    [PutAsync (T BaseModel)] (match (T->bool), item T ->>)
    [DeleteAsync (T BaseModel)] (match (T->bool) ->>)
}
