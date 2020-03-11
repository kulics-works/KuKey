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
            @ v : << _DataStoreService.[QueryAllAsync T]{i->true}.. {
                (_Dataset[typeof(T)] []T!).add(v.Decrypt(_EncryptService) T!)
            }
        }
    }
    # 导入
    [_Import (T BaseModel)] : (item T ->>) {
        dataset : _Dataset[typeof(T)] []T!
        data : dataset.find_first{i->i.Id==item.Id}
        ? data >< nil {
            ? data.UpdateAt < item.UpdateAt {
                dataset.update({i->i.Id==item.Id}, item)
                << _DataStoreService.UpdateAsync(item.Encrypt(_EncryptService) T!)
            }
        } _ {
            dataset.add(item)
            << _DataStoreService.CreateAsync(item.Encrypt(_EncryptService) T!)
        }
    }
} & $ IKuKey { # 实现接口
    UpdateEncryptService : (srv IEncryptService->) {
        _EncryptService = srv
        # 重置数据
        _Dataset = [Type]any{}
    }

    [Create (T BaseModel)] : (item T ->>id str) {
        << [_CheckDataset T]()
        item.Id = Guid.NewGuid().ToString()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.CreateAt = time
        item.UpdateAt = time
        (_Dataset[typeof(T)] []T!).add(item)
        << _DataStoreService.CreateAsync(item.Encrypt(_EncryptService) T!)
        <- item.Id
    }

    [Update (T BaseModel)] : (item T ->>) {
        << [_CheckDataset T]()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.UpdateAt = time
        (_Dataset[typeof(T)] []T!).update({i->i.Id==item.Id}, item)
        << _DataStoreService.UpdateAsync(item.Encrypt(_EncryptService) T!)
    }

    [Delete (T BaseModel)] : (id str ->>) {
        << [_CheckDataset T]()
        (_Dataset[typeof(T)] []T!).remove_all{i->i.Id==id}
        << _DataStoreService.[DeleteAsync T](id)
    }

    [Query (T BaseModel)] : (id str ->> r ?T) {
        << [_CheckDataset T]()
        <- (_Dataset[typeof(T)] []T!).find_first{i->i.Id==id}
    }

    [QueryAll (T BaseModel)] : (match (T->bool) ->> @ r T) {
        << [_CheckDataset T]()
        <- (_Dataset[typeof(T)] []T!).find_all(match)
    }

    Export : (->>text str) {
        keys : (<< _DataStoreService.[QueryAllAsync KeyModel]{i->true}).to_list()
        deletes : @ v : << _DataStoreService.[QueryAllAsync DeleteRecordModel]{i->true}.. -> {
            v.Id
        }
        <- JsonConvert.SerializeObject(KuKeyFormat{
                Key = keys
                Delete = deletes
            })
    }

    Import : (text str->>) {
        source : JsonConvert.[DeserializeObject KuKeyFormat](text)
        # 逐条导入数据
        << [_CheckDataset KeyModel]()
        @ v : source.Key.. {
            << _Import(v)
        }
        # 逐条删除数据
        << [_CheckDataset DeleteRecordModel]()
        keys : _Dataset[typeof(KeyModel)] []KeyModel!
        @ v : source.Delete.. {
            ? keys.exists{i->i.Id==v} {
                << [Delete KeyModel](v)
            }
            << _Import(DeleteRecordModel(v))
        }
    }

    GeneratePassword : (lv PasswordLevel, len int->v str) {
        <- _EncryptService.GeneratePassword(lv, len)
    }
}

KuKeyFormat : $ {
    Key         []KeyModel
    Delete      []str
}

#:DefaultDataStoreService
#:DefaultEncryptService
#:DateTime
#:DeleteRecordModel