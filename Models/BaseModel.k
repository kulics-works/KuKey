Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}

BaseModel : $ (me) {
    # 主键
    <Key; Column("id"); DatabaseGenerated(DatabaseGeneratedOption.Identity); get; set>
    Id! str
    # 创建时间
    <Column("create_at"); get; set>
    CreateAt! DateTime
    # 最后修改时间
    <Column("update_at"); get; set>
    UpdateAt! DateTime
    # 加密模型
    Encrypt : (encryptor IEncryptService->v any) {
        <- me
    }
    # 解密模型
    Decrypt : (encryptor IEncryptService->v any) {
        <- me
    }
}
