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
} & $ {
    # 数据库存储服务
    _SQLService IDataStoreService
} & $ (me, super) {
    . [CreateAsync T] : (item T ->>) {
        << super.[CreateAsync T](item)
        << _SQLService.[CreateAsync T](item)
    }

    . [UpdateAsync T] : (item T ->>) {
        << super.[UpdateAsync T](item)
        << _SQLService.[UpdateAsync T](item)
    }

    . [DeleteAsync T] : (id str ->>) {
        << super.[DeleteAsync T](id)
        << _SQLService.[DeleteAsync T](id)
    }

    . [QueryAsync T] : (id str ->> r T) {
        # 检查内存中是否有数据集，如果无则去数据库中查找
        ? ~_Dataset.has_key(typeof(T)) {
            _Dataset.add(typeof(T), (<< _SQLService.[QueryAllAsync T]{i->true}).to_list())
        }
        <- << super.[QueryAsync T](id)
    }
    . [QueryAllAsync T] : (match (T->bool) ->> @ r T) {
        # 检查内存中是否有数据集，如果无则去数据库中查找
        ? ~_Dataset.has_key(typeof(T)) {
            _Dataset.add(typeof(T), (<< _SQLService.[QueryAllAsync T]{i->true}).to_list())
        }
        <<- super.[QueryAllAsync T](match)
    }
}
#:SQLiteDataStoreService