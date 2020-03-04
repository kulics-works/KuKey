KuKey . {
    System
    
    KuKey.Models
    KuKey.Databases
    KuKey.Services
}

# 主程序
KuKey : (databasePath str, masterPassword str->$) {     # 使用默认服务
    _DataStoreService = DefaultDataStoreService(databasePath)
    _EncryptService = DefaultEncryptService(masterPassword)
} & (dataSrv IDataStoreService, encryptSrv IEncryptService->$) {   # 使用自定义服务
    _DataStoreService = dataSrv
    _EncryptService = encryptSrv
} & $ {
    _DataStoreService IDataStoreService     # 存储服务
    _EncryptService IEncryptService         # 加密服务
} & $ IKuKey { # 实现接口
    UpdateEncryptService : (srv IEncryptService->) {
        _EncryptService = srv
    }

    [Get (T BaseModel)] : (match (T->bool) ->> @ r T) {
        <<- _DataStoreService.GetAsync(match)
    }

    [Post (T BaseModel)] : (item T ->>) {
        << _DataStoreService.PostAsync(item)
    }

    [Put (T BaseModel)] : (match (T->bool), item T ->>) {
        << _DataStoreService.PutAsync(match, item)
    }

    [Delete (T BaseModel)] : (match (T->bool) ->>) {
        << _DataStoreService.DeleteAsync(match)
    }
}

#:DefaultDataStoreService
#:DefaultEncryptService