Kulics.KuKey.Models . {
    System
    System.ComponentModel.DataAnnotations
    System.ComponentModel.DataAnnotations.Schema

    Kulics.KuKey.Services
}
# 记录已删除的条目
<Table("safe_question")>
PasswordPromptModel : BaseModel & $ me {
    <Column("content"); get; set>
    Content! : ""

    . Encrypt : (encryptor IEncryptService->v any) {
        <- me
    }
    . Decrypt : (encryptor IEncryptService->v any, b bool) {
        <- me, true
    }
}
