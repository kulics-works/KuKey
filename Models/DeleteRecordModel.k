Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}
# 记录已删除的条目
<Table("delete_record")>
DeleteRecordModel : BaseModel & $(me) {
    . Encrypt : (encryptor IEncryptService->v any) {
        <- me
    }
    . Decrypt : (encryptor IEncryptService->v any, b bool) {
        <- me, true
    }
} & (id str->$) {
    Id = id
}
