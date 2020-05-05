<- Kulics.KuKey.Core

-> {
    System
    System.Linq

    Microsoft.EntityFrameworkCore

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

    UpdateEncryptData : (srv IEncryptService->>) {
        keys : []KeyModel{}
        _DataStoreService.QueryAsync~>{ ctx ->>
            @ key : ctx.[Set KeyModel]() {
                r, b : key.Decrypt(_EncryptService)
                ? b {
                    keys.add(r KeyModel!)
                }
            }
        }
        _DataStoreService.SaveAsync~>{ ctx ->> 
            @ key : keys {
                ctx.Update(key.Encrypt(srv) KeyModel!)
            }
        }
        _EncryptService = srv
    }

    QueryAsync : (func (ICoreQueryContext->>) ->>) {
        _DataStoreService.QueryAsync~>{ ctx -> 
            func~>(CoreQueryContext(ctx, _EncryptService))
        }
    }

    SaveAsync : (func (ICoreSaveContext->>) ->>) {
        _DataStoreService.SaveAsync~>{ ctx -> 
            func~>(CoreSaveContext(ctx, _EncryptService))
        }
    }

    Export : (->>text str) {
        text! : ""
        QueryAsync~>{ ctx ->
            keys : ctx.[Set KeyModel]().to_list()
            deletes : @ v : ctx.[Set DeleteRecordModel]().ToListAsync~>() -> {
                v.Id
            }
            text = JsonConvert.SerializeObject(KuKeyFormat{
                Key = keys
                Delete = deletes
            })
        }
        <- text
    }

    # "导入"
    [_Import (T BaseModel)] : (ctx ICoreSaveContext, item T ->) {
        data : ctx.[Set T]().FirstOrDefault{i->i.Id==item.Id}
        ? data >< nil {
            ? data.UpdateAt < item.UpdateAt {
                ctx.Update(item)
            }
        } _ {
            ctx.Create(item)
        }
    }

    Import : (text str->>) {
        SaveAsync~>{ ctx ->>
            source : JsonConvert.[DeserializeObject KuKeyFormat](text)
            # "逐条导入数据"
            @ v : source.Key {
                _Import(ctx, v)
            }
            # "逐条删除数据"
            @ v : source.Delete {
                ctx.[Delete KeyModel](v)
                _Import(ctx, DeleteRecordModel(v))
            }
        }
    }

    FormatExport : (->>text str) {
        text! : ""
        QueryAsync~>{ ctx ->
            keys : []FormatKeyModel{} 
            @ item : ctx.[Set KeyModel]().ToListAsync~>() {
                keys += FormatKeyModel{}.FromKeyModel(ctx.Decrypt(item).r)
            }
            text = JsonConvert.SerializeObject(OpenFormat{
                Key = keys
            })
        }
        <- text
    }

    FormatImport : (text str->>) {
        SaveAsync~>{ ctx ->>
            source : JsonConvert.[DeserializeObject OpenFormat](text)
            # "逐条导入数据"
            @ v : source.Key {
                ctx.Create(v.ToKeyModel())
            }
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

CoreQueryContext : ICoreQueryContext \/ $ {
    _DataContext IQueryContext
    _EncryptService IEncryptService 

    [Set (T BaseModel)] : (-> r [IQueryable T]) {
        <- _DataContext.[Set T]()
    }

    [Decrypt (T BaseModel)] : (item T->r T, b bool) {
        r, b : item.Decrypt(_EncryptService)
        <- r T!, b
    }
} \/ (ctx IQueryContext, srv IEncryptService->$) {
    _DataContext = ctx
    _EncryptService = srv
}

CoreSaveContext : ICoreSaveContext \/ $ {
    _DataContext ISaveContext
    _EncryptService IEncryptService

    [Set (T BaseModel)] : (-> r [IQueryable T]) {
        <- _DataContext.[Set T]()
    }

    [Decrypt (T BaseModel)] : (item T->r T, b bool) {
        r, b : item.Decrypt(_EncryptService)
        <- r T!, b
    }

    [Create (T BaseModel)] : (item T -> id str) {
        item.Id = Guid.NewGuid().ToString()
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.CreateAt = time
        item.UpdateAt = time
        _DataContext.Create(item.Encrypt(_EncryptService) T!)
        <- item.Id
    }

    [Update (T BaseModel)] : (item T ->) {
        time : (DateTime.UtcNow - DateTime(1970, 1, 1)).TotalMilliseconds / 1000 int!
        item.UpdateAt = time
        _DataContext.Update(item.Encrypt(_EncryptService) T!)
    }

    [Delete (T BaseModel)] : (id str ->) {
        _DataContext.[Delete T](id)
    }
} \/ (ctx ISaveContext, srv IEncryptService->$) {
    _DataContext = ctx
    _EncryptService = srv
}

##SQLiteDataStoreService
##AESEncryptService
##DateTime
##DeleteRecordModel
