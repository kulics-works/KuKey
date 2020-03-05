Kulics.KuKey.Core . {
    System

    Newtonsoft.Json
    
    Kulics.KuKey.Models
    Kulics.KuKey.Databases
    Kulics.KuKey.Services
}

# 主程序
KuKey : (databasePath str, masterPassword str->$) {     # 使用默认服务
    _DataStoreService = DefaultDataStoreService(databasePath)
    _EncryptService = DefaultEncryptService(masterPassword)
    _Init()
} & (dataSrv IDataStoreService, encryptSrv IEncryptService->$) {   # 使用自定义服务
    _DataStoreService = dataSrv
    _EncryptService = encryptSrv
    _Init()
} & $ {
    _DataStoreService IDataStoreService     # 存储服务
    _EncryptService IEncryptService         # 加密服务
    # 解密后的数据集，使用类型作为键，值为类型列表
    <get;set>
    _Dataset! : [Type]any{}
    # 初始化
    _Init : (->) {
        [_InitDataset KeyModel]()
    }
    [_InitDataset T] : (->) {
        _Dataset.add(typeof(T), []T{})
    }
} & $ IKuKey { # 实现接口
    UpdateEncryptService : (srv IEncryptService->) {
        _EncryptService = srv
        # 重置数据
        _Dataset = [Type]any{}
    }

    [Get (T BaseModel)] : (match (T->bool) ->> r []T) {
        ? ~_Dataset.has_key(typeof(T)) {
            _Dataset.add(typeof(T), []T{})
            @ v : << _DataStoreService.[GetAsync T]{i->true}.. {
                (_Dataset[typeof(T)] []T!).add(v.Decrypt(_EncryptService) T!)
            }
        }
        <- (_Dataset[typeof(T)] []T!).find_all(match).to_list()
    }

    [Post (T BaseModel)] : (item T ->>) {
        (_Dataset[typeof(T)] []T!).add(item)
        _DataStoreService.PostAsync(item.Encrypt(_EncryptService) T!)
    }

    [Put (T BaseModel)] : (match (T->bool), item T ->>) {
        dataset : _Dataset[typeof(T)] []T!
        ? dataset.exists(match) {
            dataset.update(match, item)
        } _ {
            dataset.add(item)
        }
        _DataStoreService.PutAsync(match, item.Encrypt(_EncryptService) T!)
    }

    [Delete (T BaseModel)] : (match (T->bool) ->>) {
        (_Dataset[typeof(T)] []T!).remove_all(match)
        _DataStoreService.DeleteAsync(match)
    }

    Export : (->>text str) {
        keys : << _DataStoreService.[GetAsync KeyModel]{i->true}
        <- JsonConvert.SerializeObject(keys)
    }

    Import : (text str->>) {
        keys : JsonConvert.[DeserializeObject []KeyModel](text)
        # 逐条导入数据
        @ v : keys.. {
            << _DataStoreService.PutAsync({i->i.Id==v.Id}, v)
        }
        # 重置数据
        _Dataset = [Type]any{}
    }
}

#:DefaultDataStoreService
#:DefaultEncryptService