KuKey . {
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

    [Create T] : (item T ->> r bool) {
        <<- _DataStoreService.AddItemAsync(item)
    }

    [Update T] : (item T ->> r bool) {
        <<- _DataStoreService.UpdateItemAsync(item)
    }

    [Update T] : (match (T->bool), item T ->> r bool) {
        <<- _DataStoreService.PutItemAsync(match, item)
    }

    [Retrieve T] : (match (T->bool) ->> r T) {
        <<- _DataStoreService.GetItemAsync(match)
    }

    [Retrieve T] : (forceRefresh bool ->> @ r T) {
        <<- _DataStoreService.GetItemsAsync()
    }

    [Delete T] : (match (T->bool) ->> r bool) {
        <<- _DataStoreService.DeleteItemAsync(item)
    }
}

#:SqliteContext