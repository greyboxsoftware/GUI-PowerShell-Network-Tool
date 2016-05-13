[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$inputXML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="Auto" Width="Auto" SizeToContent="WidthAndHeight">

     <Grid>

        <Label x:Name="singlePingLabel" Content="Individual Computer" HorizontalAlignment="Left" HorizontalContentAlignment="Center" Margin="10,10,0,0" VerticalAlignment="Top" Width="347" MinWidth="347" VerticalContentAlignment="Center" Grid.IsSharedSizeScope="True"/>
        <TextBox x:Name="singleComputer" HorizontalAlignment="Left" Height="23" Margin="10,41,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="347" TextAlignment="Center" Grid.IsSharedSizeScope="True" HorizontalContentAlignment="Center" VerticalContentAlignment="Center"/>
        <Button x:Name="pingSingle" Content="Ping" HorizontalAlignment="Left" Margin="10,69,0,0" VerticalAlignment="Top" Width="60" Height="26" RenderTransformOrigin="-0.07,3.385" Grid.IsSharedSizeScope="True"/>
        <Label x:Name="outputLable" Content="Output" HorizontalContentAlignment="Center" HorizontalAlignment="Center" Margin="380,10,0,0" VerticalAlignment="Top" Width="Auto" MinWidth="370" Grid.ColumnSpan="2" Grid.IsSharedSizeScope="True" VerticalContentAlignment="Center"/>
        <TextBox x:Name="outputBox" HorizontalAlignment="Center" Margin="380,41,0,0" Grid.ColumnSpan="2" TextWrapping="Wrap" VerticalAlignment="Top" MinWidth="370" MinHeight="250" Width="Auto" Height="514" TextAlignment="Center" HorizontalContentAlignment="Center" Grid.IsSharedSizeScope="True"/>
        <Button x:Name="resolveIP" Content="Resolve IP" HorizontalAlignment="Left" Margin="75,69,0,0" VerticalAlignment="Top" Width="66" Height="26"/>
        <Button x:Name="resolveHostName" Content="Resolve Host Name" HorizontalAlignment="Left" Margin="146,69,0,0" VerticalAlignment="Top" Width="117" Height="26"/>
        <Button x:Name="portScan" Content="Port Scan" HorizontalAlignment="Left" Margin="268,69,0,0" VerticalAlignment="Top" Width="89" Height="26"/>

    </Grid>
</Window> 
'@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Actually make the objects work
#===========================================================================
 
function singlePingFunc ($computerName) {
    Try {
        $testingConnection = Test-Connection -ComputerName $computerName -Count 1 -Quiet
        if ($testingConnection -eq 'True') {
            $WPFoutputBox.Text = "$computerName is online`n"
        }
        else {
            $WPFoutputBox.Text = "$computerName is OFFLINE`n"
        }

    } Catch {
        $WPFoutputBox.Text = "$computerName error`n"
    }
}

function resolveIPaddress ($computerName) {
    Try {
        #$ipAddress = [System.Net.Dns]::GetHostAddresses($computerName)
        $ipAddress = Resolve-DnsName -Name $computerName -Type A
        $WPFoutputBox.Text = $ipAddress.IPAddress[0]
    } Catch {$WPFoutputBox = "$computer failed with error $_.ExceptionMessage"}
}

$WPFpingSingle.Add_Click({
$getComp = $WPFsingleComputer.Text 
singlePingFunc -computerName $getComp

})

$WPFresolveIP.Add_click({
    $getComp = $WPFsingleComputer.Text
    resolveIPaddress -computerName $getComp
})

 
#===========================================================================
# Shows the form
#===========================================================================
#write-host "To show the form, run the following" -ForegroundColor Cyan
$Form.ShowDialog() | out-null