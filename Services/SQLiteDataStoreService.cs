using System;
using System.Linq;
using KuKey.Models;
using KuKey.Databases;
using System.Threading.Tasks;

namespace KuKey.Services
{
    public class SQLiteDataStoreService : IDataStoreService
    {
        readonly string Path;

        public SQLiteDataStoreService(string path)
        {
            Path = path;
        }

        public Task QueryAsync(Action<IQueryContext> func)
        {
            using var ctx = new SQLiteContext(Path);
            func(new SQLiteDataContext(ctx));
            return Task.CompletedTask;
        }

        public Task SaveAsync(Action<ISaveContext> func)
        {
            using var ctx = new SQLiteContext(Path);
            func(new SQLiteDataContext(ctx));
            return ctx.SaveChangesAsync();
        }
    }

    public class SQLiteDataContext : IQueryContext, ISaveContext
    {
        readonly SQLiteContext Context;

        public SQLiteDataContext(SQLiteContext ctx)
        {
            Context = ctx;
        }

        public IQueryable<T> Set<T>() where T : class, Model<T>
        {
            return Context.Set<T>();
        }

        public void Create<T>(T item) where T : class, Model<T>
        {
            Context.Set<T>().Add(item);
        }

        public void Update<T>(T item) where T : class, Model<T>
        {
            Context.Set<T>().Update(item);
        }

        public void Delete<T>(T item) where T : class, Model<T>
        {
            Context.Set<T>().Remove(item);
        }
    }
}
