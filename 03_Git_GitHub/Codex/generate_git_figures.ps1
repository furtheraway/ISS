Add-Type -AssemblyName System.Drawing

$OutDir = Split-Path -Parent $PSCommandPath

function Convert-ToColor {
    param([string]$Hex)
    [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function New-SolidBrush {
    param([string]$Hex)
    [System.Drawing.SolidBrush]::new((Convert-ToColor $Hex))
}

function New-DrawingPen {
    param(
        [string]$Hex,
        [float]$Width
    )
    $pen = [System.Drawing.Pen]::new((Convert-ToColor $Hex), $Width)
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen
}

function New-DrawingFont {
    param(
        [string]$Family,
        [float]$Size,
        [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular
    )
    [System.Drawing.Font]::new($Family, $Size, $Style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-RectF {
    param(
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H
    )
    [System.Drawing.RectangleF]::new($X, $Y, $W, $H)
}

function New-RoundedPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [float]$Radius
    )
    $diameter = $Radius * 2
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $W - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $W - $diameter, $Y + $H - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $H - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    $path
}

function Draw-RoundedRect {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [float]$Radius,
        [string]$Fill,
        [string]$Stroke,
        [float]$StrokeWidth = 3
    )
    $path = New-RoundedPath $X $Y $W $H $Radius
    $brush = New-SolidBrush $Fill
    $pen = New-DrawingPen $Stroke $StrokeWidth
    $G.FillPath($brush, $path)
    $G.DrawPath($pen, $path)
    $brush.Dispose()
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Text {
    param(
        [System.Drawing.Graphics]$G,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [string]$Color,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [string]$Align = "Near",
        [string]$LineAlign = "Near"
    )
    $brush = New-SolidBrush $Color
    $format = [System.Drawing.StringFormat]::new()
    $format.Trimming = [System.Drawing.StringTrimming]::Word
    $format.FormatFlags = [System.Drawing.StringFormatFlags]::LineLimit

    switch ($Align) {
        "Center" { $format.Alignment = [System.Drawing.StringAlignment]::Center }
        "Far" { $format.Alignment = [System.Drawing.StringAlignment]::Far }
        default { $format.Alignment = [System.Drawing.StringAlignment]::Near }
    }

    switch ($LineAlign) {
        "Center" { $format.LineAlignment = [System.Drawing.StringAlignment]::Center }
        "Far" { $format.LineAlignment = [System.Drawing.StringAlignment]::Far }
        default { $format.LineAlignment = [System.Drawing.StringAlignment]::Near }
    }

    $G.DrawString($Text, $Font, $brush, (New-RectF $X $Y $W $H), $format)
    $format.Dispose()
    $brush.Dispose()
}

function Draw-Arrow {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X1,
        [float]$Y1,
        [float]$X2,
        [float]$Y2,
        [string]$Color,
        [float]$Width = 7,
        [bool]$Dashed = $false,
        [bool]$DoubleHead = $false
    )
    $pen = New-DrawingPen $Color $Width
    if ($Dashed) {
        $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    }
    $endCap = [System.Drawing.Drawing2D.AdjustableArrowCap]::new(5, 7, $true)
    $pen.CustomEndCap = $endCap
    if ($DoubleHead) {
        $startCap = [System.Drawing.Drawing2D.AdjustableArrowCap]::new(5, 7, $true)
        $pen.CustomStartCap = $startCap
    }
    $G.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-Pill {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [string]$Command,
        [string]$Note,
        [string]$Accent
    )
    $commandFont = $script:FontCode
    if ($Command.Length -gt 15) {
        $commandFont = $script:FontCodeSmall
    }
    Draw-RoundedRect $G $X $Y $W $H 18 "#FFFFFF" $Accent 3
    Draw-Text $G $Command $commandFont "#111827" ($X + 18) ($Y + 16) ($W - 36) 34 "Center" "Center"
    if ($Note) {
        Draw-Text $G $Note $script:FontTiny "#475569" ($X + 22) ($Y + 53) ($W - 44) 40 "Center" "Center"
    }
}

function Draw-StateCard {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [string]$Title,
        [string]$Subtitle,
        [string[]]$Bullets,
        [string]$Accent,
        [string]$Fill
    )
    Draw-RoundedRect $G $X $Y $W $H 30 "#FFFFFF" "#CBD5E1" 3
    Draw-RoundedRect $G ($X + 28) ($Y + 28) 92 92 22 $Fill $Accent 3

    $iconPen = New-DrawingPen $Accent 7
    if ($Title -eq "Workspace") {
        $G.DrawLine($iconPen, $X + 52, $Y + 92, $X + 96, $Y + 48)
        $G.DrawLine($iconPen, $X + 61, $Y + 101, $X + 106, $Y + 57)
        $G.DrawLine($iconPen, $X + 48, $Y + 104, $X + 71, $Y + 98)
    }
    elseif ($Title -eq "Index") {
        $G.DrawRectangle($iconPen, $X + 52, $Y + 52, 44, 50)
        $G.DrawLine($iconPen, $X + 62, $Y + 66, $X + 86, $Y + 66)
        $G.DrawLine($iconPen, $X + 62, $Y + 80, $X + 86, $Y + 80)
        $G.DrawLine($iconPen, $X + 62, $Y + 94, $X + 80, $Y + 94)
    }
    else {
        $G.DrawLine($iconPen, $X + 50, $Y + 92, $X + 98, $Y + 54)
        $G.DrawLine($iconPen, $X + 98, $Y + 54, $X + 116, $Y + 84)
        $G.DrawEllipse($iconPen, $X + 44, $Y + 86, 18, 18)
        $G.DrawEllipse($iconPen, $X + 91, $Y + 47, 18, 18)
        $G.DrawEllipse($iconPen, $X + 108, $Y + 77, 18, 18)
    }
    $iconPen.Dispose()

    Draw-Text $G $Title $script:FontCardTitle "#0F172A" ($X + 145) ($Y + 28) ($W - 180) 48
    Draw-Text $G $Subtitle $script:FontSub "#475569" ($X + 145) ($Y + 82) ($W - 180) 52

    $bulletY = $Y + 175
    foreach ($bullet in $Bullets) {
        $dotBrush = New-SolidBrush $Accent
        $G.FillEllipse($dotBrush, $X + 48, $bulletY + 11, 13, 13)
        $dotBrush.Dispose()
        Draw-Text $G $bullet $script:FontBody "#1F2937" ($X + 82) $bulletY ($W - 125) 58
        $bulletY += 76
    }
}

function Draw-Panel {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [string]$Title,
        [string]$Subtitle,
        [string]$Fill,
        [string]$Stroke
    )
    Draw-RoundedRect $G $X $Y $W $H 34 $Fill $Stroke 4
    Draw-Text $G $Title $script:FontPanelTitle "#0F172A" ($X + 44) ($Y + 32) ($W - 88) 50
    Draw-Text $G $Subtitle $script:FontBody "#475569" ($X + 44) ($Y + 86) ($W - 88) 52
}

function Draw-MiniBox {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [string]$Title,
        [string]$Text,
        [string]$Accent,
        [string]$Fill = "#FFFFFF"
    )
    Draw-RoundedRect $G $X $Y $W $H 24 $Fill $Accent 3
    Draw-Text $G $Title $script:FontMiniTitle "#111827" ($X + 28) ($Y + 24) ($W - 56) 38
    Draw-Text $G $Text $script:FontBody "#334155" ($X + 28) ($Y + 72) ($W - 56) ($H - 96)
}

function New-Canvas {
    param(
        [int]$Width,
        [int]$Height,
        [string]$Background
    )
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bitmap.SetResolution(144, 144)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $graphics.Clear((Convert-ToColor $Background))
    @{ Bitmap = $bitmap; Graphics = $graphics }
}

$script:FontTitle = New-DrawingFont "Segoe UI" 58 ([System.Drawing.FontStyle]::Bold)
$script:FontSubtitle = New-DrawingFont "Segoe UI" 28 ([System.Drawing.FontStyle]::Regular)
$script:FontCardTitle = New-DrawingFont "Segoe UI" 42 ([System.Drawing.FontStyle]::Bold)
$script:FontPanelTitle = New-DrawingFont "Segoe UI" 40 ([System.Drawing.FontStyle]::Bold)
$script:FontMiniTitle = New-DrawingFont "Segoe UI" 29 ([System.Drawing.FontStyle]::Bold)
$script:FontSub = New-DrawingFont "Segoe UI" 25 ([System.Drawing.FontStyle]::Regular)
$script:FontBody = New-DrawingFont "Segoe UI" 26 ([System.Drawing.FontStyle]::Regular)
$script:FontSmall = New-DrawingFont "Segoe UI" 22 ([System.Drawing.FontStyle]::Regular)
$script:FontTiny = New-DrawingFont "Segoe UI" 19 ([System.Drawing.FontStyle]::Regular)
$script:FontCode = New-DrawingFont "Consolas" 25 ([System.Drawing.FontStyle]::Bold)
$script:FontCodeSmall = New-DrawingFont "Consolas" 22 ([System.Drawing.FontStyle]::Bold)

function Export-GitStateFigure {
    $canvas = New-Canvas 2400 1500 "#F8FAFC"
    $g = $canvas.Graphics
    $bitmap = $canvas.Bitmap

    Draw-Text $g "Git's three local states" $script:FontTitle "#0F172A" 115 78 1500 76
    Draw-Text $g "A change moves from your files, to the staging area, to a recorded commit." $script:FontSubtitle "#475569" 120 156 1500 48

    Draw-StateCard -G $g -X 120 -Y 400 -W 590 -H 500 -Title "Workspace" -Subtitle "Working tree: files you edit" -Bullets @(
        "Actual project files on disk",
        "Modified, deleted, or untracked files",
        "Not committed until staged"
    ) -Accent "#0F766E" -Fill "#DDF7F0"

    Draw-StateCard -G $g -X 905 -Y 400 -W 590 -H 500 -Title "Index" -Subtitle "Staging area: next commit preview" -Bullets @(
        "Holds selected changes",
        "Lets you commit only part of your work",
        "Shown by git status as staged changes"
    ) -Accent "#B45309" -Fill "#FEF3C7"

    Draw-StateCard -G $g -X 1690 -Y 400 -W 590 -H 500 -Title "Commit" -Subtitle "Saved snapshots in history" -Bullets @(
        "Permanent snapshot with an ID",
        "Contains author, time, and message",
        "Branches point to commits"
    ) -Accent "#4F46E5" -Fill "#E0E7FF"

    Draw-Arrow $g 735 535 875 535 "#0F766E" 8 $false $false
    Draw-Pill $g 720 430 185 86 "git add" "stage changes" "#0F766E"

    Draw-Arrow $g 875 775 735 775 "#64748B" 7 $false $false
    Draw-Pill $g 654 812 325 88 "git restore --staged" "unstage, keep edits" "#64748B"

    Draw-Arrow $g 1520 535 1660 535 "#B45309" 8 $false $false
    Draw-Pill $g 1490 430 225 86 "git commit" "record snapshot" "#B45309"

    Draw-Arrow $g 1660 775 1520 775 "#64748B" 7 $false $false
    Draw-Pill $g 1412 812 390 88 "git reset --soft HEAD~1" "commit back to index" "#64748B"

    Draw-Arrow $g 2000 965 445 965 "#334155" 7 $true $false
    Draw-Pill $g 905 1010 590 94 "git restore or git switch" "load tracked file or branch contents from history" "#334155"

    Draw-RoundedRect $g 355 1140 1690 170 28 "#EFF6FF" "#93C5FD" 3
    Draw-Text $g "Typical flow: edit files in the workspace, stage the exact changes you want, then commit the staged snapshot." $script:FontBody "#1E3A8A" 420 1182 1560 50 "Center" "Center"
    Draw-Text $g "git status is the map: it compares workspace, index, and the current commit." $script:FontSmall "#334155" 420 1238 1560 42 "Center" "Center"

    $path = Join-Path $OutDir "git_three_states_commands.png"
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bitmap.Dispose()
}

function Export-LocalRemoteFigure {
    $canvas = New-Canvas 2400 1500 "#F8FAFC"
    $g = $canvas.Graphics
    $bitmap = $canvas.Bitmap

    Draw-Text $g "How a local repo connects to a remote" $script:FontTitle "#0F172A" 115 78 1700 76
    Draw-Text $g "Your local repository has its own commits. The remote, often GitHub origin, is another copy you sync with." $script:FontSubtitle "#475569" 120 156 1900 48

    Draw-Panel $g 110 270 980 970 "Local repository" "Your computer: working files, staging area, branches, and full commit history" "#F0FDFA" "#5EEAD4"
    Draw-Panel $g 1310 270 980 970 "Remote repository" "GitHub or another server: shared branches and commits for collaboration" "#EEF2FF" "#A5B4FC"

    Draw-MiniBox $g 180 430 400 175 "Workspace" "Files you edit before staging or committing." "#0F766E" "#FFFFFF"
    Draw-MiniBox $g 620 430 400 175 "Index" "The staged snapshot prepared for the next commit." "#B45309" "#FFFFFF"
    Draw-MiniBox $g 180 665 840 210 "Local commits" "Branches point to local commits. You can commit offline." "#4F46E5" "#FFFFFF"
    Draw-MiniBox $g 180 930 840 180 "Remote-tracking refs" "origin/main stores the last remote state fetched." "#0284C7" "#FFFFFF"

    $branchPen = New-DrawingPen "#4F46E5" 6
    $g.DrawLine($branchPen, 460, 818, 735, 818)
    $g.DrawEllipse($branchPen, 430, 799, 38, 38)
    $g.DrawEllipse($branchPen, 568, 799, 38, 38)
    $g.DrawEllipse($branchPen, 706, 799, 38, 38)
    $branchPen.Dispose()
    Draw-Text $g "main" $script:FontCodeSmall "#3730A3" 765 795 150 38

    $remotePen = New-DrawingPen "#0284C7" 6
    $remotePen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $g.DrawLine($remotePen, 465, 1066, 735, 1066)
    $g.DrawEllipse($remotePen, 435, 1047, 38, 38)
    $g.DrawEllipse($remotePen, 573, 1047, 38, 38)
    $g.DrawEllipse($remotePen, 711, 1047, 38, 38)
    $remotePen.Dispose()
    Draw-Text $g "origin/main" $script:FontCodeSmall "#0369A1" 765 1043 210 38

    Draw-MiniBox $g 1380 430 840 185 "Remote branches" "Shared branch names point to commits on the server." "#4F46E5" "#FFFFFF"
    Draw-MiniBox $g 1380 675 840 185 "Collaboration surface" "Teammates push and fetch from the same remote. GitHub also adds pull requests, issues, and releases." "#7C3AED" "#FFFFFF"
    Draw-MiniBox $g 1380 920 840 190 "Remote URL named origin" "The local name origin stores where push, fetch, and pull talk to by default." "#0284C7" "#FFFFFF"

    $serverPen = New-DrawingPen "#4F46E5" 6
    $g.DrawLine($serverPen, 1605, 560, 1885, 560)
    $g.DrawEllipse($serverPen, 1575, 541, 38, 38)
    $g.DrawEllipse($serverPen, 1713, 541, 38, 38)
    $g.DrawEllipse($serverPen, 1851, 541, 38, 38)
    $serverPen.Dispose()
    Draw-Text $g "main" $script:FontCodeSmall "#3730A3" 1910 537 160 38

    Draw-Arrow $g 1310 365 1090 365 "#64748B" 7 $true $false
    Draw-Pill $g 1080 310 245 88 "git clone" "first local copy" "#64748B"

    Draw-Arrow $g 1090 610 1310 610 "#16A34A" 8 $false $false
    Draw-Pill $g 1094 548 215 88 "git push" "send commits" "#16A34A"

    Draw-Arrow $g 1310 790 1090 790 "#2563EB" 8 $false $false
    Draw-Pill $g 1086 728 225 88 "git fetch" "update origin/*" "#2563EB"

    Draw-Arrow $g 1310 975 1090 975 "#7C3AED" 8 $false $false
    Draw-Pill $g 1086 913 225 88 "git pull" "fetch + integrate" "#7C3AED"

    Draw-RoundedRect $g 385 1285 1630 120 28 "#FFFFFF" "#CBD5E1" 3
    Draw-Text $g "Key idea: local and remote repositories are separate copies. Syncing moves commits; local file changes stay local until committed and pushed." $script:FontBody "#0F172A" 430 1310 1540 82 "Center" "Center"

    $path = Join-Path $OutDir "git_local_remote_connection.png"
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bitmap.Dispose()
}

Export-GitStateFigure
Export-LocalRemoteFigure

Get-Item -LiteralPath (Join-Path $OutDir "git_three_states_commands.png"), (Join-Path $OutDir "git_local_remote_connection.png") |
    Select-Object FullName, Length, LastWriteTime
