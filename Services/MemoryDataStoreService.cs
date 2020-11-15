using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using KuKey.Models;

namespace KuKey.Services
{
    public class MemoryDataStoreService : IDataStoreService, IQueryContext, ISaveContext
    {
        readonly Dictionary<Type, object> Dataset = new();

        List<T> GetDataset<T>() where T : Model<T>
        {
            if (Dataset.ContainsKey(typeof(T)) is false)
            {
                Dataset.Add(typeof(T), new());
            }
            return (List<T>)Dataset[typeof(T)];
        }

        public Task QueryAsync(Action<IQueryContext> func)
        {
            func(this);
            return Task.CompletedTask;
        }

        public Task SaveAsync(Action<ISaveContext> func)
        {
            func(this);
            return Task.CompletedTask;
        }

        public IQueryable<T> Set<T>() where T : class, Model<T>
        {
            return GetDataset<T>().AsQueryable();
        }

        public void Create<T>(T item) where T : class, Model<T>
        {
            GetDataset<T>().Add(item);
        }

        public void Update<T>(T item) where T : class, Model<T>
        {
            var i = GetDataset<T>().First(i => i.Id == item.Id);
            GetDataset<T>().Remove(i);
            GetDataset<T>().Add(item);
        }

        public void Delete<T>(T item) where T : class, Model<T>
        {
            GetDataset<T>().RemoveAll(i => i.Id == item.Id);
        }
    }
}
