KuKey . {
    System
    
    KuKey.Models
    KuKey.Databases
    KuKey.Services
}

# 主程序
KuKey : (databasePath str, masterPassword str->$) {     # 使用默认存储服务
    _DataStoreService = DefaultStoreService(databasePath)
    _EncryptService.MasterPassword = masterPassword
} & (dataStoreService IDataStoreService, masterPassword str->$) {   # 使用自定义存储服务
    _DataStoreService = dataStoreService
    _EncryptService.MasterPassword = masterPassword
} & $ { # 内部属性
    _DataStoreService IDataStoreService   # 存储服务
    _EncryptService : EncryptService{}  # 加密服务

} & $ { # 暴露接口
    UpdateMasterPassword : (v str->) {
        _EncryptService.MasterPassword = v
    }

    [Get (T BaseModel)] : (match (T->bool) ->> @ r T) {
        <<- _DataStoreService.GetAsync(match)
    }

    [Post (T BaseModel)] : (item T ->> r bool) {
        <<- _DataStoreService.PostAsync(item)
    }

    [Put (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        <<- _DataStoreService.PutAsync(match, item)
    }

    [Delete (T BaseModel)] : (match (T->bool) ->> r bool) {
        <<- _DataStoreService.DeleteAsync(item)
    }
}

#:DefaultStoreService