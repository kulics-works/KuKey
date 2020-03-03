KuKey.Services . {
    System
    System.Collections.Generic
    System.Linq
    System.Threading.Tasks

    KuKey.Models
    KuKey.Databases
}

DefaultStoreService : $ (me) {
    <get,set>
    items! []T

    check_items : (->>) {
        ? me._items == nil {
            me._items = []T{}
            ? DependencyService.[Get [IDataStore T]]() >< nil {
                @ v : << DependencyService.[Get [IDataStore T]]().GetItemsAsync(true).. {
                    me._items.add(Models_static.decrypt_model(v))
                }
            }
        }
    }

    [CreateAsync (T BaseModel)] : (item T ->> r bool) {
        me.items.add(item)
        DependencyService.[Get [IDataStore T]]()?.AddItemAsync(Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [UpdateAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        me.items.update(match, item)
        DependencyService.[Get [IDataStore T]]()?.UpdateItemAsync(Models_static.encrypt_model(item))
        <<- Task.FromResult(true)
    }

    [UpdateAsync (T BaseModel)] : (match (T->bool), item T ->> r bool) {
        ? me.items.exists(match) {
            << me.UpdateItemAsync(match, item)
        } _ {
            << me.AddItemAsync(item)
        }
        <<- Task.FromResult(true)
    }

    [RetrieveAsync (T BaseModel)] : (match (T->bool) ->> r T) {
        << check_items()
        r : me.items.FirstOrDefault(match)
        <<- Task.FromResult(r)
    }

    [RetrieveAsync (T BaseModel)] : (forceRefresh bool ->> @ r T) {
        << check_items()
        r : (@ it : me.items.. -> select it).ToList()
        <<- Task.FromResult(r)
    }

    [RetrieveAsync (T BaseModel)] : (match (T->bool) ->> @ r T) {
        << check_items()
        r : (@ it : me.items.. -> where match(it) -> select it).ToList()
        <<- Task.FromResult(r)
    }

    [DeleteAsync (T BaseModel)] : (match (T->bool) ->> r bool) {
        me.items.remove_all(match)
        DependencyService.[Get [IDataStore T]]()?.DeleteItemAsync(match)
        <<- Task.FromResult(true)
    }

    reload : (->>) {
        me._items = []T{}
        ? DependencyService.[Get [IDataStore T]]() >< nil {
            @ v : << DependencyService.[Get [IDataStore T]]().GetItemsAsync(true).. {
                me._items.add(Models_static.decrypt_model(v))
            }
        }
    }
}
