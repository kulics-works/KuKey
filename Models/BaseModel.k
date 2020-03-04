Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}

BaseModel : $ (me) {
    # 主键
    <Key; Column("id"); DatabaseGenerated(DatabaseGeneratedOption.Identity); get; set>
    Id! ?str
    # 加密模型
    Encrypt : (encryptor IEncryptService->v any) {
        <- me
    }
    # 解密模型
    Decrypt : (encryptor IEncryptService->v any) {
        <- me
    }
}
