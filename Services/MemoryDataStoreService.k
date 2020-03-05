Kulics.KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    Kulics.KuKey.Models
    Kulics.KuKey.Databases
}
# 内存 数据存储服务
MemoryDataStoreService : (->$) {
} & $ {
    # 内存数据集，使用类型作为键，值为类型列表
    <get;set>
    _Dataset! : [Type]any{}

    # 获取某个数据集
    [_GetDataset (T BaseModel)] : (->r []T) {
        ? ~_Dataset.has_key(typeof(T)) {
            _Dataset.add(typeof(T), []T{})
        }
        <- _Dataset[typeof(T)] []T! 
    }
} & $ IDataStoreService {
    [GetAsync (T BaseModel)] : (match (T->bool) ->> r []T) {
        <- [_GetDataset T]().Where(match).to_list()
    }

    [PostAsync (T BaseModel)] : (item T ->>) {
        [_GetDataset T]().add(item)
    }

    [PutAsync (T BaseModel)] : (item T ->>) {
        dataset : [_GetDataset T]()
        ? dataset.exists{i->i.Id==item.Id} {
            dataset.update({i->i.Id==item.Id}, item)
        } _ {
            dataset.add(item)
        }
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->>) {
        [_GetDataset T]().remove_all(match)
    }
}
#:SQLiteContext
