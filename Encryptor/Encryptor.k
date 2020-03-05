Kulics.KuKey.Encryptor . {
    System
    System.Security.Cryptography
    System.Text
}

# 散列
# 使用 SHA512，转成16进制输出
SHA512Hash : (content str -> v str) {
    SHA512 : SHA512Managed{}
    HashContent : SHA512.ComputeHash(content.to_bytes())
    SHA512.Clear()
    <- HashContent.to_hex()
}

# 加密
# 将key散列，拆成前后两部分用于AES256的key和iv，最后输出base64
# AES256，CBC模式，PKCS7填充
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
    }
    CryptoTransform : AES.CreateEncryptor()
    ResultArray : CryptoTransform.TransformFinalBlock(ValueByte, 0, ValueByte.Length)
    <- ResultArray.to_str_by_base64()
}

# 解密
# 将key散列，拆成前后两部分用于AES256的key和iv，最后输出base64
# AES256，CBC模式，PKCS7填充
AES256Decrypt : (content str, key str -> v str) {
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
    }
    CryptoTransform : AES.CreateDecryptor()
    ResultArray : CryptoTransform.TransformFinalBlock(ValueByte, 0, ValueByte.Length)
    <- ResultArray.to_str()
}

# 生成数字密码
GeneratePasswordNum : (len int -> v str) {
    number : {"0"; "1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"}

    rand : Random{}
    password! : ""
    @ i : 0 ~ len-1.. {
        temp : number[rand.Next( number.len )]
        password += temp
    }
    <- password
}

# 生成普通密码
GeneratePasswordNormal : (len int -> v str) {
    number : {"2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"}
    lowercase : {"a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j"; "k"
            "m"; "n"; "p"; "q"; "r"; "s"; "t"; "u"; "v"; "w"
        "x"; "y"; "z"}

    rand : Random{}
    password! : ""
    @ i : 0 ~ len-1.. {
        temp! : ""
        ? rand.Next( 2 ).. 0 {
            temp = number[rand.Next( number.len )]
        } 1 {
            temp = lowercase[rand.Next( lowercase.len )]
        }
        password += temp
    }
    <- password
}

# 生成复杂密码
GeneratePasswordComplex : (len int -> v str) {
    number : {"2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"}
    lowercase : {"a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j"
            "m"; "n"; "p"; "q"; "r"; "s"; "t"; "u"; "v"; "w"
        "x"; "y"; "z"}
    uppercase : {"A"; "B"; "C"; "D"; "E"; "F"; "G"; "H"; "J"
        "L"; "M"; "N"; "P"; "Q"; "R"; "S"; "T"; "U"; "V"; "W"
        "X"; "Y"; "Z"}

    rand : Random{}
    password! : ""
    @ i : 0 ~ len-1.. {
        temp! : ""
        ? rand.Next( 3 ).. 0 {
            temp = number[rand.Next( number.len )]
        } 1 {
            temp = lowercase[rand.Next( lowercase.len )]
        } 2 {
            temp = uppercase[rand.Next( uppercase.len )]
        }
        password += temp
    }
    <- password
}

# 生成混合密码
GeneratePasswordMix : (len int -> v str) {
    number : {"2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"}
    lowercase : {"a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j"
            "m"; "n"; "p"; "q"; "r"; "s"; "t"; "u"; "v"; "w"
        "x"; "y"; "z"}
    uppercase : {"A"; "B"; "C"; "D"; "E"; "F"; "G"; "H"; "J"
        "L"; "M"; "N"; "P"; "Q"; "R"; "S"; "T"; "U"; "V"; "W"
        "X"; "Y"; "Z"}
    symbol : {"~"; "`"; "!"; "@"; "#"; "$"; "%"; "^"; "&"; "*"; "("
        ")"; "_"; "-"; "+"; "="; "{"; "}"; "["; "]"; ":"; ";"
        "<"; ","; ">"; "."; "?"; "/"; "\\"}

    rand : Random{}
    password! : ""
    @ i : 0 ~ len-1.. {
        temp! : ""
        ? rand.Next( 4 ).. 0 {
            temp = number[rand.Next( number.len )]
        } 1 {
            temp = lowercase[rand.Next( lowercase.len )]
        } 2 {
            temp = uppercase[rand.Next( uppercase.len )]
        } 3 {
            temp = symbol[rand.Next( symbol.len )]
        }
        password += temp
    }
    <- password
}
