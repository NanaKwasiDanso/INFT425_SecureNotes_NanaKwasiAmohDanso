Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap(512,512)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush([System.Drawing.Rectangle]::new(0,0,512,512), [System.Drawing.Color]::FromArgb(255,58,123,213), [System.Drawing.Color]::FromArgb(255,0,210,255), [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
$g.FillRectangle($brush,[System.Drawing.Rectangle]::new(0,0,512,512))
$font = New-Object System.Drawing.Font('Segoe UI',220,[System.Drawing.FontStyle]::Bold)
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString('S',$font,[System.Drawing.Brushes]::White,[System.Drawing.RectangleF]::new(0,0,512,512),$format)
$bmp.Save('assets/new_icon.png',[System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output 'CREATED asset/new_icon.png'
