Kulics.KuKey.Services . {
    _ : Kulics.KuKey.Encryptor.Encryptor_static
}
# 加密服务
AESEncryptService : (password str->$) {
    _MasterPassword = password
} & IEncryptService & $ {
    # 主密码
    _MasterPassword str
    # 加密
    Encrypt : (v str -> v str) {
        ? v >< "" {
            v = AES256Encrypt(v, _MasterPassword)
        }
        <- v
    }
    # 解密
    Decrypt : (v str -> v str, b bool) {
        ? v >< "" {
            <- AES256Decrypt(v, _MasterPassword)
        }
        <- v, true
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
