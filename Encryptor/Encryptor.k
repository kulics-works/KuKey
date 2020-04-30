<- Kulics.KuKey.Encryptor

-> {
    System
    System.Security.Cryptography
    System.Text
}

# "散列"
# "使用 SHA512，转成16进制输出"
SHA512Hash : (content str -> v str) {
    SHA512 : SHA512Managed{}
    HashContent : SHA512.ComputeHash(content.to_bytes())
    SHA512.Clear()
    <- HashContent.to_hex()
}

# "加密"
# "将key散列，拆成前后两部分用于AES256的key和iv，最后输出base64"
# "AES256，CBC模式，PKCS7填充"
AES256Encrypt : (content str, key str -> v str) {
    SHA512 : SHA512Managed{}
    HashKey : SHA512.ComputeHash(key.to_bytes())
    SHA512.Clear()

    KeyByte : HashKey.sub_bytes(0, 32)
    ValueByte : content.to_bytes()
    IVByte : HashKey.sub_bytes(32, 16)
    ! AES : RijndaelManaged{
        IV = IVByte
        Key = KeyByte
        Mode = CipherMode.CBC
        Padding = PaddingMode.PKCS7
    } {
        CryptoTransform : AES.CreateEncryptor()
        ResultArray : CryptoTransform.TransformFinalBlock(ValueByte, 0, ValueByte.Length)
        <- ResultArray.to_base64_str()
    }
}

# "解密"
# "将key散列，拆成前后两部分用于AES256的key和iv，最后输出base64"
# "AES256，CBC模式，PKCS7填充"
AES256Decrypt : (content str, key str -> v str, success bool) {
    SHA512 : SHA512Managed{}
    HashKey : SHA512.ComputeHash(key.to_bytes())
    SHA512.Clear()

    KeyByte : HashKey.sub_bytes(0, 32)
    ValueByte : content.to_bytes_by_base64()
    IVByte : HashKey.sub_bytes(32, 16)
    ! AES : RijndaelManaged{
        IV = IVByte
        Key = KeyByte
        Mode = CipherMode.CBC
        Padding = PaddingMode.PKCS7
    } {
        ! {
            CryptoTransform : AES.CreateDecryptor()
            ResultArray : CryptoTransform.TransformFinalBlock(ValueByte, 0, ValueByte.Length)
            <- ResultArray.to_str(), true
        } e {
            <- content, false
        }
    }
}

Number :  "23456789"
Lowercase : "abcdefghikjmnopqrstuvwxyz"
Uppercase : "ABCDEFGHJKLMNPQRSTUVWXYZ"
Symbol : "~!@#$%^&*()_-+={}:;<,>.?/\\"

# "生成密码"
GeneratePasswordByPool : (len int, pool str -> v str) {
    password! : ""
    rand : Random{}
    @ i : 0 .. len-1 {
        password += pool[rand.Next( pool.len() )]
    }
    <- password
}
