KuKey . {
    System
    
    KuKey.Models
    KuKey.Services
}

# 核心接口
IKuKey : $$ {
    UpdateEncryptService (srv IEncryptService->)
    [Get (T BaseModel)] (match (T->bool) ->> @ r T)
    [Post (T BaseModel)] (item T ->>)
    [Put (T BaseModel)] (match (T->bool), item T ->>)
    [Delete (T BaseModel)] (match (T->bool) ->>)
    Export (->>text str)
    Import (text str->>)
}
