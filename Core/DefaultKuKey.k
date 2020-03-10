Kulics.KuKey.Core . {
    System

    Newtonsoft.Json
    
    Kulics.KuKey.Models
    Kulics.KuKey.Databases
    Kulics.KuKey.Services
}

# 主程序
DefaultKuKey : (databasePath str, masterPassword str->$) {     # 使用默认服务
    _DataStoreService = DefaultDataStoreService(databasePath)
    _EncryptService = DefaultEncryptService(masterPassword)
} & (dataSrv IDataStoreService, encryptSrv IEncryptService->$) {   # 使用自定义服务
    _DataStoreService = dataSrv
    _EncryptService = encryptSrv
} & $ {
    _DataStoreService IDataStoreService     # 存储服务
    _EncryptService IEncryptService         # 加密服务
    # 解密后的数据集，使用类型作为键，值为类型列表
    <get;set>
    _Dataset! : [Type]any{}
    # 检查数据集
    [_CheckDataset (T BaseModel)] : (->>) {
        ? ~_Dataset.has_key(typeof(T)) {
            _Dataset.add(typeof(T), []T{})
            @ v : << _DataStoreService.[GetAsync T]{i->true}.. {
                (_Dataset[typeof(T)] []T!).add(v.Decrypt(_EncryptService) T!)
            }
        }
    }
} & $ IKuKey { # 实现接口
    UpdateEncryptService : (srv IEncryptService->) {
        _EncryptService = srv
        # 重置数据
        _Dataset = [Type]any{}
    }

    [Get (T BaseModel)] : (match (T->bool) ->> r []T) {
        << [_CheckDataset T]()
        <- (_Dataset[typeof(T)] []T!).find_all(match).to_list()
    }

    [Post (T BaseModel)] : (item T ->>id str) {
        << [_CheckDataset T]()
        item.Id = Guid.NewGuid().ToString()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.CreateAt = time
        item.UpdateAt = time
        (_Dataset[typeof(T)] []T!).add(item)
        << _DataStoreService.PostAsync(item.Encrypt(_EncryptService) T!)
        <- item.Id
    }

    [Put (T BaseModel)] : (item T ->>) {
        << [_CheckDataset T]()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.UpdateAt = time
        dataset : _Dataset[typeof(T)] []T!
        ? dataset.exists{i->i.Id==item.Id} {
            dataset.update({i->i.Id==item.Id}, item)
        } _ {
            item.CreateAt = time
            dataset.add(item)
        }
        << _DataStoreService.PutAsync(item.Encrypt(_EncryptService) T!)
    }

    [Delete (T BaseModel)] : (match (T->bool) ->>) {
        << [_CheckDataset T]()
        (_Dataset[typeof(T)] []T!).remove_all(match)
        << _DataStoreService.DeleteAsync(match)
    }

    Export : (->>text str) {
        keys : << _DataStoreService.[GetAsync KeyModel]{i->true}
        <- JsonConvert.SerializeObject(keys)
    }

    Import : (text str->>) {
        keys : JsonConvert.[DeserializeObject []KeyModel](text)
        # 逐条导入数据
        @ v : keys.. {
            << _DataStoreService.PutAsync(v)
        }
        # 重置数据
        _Dataset = [Type]any{}
    }

    GeneratePassword : (lv PasswordLevel, len int->v str) {
        <- _EncryptService.GeneratePassword(lv, len)
    }
}

#:DefaultDataStoreService
#:DefaultEncryptService
#:DateTime