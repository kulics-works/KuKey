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

    . _ OnConfiguring : (optionsBuilder DbContextOptionsBuilder ->) {
        optionsBuilder.UseSqlite("Filename=${_DatabasePath}")
        #: optionsBuilder.EnableSensitiveDataLogging()
    }

    . _ OnModelCreating : (modelBuilder ModelBuilder ->) {
        #=
        # 查找程序集的model接口，全部加载进映射
        @ t : Assembly.GetAssembly([typeof Modeler]()).GetTypes() {
            ? t.IsClass {
                # 是否接口
                ? t.GetInterfaces().Contains([typeof Modeler]()) {
                    modelBuilder.Entity(t)
                }
            }
        }
        =#
        # "通过反射，自动装载所有基础模型的子类"
        @ t : Assembly.GetAssembly(typeof(BaseModel)).GetTypes() {
            # "是否子类"
            ? t.IsClass & t.IsSubclassOf(typeof(BaseModel))  {
                modelBuilder.Entity(t)
            }
        }
    }
}
