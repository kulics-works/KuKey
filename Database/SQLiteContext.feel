<- Kulics.KuKey.Databases

-> {
    System
    System.Collections.Generic
    System.Text
    System.Linq
    System.IO
    System.Reflection

    Microsoft.EntityFrameworkCore
    Microsoft.EntityFrameworkCore.Infrastructure
    Microsoft.Extensions.DependencyInjection
    Microsoft.Extensions.Logging

    Kulics.KuKey.Models
}
# "sqlite上下文"
# "必须由外部传入路径"
SQLiteContext : DbContext \/ (path str->$) {
    _DatabasePath = path
    Database.EnsureCreated()
    Database.Migrate()
} \/ $ {
    _DatabasePath str
    #get #set
    Key [DbSet KeyModel]
    #get #set
    Tag [DbSet TagModel]
    #get #set
    KeyMapTag [DbSet KeyMapTagModel]
    #get #set
    DeleteRecord [DbSet DeleteRecordModel]

    . _ OnConfiguring : (optionsBuilder DbContextOptionsBuilder ->) {
        optionsBuilder.UseSqlite("Filename=${_DatabasePath}")
        #: optionsBuilder.EnableSensitiveDataLogging()
    }

    . _ OnModelCreating : (modelBuilder ModelBuilder ->) {
    }
}
