KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    KuKey.Models
    KuKey.Databases
}
# 内存 数据存储服务
MemoryDataStoreService : (->$) {
} & $ {
    # 内存数据集，使用类型作为键，值为类型列表
    <get;set>
    _Dataset! : [Type]any{}

    # 获取某个数据集
    [_GetDataset (T BaseModel)] : (->r []T) {
        <- _Dataset[typeof(T)] []T! 
    }
} & $ IDataStoreService(me) {
    [GetAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        <- [_GetDataset T]().Where{i->match(i)}.ToList()
    }

    [PostAsync (T BaseModel)] : (item T ->>) {
        [_GetDataset T]().add(item)
    }

    [PutAsync (T BaseModel)] : (match (T->bool), item T ->>) {
        dataset : [_GetDataset T]()
        ? dataset.exists(match) {
            dataset.update(match, item)
        } _ {
            dataset.add(item)
        }
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->>) {
        [_GetDataset T]().remove_all(match)
    }
}
#:SQLiteContext
