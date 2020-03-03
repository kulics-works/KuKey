KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    KuKey.Models
    KuKey.Databases
}

DefaultStoreService : $ {
    <get;set>
    items! []T

    _SQLService! SQLiteDataStoreService

    check_items : (->>) {
        ? _items == nil {
            _items = []T{}
            ? DependencyService.[Get [IDataStore T]]() >< nil {
                @ v : << DependencyService.[Get [IDataStore T]]().GetItemsAsync(true).. {
                    _items.add(Models_static.decrypt_model(v))
                }
            }
        }
    }

    reload : (->>) {
        _items = []T{}
        ? DependencyService.[Get [IDataStore T]]() >< nil {
            @ v : << DependencyService.[Get [IDataStore T]]().GetItemsAsync(true).. {
                _items.add(Models_static.decrypt_model(v))
            }
        }
    }
} & $ IDataStoreService {
    [GetAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        << check_items()
        r : items.Where{i->match(i)}.ToList()
        <<- Task.FromResult(r)
    }

    [PostAsync (T BaseModel)] : (item T ->> r bool) {
        items.add(item)
        _SQLService.PostAsync(Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [PutAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        ? items.exists(match) {
            items.update(match, item)
        } _ {
            items.add(item)
        }
        _SQLService.PutAsync(Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->> r bool) {
        items.remove_all(match)
        _SQLService.DeleteAsync(match)
        <<- Task.FromResult(true)
    }
}
