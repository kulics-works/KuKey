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
} & IDataStoreService & $ {
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

    [CreateAsync (T BaseModel)] : (item T ->>) {
        [_GetDataset T]().add(item)
    }

    [UpdateAsync (T BaseModel)] : (item T ->>) {
        [_GetDataset T]().update({i->i.Id==item.Id}, item)
    }

    [DeleteAsync (T BaseModel)] : (id str ->>) {
        [_GetDataset T]().remove_all{i->i.Id==id}
    }

    [QueryAsync (T BaseModel)] : (id str ->> r ?T) {
        <- [_GetDataset T]().First{i->i.Id==id}
    }

    [QueryAllAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        <- [_GetDataset T]().Where(match)
    }
}
#:SQLiteContext
