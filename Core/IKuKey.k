Kulics.KuKey.Core . {
    System
    System.Linq
    
    Kulics.KuKey.Models
    Kulics.KuKey.Services
}

# 核心接口
IKuKey : $$ {
    UpdateEncryptService (srv IEncryptService->)
    [Create (T BaseModel)] (item T ->>id str)
    [Update (T BaseModel)] (item T ->>)
    [Delete (T BaseModel)] (id str ->>)
    [Query (T BaseModel)] (id str ->> r ?T)
    [LINQ T] (query (ICoreContext->T) ->r T)
    Export (->>text str)
    Import (text str->>)
    GeneratePassword (len int, number bool, lower bool, upper bool, symbol bool->v str)
}

ICoreContext : IDataContext & $$ {
    [Set (T BaseModel)] (-> r [IQueryable T])
    [Decrypt (T BaseModel)] (item T->r T, b bool)
}
