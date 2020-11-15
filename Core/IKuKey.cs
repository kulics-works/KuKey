using System;
using System.Linq;
using System.Threading.Tasks;
using KuKey.Models;
using KuKey.Services;

namespace KuKey.Core
{
    public interface IKuKey
    {
        void UpdateEncryptService(IEncryptService srv);
        Task UpdateEncryptData(IEncryptService srv);
        Task QueryAsync(Action<ICoreQueryContext> func);
        Task SaveAsync(Action<ICoreSaveContext> func);
        Task<string> Export();
        Task Import(string text);
        Task<string> FormatExport();
        Task FormatImport(string text);
        string GeneratePassword(int len, bool number, bool lower, bool upper, bool symbol);
    }

    public interface ICoreQueryContext
    {
        T? Decrypt<T>(T item) where T : class, Model<T>;
        IQueryable<T> Set<T>() where T : class, Model<T>;
    }

    public interface ICoreSaveContext
    {
        T? Decrypt<T>(T item) where T : class, Model<T>;
        IQueryable<T> Set<T>() where T : class, Model<T>;
        string Create<T>(T item) where T : class, Model<T>;
        void Update<T>(T item) where T : class, Model<T>;
        void Delete<T>(T item) where T : class, Model<T>;
    }
}
