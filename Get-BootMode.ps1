<#
    Author: Cole Lavallee
    Filename: Get-BootMode.ps1
    Date: 03.03.2019
    Description: Used to get the boot mode (EFI vs BIOS) for machines via WinRM.
#>

$OUs = Get-Content "OUs.txt"
$Creds  = (Get-Credential)
$Results = "$env:USERPROFILE\Desktop\BootModeResults_$(Get-Date -f yyyyddMM).csv"
$Computers = @()
Write-Host "Running...." -ForegroundColor Yellow
foreach ($OU in $OUs){
    Get-ADComputer -Filter * -SearchBase $OU | foreach  {
if (Test-WSMan -ComputerName $_.Name -ErrorAction SilentlyContinue ){
    try {
        $BootMode = Invoke-Command -ComputerName $_.Name -Credential $Creds -ScriptBlock {
            ((Select-String 'Detected boot environment' C:\Windows\Panther\setupact.log -AllMatches ).line -replace '.*:\s+')
        }}
        catch {
            $BootMode = "Could not connect over to setupact.log over WinRM."
        }
}
else {
    $BootMode = "System unreachable via WinRM."
    }
$props = @{
     Name = $_.Name
     BootMode = $BootMode
    }
$Computer = New-Object -TypeName PSObject -Property $props
$Computers += $Computer
}}
Write-Host "Completed!" -ForegroundColor Green
Write-Host "File can be found at: $Results" -ForegroundColor Green
$Computers | Export-Csv $Results -NoTypeInformation
