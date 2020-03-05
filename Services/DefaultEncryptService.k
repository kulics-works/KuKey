Kulics.KuKey.Services . {
    _ : Kulics.KuKey.Encryptor.Encryptor_static
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
        <- AES256Encrypt(v, _MasterPassword)
    }
    # 解密
    Decrypt : (v str -> v str) {
        <- AES256Decrypt(v, _MasterPassword)
    }
    # 生成密码
    GeneratePassword : (lv PasswordLevel, len int->v str) {
        <- ? lv.. -> PasswordLevel.Number {
            GeneratePasswordNum(len)
        } PasswordLevel.Normal {
            GeneratePasswordNormal(len)
        } PasswordLevel.Complex {
            GeneratePasswordComplex(len)
        } PasswordLevel.Mix {
            GeneratePasswordMix(len)
        } _ {
            ""
        }
    }
}
