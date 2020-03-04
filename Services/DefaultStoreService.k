KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    KuKey.Models
    KuKey.Databases
}
# 默认存储服务
DefaultStoreService : (path str->$) {
    _SQLService = SQLiteDataStoreService(path)
} & $ {
    <get;set>
    _Dataset! : [Type]any{} # 内存数据集，使用类型作为键，值为类型列表
    _SQLService SQLiteDataStoreService # 使用SQLite数据库服务作持久化存储
    # 检查内存中是否有数据集，如果无则去数据库中查找
    [CheckDataset (T BaseModel)] : (->>) {
        ? _Dataset[typeof(T)] == nil {
            dataset : _Dataset[typeof(T)] []T!
            dataset = []T{}
            @ v : << _SQLService.[GetAsync T]{i->true}.. {
                dataset.add(Models_static.decrypt_model(v))
            }
        }
    }
    # 获取某个数据集
    [GetDataset (T BaseModel)] : (->r []T) {
        <- _Dataset[typeof(T)] []T! 
    }
} & $ IDataStoreService {   # 实现数据服务接口
    [GetAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        << [CheckDataset T]()
        r : [GetDataset T]().Where{i->match(i)}.ToList()
        <<- Task.FromResult(r)
    }

    [PostAsync (T BaseModel)] : (item T ->> r bool) {
        [GetDataset T]().add(item)
        << _SQLService.[PostAsync T](Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [PutAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        dataset : [GetDataset T]()
        ? dataset.exists(match) {
            dataset.update(match, item)
        } _ {
            dataset.add(item)
        }
        << _SQLService.[PutAsync T](match, Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->> r bool) {
        [GetDataset T]().remove_all(match)
        << _SQLService.[DeleteAsync T](match)
        <<- Task.FromResult(true)
    }
}
#:SQLiteDataStoreService