KuKey.Services . {
}

IDataStoreService : $$ {
    [CreateAsync T] (item T ->> r bool)
    [UpdateAsync T] (item T ->> r bool)
    [UpdateAsync T] (match (T->bool), item T ->> r bool)
    [RetrieveAsync T] (match (T->bool) ->> r T)
    [RetrieveAsync T] (forceRefresh bool ->> @ r T)
    [DeleteAsync T] (match (T->bool) ->> r bool)
}
