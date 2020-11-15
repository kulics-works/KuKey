using Microsoft.EntityFrameworkCore;
using KuKey.Models;

namespace KuKey.Databases
{
    public class SQLiteContext : DbContext
    {
        readonly string DatabasePath;
        public DbSet<KeyModel> Key { get; set; }
        public DbSet<KeyGroupModel> KeyGroup { get; set; }

        public SQLiteContext(string path)
        {
            DatabasePath = path;
            Database.EnsureCreated();
            Database.Migrate();
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlite($"Filename={DatabasePath}");
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
        }
    }
}
