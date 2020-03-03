KuKey.Services . {
    System
    
    KuKey.Models
}

IDataStoreService : $$ {
    [GetAsync (T BaseModel)] (match (T->bool) ->> @ r T)
    [PostAsync (T BaseModel)] (item T ->> r bool)
    [PutAsync (T BaseModel)] (match (T->bool), item T ->> r bool)
    [DeleteAsync (T BaseModel)] (match (T->bool) ->> r bool)
}
