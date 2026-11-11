param(
    [Parameter(Mandatory=$true)][string]$ComPort,
    [string]$ListenAddress = '0.0.0.0',
    [ValidateRange(1,65535)][int]$Port = 5001,
    [ValidateRange(1,4000000)][int]$BaudRate = 115200
)

$ErrorActionPreference = 'Stop'
try { Add-Type -AssemblyName System.IO.Ports } catch { }
$address = [System.Net.IPAddress]::Parse($ListenAddress)
$listener = [System.Net.Sockets.TcpListener]::new($address, $Port)
$serial = [System.IO.Ports.SerialPort]::new($ComPort, $BaudRate, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$serial.ReadTimeout = 200
$serial.Handshake = [System.IO.Ports.Handshake]::None

try {
    $serial.Open()
    $listener.Start()
    Write-Host "UART $ComPort ($BaudRate 8N1) -> TCP $ListenAddress`:$Port; Ctrl+C to stop."
    Write-Host 'Read-only forwarder: bytes received from TCP clients are not written to the COM port.'
    while ($true) {
        Write-Host 'Waiting for one TCP log client...'
        $client = $listener.AcceptTcpClient()
        $client.NoDelay = $true
        $stream = $client.GetStream()
        $buffer = New-Object byte[] 4096
        Write-Host "Client connected from $($client.Client.RemoteEndPoint)"
        try {
            while ($client.Connected) {
                if ($client.Client.Poll(0, [System.Net.Sockets.SelectMode]::SelectRead) -and $client.Available -eq 0) { break }
                try {
                    $count = $serial.Read($buffer, 0, $buffer.Length)
                    if ($count -gt 0) { $stream.Write($buffer, 0, $count); $stream.Flush() }
                } catch [System.TimeoutException] { }
            }
        } finally {
            $stream.Dispose()
            $client.Close()
            Write-Host 'TCP log client disconnected.'
        }
    }
} finally {
    if ($serial.IsOpen) { $serial.Close() }
    $serial.Dispose()
    $listener.Stop()
}
