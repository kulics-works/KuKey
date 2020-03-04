Kulics.KuKey.Services . {
    Kulics.KuKey.Encryptor
}
# 加密服务
DefaultEncryptService : (password str->$) {
    _MasterPassword = password
} & $ {
    # 主密码
    _MasterPassword str
} & $ IEncryptService {
    # 加密
    Encrypt : (v str -> v str) {
        <- Encryptor_static.Encrypt(v, _MasterPassword)
    }
    # 解密
    Decrypt : (v str -> v str) {
        <- Encryptor_static.Decrypt(v, _MasterPassword)
    }
}
