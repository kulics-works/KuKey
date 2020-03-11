Kulics.KuKey.Core . {
    System
    
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
    [QueryAll (T BaseModel)] (match (T->bool) ->> @ r T)
    Export (->>text str)
    Import (text str->>)
    GeneratePassword (lv PasswordLevel, len int->v str)
}
