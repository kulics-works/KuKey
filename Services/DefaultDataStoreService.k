Kulics.KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    Kulics.KuKey.Models
    Kulics.KuKey.Databases
}
# 默认存储服务
DefaultDataStoreService : MemoryDataStoreService & (path str->$) {
    # 使用SQLite数据库服务作持久化存储
    _SQLService = SQLiteDataStoreService(path)
} & $ (me, super) {
    # 数据库存储服务
    _SQLService IDataStoreService
    
    . [GetAsync T] : (match (T->bool) ->> r []T) {
        # 检查内存中是否有数据集，如果无则去数据库中查找
        ? _Dataset[typeof(T)] == nil {
            dataset : _Dataset[typeof(T)] []T!
            dataset = []T{}
            @ v : << _SQLService.[GetAsync T]{i->true}.. {
                dataset.add(v)
            }
        }
        <<- super.[GetAsync T](match)
    }

    . [PostAsync T] : (item T ->>) {
        << super.[PostAsync T](item)
        _SQLService.[PostAsync T](item)
    }

    . [PutAsync T] : (match (T->bool), item T ->>) {
        << super.[PutAsync T](match, item)
        _SQLService.[PutAsync T](match, item)
    }

    . [DeleteAsync T] : (match (T->bool) ->>) {
        << super.[DeleteAsync T](match)
        _SQLService.[DeleteAsync T](match)
    }
}
#:SQLiteDataStoreService