using System;
using System.Linq;
using System.Threading.Tasks;
using KuKey.Models;

namespace KuKey.Services
{
    public interface IDataStoreService
    {
        Task QueryAsync(Action<IQueryContext> func);
        Task SaveAsync(Action<ISaveContext> func);
    }

    public interface IQueryContext
    {
        IQueryable<T> Set<T>() where T : class, Model<T>;
    }

    public interface ISaveContext
    {
        IQueryable<T> Set<T>() where T : class, Model<T>;
        void Create<T>(T item) where T : class, Model<T>;
        void Update<T>(T item) where T : class, Model<T>;
        void Delete<T>(T item) where T : class, Model<T>;
    }
}
