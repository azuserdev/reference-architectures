param (
    [Parameter(Mandatory=$true,
    ParameterSetName='P@$$w0rd!#')]
    [String]
    $replaceWithPassword,

    [Parameter(Mandatory=$true,
    ParameterSetName='segmentation')]
    [String[]]
    $rgname
)
#スクリプトが存在するフォルダへ移動
Set-Location $PSScriptRoot

#Azureへログイン
az login
$yousubscriptionid = az account list | ConvertFrom-Json 

$filePath=".\n-tier-windows.json"
#n-tier-windows.jsonに含まれる下記の文字列を指定したパスワードに変更
#[replace-with-password] 
#[replace-with-safe-mode-password]
#[replace-with-safe-password]
$string = Get-Content $filePath 
$replaced=$string | ForEach-Object {
    $_=$_.replace('[replace-with-password]',$replaceWithPassword) 
    $_=$_.replace('[replace-with-safe-mode-password]',$replaceWithPassword)
    $_=$_.replace('[replace-with-safe-password]',$replaceWithPassword)
    $_
}
$replaced | Set-Content ".\replaced-n-tier-windows.json"

azbb -s $yousubscriptionid.id -g $rgname -l "japaneast" -p replaced-n-tier-windows.json --deploy

$accountname=Get-AzStorageAccount | Where-Object{$_.StorageAccountName -like "sql*"} 
$key=Get-AzStorageAccountKey -Name $accountname.StorageAccountName -ResourceGroupName $rgname | Where-Object{$_.KeyName -eq "key1"}

$filePath=".\n-tier-windows-sqlao.json"
#n-tier-windows.jsonに含まれる下記の文字列を指定したパスワードに変更
#[replace-with-password] 
#[replace-with-sql-password]
#[replace-with-storageaccountname]
#[replace-with-storagekey]

$string = Get-Content $filePath 
$replaced=$string | ForEach-Object {
    $_=$_.replace('[replace-with-password]',$replaceWithPassword) 
    $_=$_.replace('[replace-with-sql-password]',$replaceWithPassword)
    $_=$_.replace('[replace-with-storageaccountname]',$accountname.StorageAccountName)
    $_=$_.replace('[replace-with-storagekey]',$key.Value)
    $_
}
$replaced | Set-Content ".\replaced-n-tier-windows-sqlao.json"

azbb -s $yousubscriptionid.id -g $rgname -l "japaneast" -p replaced-n-tier-windows-sqlao.json --deploy
