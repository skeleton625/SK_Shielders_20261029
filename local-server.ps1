$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://localhost:8000/')
$listener.Start()
Write-Host 'PLAYBOOK server: http://localhost:8000'
while ($listener.IsListening) {
  $context = $listener.GetContext()
  $path = $context.Request.Url.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrWhiteSpace($path)) { $path = 'index.html' }
  $file = Join-Path $root $path
  if (Test-Path -LiteralPath $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $context.Response.StatusCode = 200
    $context.Response.ContentType = switch ([IO.Path]::GetExtension($file)) { '.html' {'text/html; charset=utf-8'} '.css' {'text/css; charset=utf-8'} '.js' {'text/javascript; charset=utf-8'} default {'application/octet-stream'} }
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else { $context.Response.StatusCode = 404 }
  $context.Response.Close()
}
