using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using KuKey.Models;
using KuKey.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace KuKey.Core
{
    public class DefaultKuKey : IKuKey
    {
        IDataStoreService DataStoreService;
        IEncryptService EncryptService;

        public DefaultKuKey(string databasePath, string masterPassword)
        {
            DataStoreService = new SQLiteDataStoreService(databasePath);
            EncryptService = new AESEncryptService(masterPassword);
        }

        public DefaultKuKey(IDataStoreService dataSrv, IEncryptService encryptSrv)
        {
            DataStoreService = dataSrv;
            EncryptService = encryptSrv;
        }

        public void UpdateEncryptService(IEncryptService srv)
        {
            EncryptService = srv;
        }

        public async Task UpdateEncryptData(IEncryptService srv)
        {
            var keys = new List<KeyModel>();
            var keyGroups = new List<KeyGroupModel>();
            await DataStoreService.QueryAsync(ctx =>
            {
                foreach (var item in ctx.Set<KeyModel>())
                {
                    var r = item.Decrypt(EncryptService);
                    if (r != null)
                    {
                        keys.Add(r);
                    }
                }
                foreach (var item in ctx.Set<KeyGroupModel>())
                {
                    var r = item.Decrypt(EncryptService);
                    if (r != null)
                    {
                        keyGroups.Add(r);
                    }
                }
            });
            await DataStoreService.SaveAsync(ctx =>
            {
                keys.ForEach(i => ctx.Update(i.Encrypt(srv)));
                keyGroups.ForEach(i => ctx.Update(i.Encrypt(srv)));
            });
            EncryptService = srv;
        }

        public async Task QueryAsync(Action<ICoreQueryContext> func)
        {
            await DataStoreService.QueryAsync(ctx =>
                func(new CoreQueryContext(ctx, EncryptService)));
        }

        public async Task SaveAsync(Action<ICoreSaveContext> func)
        {
            await DataStoreService.SaveAsync(ctx =>
                func(new CoreSaveContext(ctx, EncryptService)));
        }

        public async Task<string> Export()
        {
            var text = "";
            await QueryAsync(ctx =>
            {
                text = JsonConvert.SerializeObject(
                    new KuKeyFormat()
                    {
                        Key = ctx.Set<KeyModel>().ToList(),
                        KeyGroup = ctx.Set<KeyGroupModel>().ToList()
                    });
            });
            return text;
        }

        void Import<T>(ICoreSaveContext ctx, T item) where T : class, Model<T>
        {
            var data = ctx.Set<T>().FirstOrDefault(i => i.Id == item.Id);
            if (data?.UpdateAt < item.UpdateAt)
            {
                ctx.Update(item);
            }
            else
            {
                ctx.Create(item);
            }
        }

        public async Task Import(string text)
        {
            await SaveAsync(ctx =>
            {
                var source = JsonConvert.DeserializeObject<KuKeyFormat>(text);
                source.Key.ForEach(v => Import(ctx, v));
                source.KeyGroup.ForEach(v => Import(ctx, v));
            });
        }

        public async Task<string> FormatExport()
        {
            var text = "";
            await QueryAsync(ctx =>
            {
                var keys = new List<FormatKeyModel>();
                foreach (var item in ctx.Set<KeyModel>().ToList())
                {
                    var r = ctx.Decrypt(item);
                    if (r is not null)
                    {
                        keys.Add(new FormatKeyModel().FromKeyModel(r));
                    }
                }
                text = JsonConvert.SerializeObject(new OpenFormat { Key = keys });
            });
            return text;
        }

        public async Task FormatImport(string text)
        {
            await SaveAsync(ctx =>
            {
                var source = JsonConvert.DeserializeObject<OpenFormat>(text);
                source.Key.ForEach(v => ctx.Create(v.ToKeyModel()));
            });
        }

        public string GeneratePassword(int len, bool number, bool lower, bool upper, bool symbol)
        {
            return EncryptService.GeneratePassword(len, number, lower, upper, symbol);
        }
    }

    public class KuKeyFormat
    {
        public List<KeyModel> Key = new();

        public List<KeyGroupModel> KeyGroup = new();

        public int Version = 1;
    }

    public class OpenFormat
    {
        [JsonProperty("key")]
        public List<FormatKeyModel> Key = new();

        [JsonProperty("version")]
        public int Version = 1;
    }

    public class CoreQueryContext : ICoreQueryContext
    {
        readonly IQueryContext DataContext;
        readonly IEncryptService EncryptService;

        public CoreQueryContext(IQueryContext ctx, IEncryptService srv)
        {
            DataContext = ctx;
            EncryptService = srv;
        }

        public IQueryable<T> Set<T>() where T : class, Model<T>
        {
            return DataContext.Set<T>();
        }

        public T? Decrypt<T>(T item) where T : class, Model<T>
        {
            return item.Decrypt(EncryptService) as T;
        }
    }

    public class CoreSaveContext : ICoreSaveContext
    {
        readonly ISaveContext DataContext;
        readonly IEncryptService EncryptService;

        public CoreSaveContext(ISaveContext ctx, IEncryptService srv)
        {
            DataContext = ctx;
            EncryptService = srv;
        }

        public IQueryable<T> Set<T>() where T : class, Model<T>
        {
            return DataContext.Set<T>();
        }

        public T? Decrypt<T>(T item) where T : class, Model<T>
        {
            return item.Decrypt(EncryptService) as T;
        }

        public string Create<T>(T item) where T : class, Model<T>
        {
            item.Id = Guid.NewGuid().ToString();
            var time = (int)((DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds / 1000);
            item.CreateAt = time;
            item.UpdateAt = time;
            DataContext.Create(item.Encrypt(EncryptService));
            return item.Id;
        }

        public void Update<T>(T item) where T : class, Model<T>
        {
            var time = (int)((DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds / 1000);
            item.UpdateAt = time;
            DataContext.Update(item.Encrypt(EncryptService));
        }

        public void Delete<T>(T item) where T : class, Model<T>
        {
            DataContext.Delete(item);
        }
    }
}
