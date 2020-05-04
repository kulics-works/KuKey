<- Kulics.KuKey.Core

-> {
    System
    System.Linq

    Newtonsoft.Json
    
    Kulics.KuKey.Models
    Kulics.KuKey.Databases
    Kulics.KuKey.Services
}

# "主程序"
DefaultKuKey : IKuKey \/ (databasePath str, masterPassword str->$) {     #: 使用默认服务
    _DataStoreService = SQLiteDataStoreService(databasePath)
    _EncryptService = AESEncryptService(masterPassword)
} \/ (dataSrv IDataStoreService, encryptSrv IEncryptService->$) {   #: 使用自定义服务
    _DataStoreService = dataSrv
    _EncryptService = encryptSrv
} \/ $ me {
    # "存储服务"
    _DataStoreService IDataStoreService     
    # "加密服务"
    _EncryptService IEncryptService         
    # "实现接口"
    UpdateEncryptService : (srv IEncryptService->) {
        _EncryptService = srv
    }

    [Create (T BaseModel)] : (item T ->>id str) {
        item.Id = Guid.NewGuid().ToString()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.CreateAt = time
        item.UpdateAt = time
        _DataStoreService.CreateAsync~>(item.Encrypt(_EncryptService) T!)
        <- item.Id
    }

    [Update (T BaseModel)] : (item T ->>) {
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.UpdateAt = time
        _DataStoreService.UpdateAsync~>(item.Encrypt(_EncryptService) T!)
    }

    [Delete (T BaseModel)] : (id str ->>) {
        _DataStoreService.[DeleteAsync T]~>(id)
    }

    [Query (T BaseModel)] : (id str ->> r ?T) {
        item : _DataStoreService.[QueryAsync T]~>(id)
        ? item >< nil {
            decryptitem, success : Decrypt(item)
            ? success {
                <- decryptitem
            }
        }
        <- nil
    }

    [LINQ T] : (query (ICoreContext->T) -> r T) {
        <- _DataStoreService.LINQ{ ctx ->
            <- query(LinqContext(ctx, _EncryptService))
        }
    }

    [Decrypt (T BaseModel)] : (item T->r T, b bool) {
        r, b : item.Decrypt(_EncryptService)
        <- r T!, b
    }

    Export : (->>text str) {
        <<- _DataStoreService.LINQ{ ctx -> 
            keys : ctx.[Set KeyModel]().to_list()
            deletes : @ v : ctx.[Set DeleteRecordModel]() -> {
                v.Id
            }
            <- JsonConvert.SerializeObject(KuKeyFormat{
                Key = keys
                Delete = deletes
            })
        }
    }

    # "导入"
    [_Import (T BaseModel)] : (item T ->>) {
        data : _DataStoreService.[QueryAsync T]~>(item.Id)
        ? data >< nil {
            ? data.UpdateAt < item.UpdateAt {
                _DataStoreService.UpdateAsync~>(item)
            }
        } _ {
            _DataStoreService.CreateAsync~>(item)
        }
    }

    Import : (text str->>) {
        source : JsonConvert.[DeserializeObject KuKeyFormat](text)
        # "逐条导入数据"
        @ v : source.Key {
            _Import~>(v)
        }
        # "逐条删除数据"
        @ v : source.Delete {
            _DataStoreService.[DeleteAsync KeyModel]~>(v)
            _Import~>(DeleteRecordModel(v))
        }
    }

    FormatExport : (->>text str) {
        <<- LINQ{ctx ->
            keys : @ item : ctx.[Set KeyModel]() -> {
                FormatKeyModel{}.FromKeyModel(ctx.Decrypt(item).r)
            }
            <- JsonConvert.SerializeObject(OpenFormat{
                Key = keys
            })
        }
    }

    [_FormatImport (T BaseModel)] : (item T ->>) {
        item.Id = Guid.NewGuid().ToString()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.CreateAt = time
        item.UpdateAt = time
        _DataStoreService.CreateAsync~>(item.Encrypt(_EncryptService) T!)
    }

    FormatImport : (text str->>) {
        source : JsonConvert.[DeserializeObject OpenFormat](text)
        # "逐条导入数据"
        @ v : source.Key {
            _FormatImport~>(v.ToKeyModel())
        }
    }

    GeneratePassword : (len int, number bool, lower bool, upper bool, symbol bool->v str) {
        <- _EncryptService.GeneratePassword(len, number, lower, upper, symbol)
    }
}

KuKeyFormat : $ {
    Key         []KeyModel
    Delete      []str
    Version : 1
}

OpenFormat : $ {
    #JsonProperty("key")
    Key []FormatKeyModel
    #JsonProperty("version")
    Version : 1
}

LinqContext : ICoreContext \/ $ {
    _DataContext IDataContext
    _EncryptService IEncryptService 

    [Set (T BaseModel)] : (-> r [IQueryable T]) {
        <- _DataContext.[Set T]()
    }

    [Decrypt (T BaseModel)] : (item T->r T, b bool) {
        r, b : item.Decrypt(_EncryptService)
        <- r T!, b
    }
} \/ (ctx IDataContext, srv IEncryptService->$) {
    _DataContext = ctx
    _EncryptService = srv
}

##SQLiteDataStoreService
##AESEncryptService
##DateTime
##DeleteRecordModel
