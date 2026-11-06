# =============================================================================
# EUDinator  --  GUI version
# Same package lists and phases as the CLI version, wrapped in a WinForms UI.
# Built for repeated runs: REFRESH to poll the device, RUN SELECTED PHASES to
# execute, REBOOT DEVICE to reboot and wait for reconnect.
#
# SAVE AS: EUDinator-GUI.ps1 (in the same folder as adb.exe)
# LAUNCH:  right-click > "Run with PowerShell"
#          (or: powershell -ExecutionPolicy Bypass -STA -File .\EUDinator-GUI.ps1)
# =============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------------------------------------------------------- PACKAGE LISTS
$PkgsATT = @(
  "com.asurion.android.protech.att","com.att.myWireless","com.locationlabs.cni.att",
  "com.synchronoss.dcs.att.r2g","com.aetherpal.attdh.se","net.aetherpal.device","com.att.iqi")

$PkgsFacebook = @(
  "com.facebook.katana","com.facebook.system","com.facebook.appmanager")

$PkgsSamMini = @(
  "com.samsung.android.scloud","com.samsung.android.spay","com.samsung.android.spayfw",
  "com.samsung.android.svoiceime","com.samsung.android.drivelink.stub",
  "com.sec.android.easyMover.Agent","com.samsung.android.smartswitchassistant",
  "com.samsung.android.themestore","com.sec.android.daemonapp",
  "com.samsung.android.app.sbrowseredge")

$PkgsGoogleApps = @(
  "com.google.android.youtube","com.google.android.gm","com.google.android.music",
  "com.google.android.apps.docs","com.google.android.apps.maps","com.google.android.apps.photos",
  "com.google.android.apps.walletnfcrel","com.google.android.videos","com.google.android.talk",
  "com.google.android.googlequicksearchbox","com.google.android.feedback",
  "com.google.android.printservice.recommendation","com.google.android.partnersetup",
  "com.google.android.onetimeinitializer","com.google.android.syncadapters.contacts",
  "com.google.android.syncadapters.calendar","com.google.android.backuptransport")

$PkgsSamBig = @(
  "com.samsung.faceservice","com.samsung.smartface","com.samsung.android.smartface",
  "com.samsung.android.fingerprint.service","com.samsung.android.authfw",
  "com.samsung.android.samsungpass","com.samsung.android.samsungpassautofill",
  "com.samsung.android.fmm","com.samsung.android.mobileservice","com.samsung.storyservice",
  "com.samsung.ucs.agent.boot","com.samsung.ucs.agent.ese",
  "com.samsung.android.app.watchmanager","com.samsung.android.app.watchmanagerstub",
  "com.samsung.android.app.simplesharing","com.samsung.android.allshare.service.fileshare",
  "com.samsung.android.allshare.service.mediashare","com.samsung.android.app.withtv",
  "com.samsung.android.smartmirroring","com.samsung.android.app.mirrorlink",
  "com.samsung.android.video","com.samsung.android.app.memo","com.samsung.android.calendar",
  "com.sec.android.gallery3d.panorama360view","com.samsung.android.app.selfmotionpanoramaviewer",
  "com.samsung.android.app.motionpanoramaviewer","com.samsung.android.app.interactivepanoramaviewer",
  "com.samsung.app.slowmotion","com.samsung.app.newtrim","com.samsung.app.highlightplayer",
  "com.samsung.android.app.smartcapture","com.samsung.android.app.camera.sticker.stamp.preload",
  "com.samsung.android.app.aodservice","com.samsung.android.themecenter","com.samsung.helphub",
  "com.samsung.android.keyguardwallpaperupdator","com.samsung.android.personalpage.service",
  "com.samsung.android.app.accesscontrol","com.samsung.android.beaconmanager",
  "com.samsung.android.stickercenter","com.samsung.android.stickerplugin",
  "com.samsung.android.provider.filterprovider","com.samsung.android.provider.shootingmodeprovider",
  "com.samsung.android.provider.stickerprovider","com.samsung.android.easysetup",
  "com.samsung.android.app.filterinstaller","com.samsung.android.app.assistantmenu",
  "com.samsung.android.universalswitch","com.samsung.android.app.talkback",
  "com.samsung.android.voicewakeup","com.samsung.android.svcagent","com.samsung.android.bbc.bbcagent",
  "com.samsung.android.lool","com.samsung.android.bluelightfilter","com.samsung.vvm",
  "com.samsung.dcmservice","com.samsung.qosindicator","com.samsung.ipservice",
  "com.samsung.aasaservice","com.samsung.upsmtheme","com.samsung.svoice","com.samsung.svoice.sync",
  "com.samsung.voiceserviceplatform","com.samsung.android.app.color",
  "com.samsung.android.sdk.handwriting","com.samsung.android.networkdiagnostic",
  "com.samsung.android.shortcutbackupservice",
  "com.samsung.android.sdk.professionalaudio.utility.jammonitor",
  "com.samsung.android.sdk.professionalaudio.app.audioconnectionservice",
  "com.samsung.advp.imssettings","com.samsung.android.app.galaxyfinder",
  "com.sec.android.widgetapp.samsungapps","com.sec.android.app.samsungapps",
  "com.samsung.android.game.gamehome","com.samsung.android.game.gametools",
  "com.samsung.android.securitylogagent",
  "com.samsung.da.daagent","com.samsung.android.da.daagent")

$PkgsMisc = @(
  "com.android.chrome","com.android.vending","com.amazon.kindle","com.ubercab",
  "flipboard.boxer.app","com.yellowpages.android.ypmobile","com.americanexpress.plenti",
  "com.lookout","com.directv.dvrscheduler","com.directv.promo.shade","com.cequint.ecid",
  "com.osp.app.signin","com.sec.android.app.sbrowser","com.sec.android.app.billing",
  "com.sec.android.ofviewer","com.sec.android.mimage.photoretouching",
  "com.sec.android.app.vepreload","com.sec.android.app.ringtoneBR",
  "com.sec.android.service.health","com.sec.android.app.shealth","com.sec.android.splitsound",
  "com.sec.hearingadjust","com.sec.android.app.magnifier","com.sec.android.app.popupcalculator",
  "com.sec.android.app.clockpackage","com.sec.android.widgetapp.easymodecontactswidget",
  "com.sec.android.easyonehand","com.sec.svoice.lang.en_US","com.sec.svoice.lang.es_US",
  "com.enhance.gameservice","com.drivemode","com.hancom.office.editor.hidden",
  "com.dsi.ant.service.socket","com.dsi.ant.sample.acquirechannels",
  "com.dsi.ant.plugins.antplus","com.dsi.ant.server","com.android.egg",
  "com.android.dreams.basic","com.android.dreams.phototable","com.android.bookmarkprovider",
  "com.android.providers.partnerbookmarks","com.android.printspooler","com.android.bips",
  "com.sec.android.diagmonagent","com.sec.spp.push","com.sec.android.preloadinstaller")

$PkgsGMS = @("com.google.android.gms","com.google.android.gsf")

# ----------------------------------------------------------------------- HELPERS
$script:ok = 0; $script:gone = 0; $script:bad = 0
function Log($msg, $color) {
    if (-not $color) { $color = [Drawing.Color]::White }
    $txtLog.SelectionColor = $color
    $txtLog.AppendText("$msg`r`n")
    $txtLog.SelectionColor = [Drawing.Color]::White
    $txtLog.ScrollToCaret()
    [Windows.Forms.Application]::DoEvents()
}
function Remove-Batch([string]$title, [string[]]$pkgs) {
    Log "--- $title ---" ([Drawing.Color]::Cyan)
    foreach ($p in $pkgs) {
        $r = .\adb.exe shell pm uninstall --user 0 $p 2>&1
        if ("$r" -match "Success")          { $script:ok++;   Log "  REMOVED                              $p" ([Drawing.Color]::LightGreen) }
        elseif ("$r" -match "not installed for 0") { $script:gone++; Log "  ALREADY ABSENT (expected on re-runs) $p" ([Drawing.Color]::Khaki) }
        else                                 { $script:bad++;  Log "  FAILED  $p  ->  $r" ([Drawing.Color]::OrangeRed) }
    }
}
function Get-DeviceSerial {
    $line = .\adb.exe devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" } | Select-Object -First 1
    if ($line) { return ($line -split "\t")[0] } else { return $null }
}

# ------------------------------------------------------------------------- FORM
$form               = New-Object Windows.Forms.Form
$form.Text          = "EUDinator - SM-G891A (S7 Active)"
$form.Size           = New-Object Drawing.Size(900, 800)
$form.StartPosition  = "CenterScreen"
$form.BackColor      = [Drawing.Color]::FromArgb(30,30,30)
$form.Font           = New-Object Drawing.Font("Arial", 11)

# -- top-left: device status
$lblDev          = New-Object Windows.Forms.Label
$lblDev.Location = New-Object Drawing.Point(12, 14)
$lblDev.Size     = New-Object Drawing.Size(480, 24)
$lblDev.ForeColor= [Drawing.Color]::Gray
$lblDev.Text     = "No device checked yet"
$form.Controls.Add($lblDev)

# -- REBOOT DEVICE: race red, bold white (left of refresh)
$btnReboot          = New-Object Windows.Forms.Button
$btnReboot.Location = New-Object Drawing.Point(520, 8)
$btnReboot.Size     = New-Object Drawing.Size(180, 36)
$btnReboot.Text     = "REBOOT DEVICE"
$btnReboot.BackColor= [Drawing.Color]::FromArgb(227, 24, 36)     # race red
$btnReboot.ForeColor= [Drawing.Color]::White
$btnReboot.FlatStyle= "Flat"
$btnReboot.Font     = New-Object Drawing.Font("Arial", 11, [Drawing.FontStyle]::Bold)
$form.Controls.Add($btnReboot)

# -- REFRESH: saturated royal blue, bold white, top-right, maxed
$btnRefresh          = New-Object Windows.Forms.Button
$btnRefresh.Location = New-Object Drawing.Point(710, 8)
$btnRefresh.Size     = New-Object Drawing.Size(170, 36)
$btnRefresh.Text     = "REFRESH"
$btnRefresh.BackColor= [Drawing.Color]::FromArgb(0, 80, 255)    # royal blue
$btnRefresh.ForeColor= [Drawing.Color]::White
$btnRefresh.FlatStyle= "Flat"
$btnRefresh.Font     = New-Object Drawing.Font("Arial", 11, [Drawing.FontStyle]::Bold)
$form.Controls.Add($btnRefresh)

# -- checkboxes
$y = 52
$boxes = [ordered]@{
  reenable = @{ txt = "PRE-PASS: re-enable all disabled packages (recommended)"; list = $null }
  sideload = @{ txt = "Side-load APKs from .\apks\ (skip if apps pre-installed)"; list = $null }
  att      = @{ txt = "PHASE A: AT&T carrier bloat + telemetry";        list = $PkgsATT }
  fb       = @{ txt = "PHASE B: Facebook trio";                        list = $PkgsFacebook }
  sammini  = @{ txt = "PHASE C: Samsung mini-batch (cloud/pay/car)";    list = $PkgsSamMini }
  gapps    = @{ txt = "PHASE D: Google consumer apps (pre-GMS)";        list = $PkgsGoogleApps }
  sambig   = @{ txt = "PHASE E: Samsung big sweep + biometrics (PIN kept)"; list = $PkgsSamBig }
  misc     = @{ txt = "PHASE F: Batch-5 misc (chrome/store/ANT+/cruft)"; list = $PkgsMisc }
  gms      = @{ txt = "PHASE G: GMS/GSF core strip (needs admin step first)"; list = $PkgsGMS }
  harden   = @{ txt = "PHASE H: Captive portal hardening (mode 0)";     list = $null }
}
foreach ($k in $boxes.Keys) {
  $cb = New-Object Windows.Forms.CheckBox
  $cb.Name      = $k
  $cb.Tag       = $k
  $cb.Text      = $boxes[$k].txt
  $cb.Checked   = ($k -notin @("gms","sideload"))
  $cb.Location  = New-Object Drawing.Point(16, $y)
  $cb.Size      = New-Object Drawing.Size(860, 28)
  $cb.ForeColor = [Drawing.Color]::White
  $cb.BackColor = $form.BackColor
  if ($k -eq "gms") { $cb.ForeColor = [Drawing.Color]::Khaki }
  $form.Controls.Add($cb)
  $boxes[$k].box = $cb
  $y += 34
}
$y += 8

# -- RUN SELECTED PHASES: saturated green, bold white
$btnRun          = New-Object Windows.Forms.Button
$btnRun.Location = New-Object Drawing.Point(16, $y)
$btnRun.Size     = New-Object Drawing.Size(864, 44)
$btnRun.Text     = "RUN SELECTED PHASES"
$btnRun.BackColor= [Drawing.Color]::FromArgb(0, 176, 24)       # saturated green
$btnRun.ForeColor= [Drawing.Color]::White
$btnRun.FlatStyle= "Flat"
$btnRun.Font     = New-Object Drawing.Font("Arial", 12, [Drawing.FontStyle]::Bold)
$form.Controls.Add($btnRun)
$y += 56

# -- log box (height pre-computed - avoids the op_Subtraction array trap)
$logHeight  = $form.ClientSize.Height - $y - 14
$logWidth   = 864
$txtLog          = New-Object Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.Font     = New-Object Drawing.Font("Arial", 11)
$txtLog.BackColor= [Drawing.Color]::Black
$txtLog.ForeColor= [Drawing.Color]::White
$txtLog.Location = New-Object Drawing.Point(16, $y)
$txtLog.Size     = New-Object Drawing.Size($logWidth, $logHeight)
$txtLog.Anchor   = "Top,Bottom,Left,Right"
$form.Controls.Add($txtLog)

# -------------------------------------------------------------------- BEHAVIOR
$btnRefresh.Add_Click({
    $serial = Get-DeviceSerial
    if ($serial) {
        $lblDev.Text = "CONNECTED: $serial"
        $lblDev.ForeColor = [Drawing.Color]::LightGreen
        Log "Device detected: $serial"
    } else {
        $lblDev.Text = "NO AUTHORIZED DEVICE (plug in, enable USB debugging, accept prompt)"
        $lblDev.ForeColor = [Drawing.Color]::OrangeRed
        Log "No device. ADB must be authorized from this PC."
    }
})

$btnReboot.Add_Click({
    $serial = Get-DeviceSerial
    if (-not $serial) { Log "REBOOT: no device connected." ([Drawing.Color]::OrangeRed); return }
    Log "REBOOT: sending reboot command to $serial ..." ([Drawing.Color]::Khaki)
    $null = .\adb.exe reboot
    Log "REBOOT: sent. Waiting for device to return (up to ~3 min)..."
    $lblDev.Text = "WAITING FOR REBOOT..."; $lblDev.ForeColor = [Drawing.Color]::Khaki
    $null = .\adb.exe wait-for-device
    $tries = 0
    do {
        Start-Sleep -Seconds 3
        $booted = (.\adb.exe shell getprop sys.boot_completed 2>$null) -replace "\r|\n",""
        $tries++
        [Windows.Forms.Application]::DoEvents()
    } while ($booted -ne "1" -and $tries -lt 60)
    if ($booted -eq "1") {
        $serial2 = Get-DeviceSerial
        if ($serial2) {
            $lblDev.Text = "CONNECTED: $serial2 (post-reboot)"; $lblDev.ForeColor = [Drawing.Color]::LightGreen
            Log "REBOOT COMPLETE: device back online. Unlock PIN if needed and verify." ([Drawing.Color]::LightGreen)
        } else {
            $lblDev.Text = "REBOOTED BUT UNAUTHORIZED - accept USB debug prompt on phone"
            $lblDev.ForeColor = [Drawing.Color]::OrangeRed
            Log "Device booted but ADB unauthorized. Accept the prompt on the phone, then REFRESH." ([Drawing.Color]::OrangeRed)
        }
    } else {
        Log "REBOOT: timed out waiting for boot_completed." ([Drawing.Color]::OrangeRed)
    }
})

$btnRun.Add_Click({
    if (-not (Get-DeviceSerial)) {
        Log "ABORT: no authorized device. Click REFRESH first." ([Drawing.Color]::OrangeRed)
        return
    }
    $btnRun.Enabled = $false
    $script:ok = 0; $script:gone = 0; $script:bad = 0

    if ($boxes["reenable"].box.Checked) {
        Log "--- PRE-PASS: enabling all disabled packages ---" ([Drawing.Color]::Cyan)
        $disabled = .\adb.exe shell pm list packages -d | ForEach-Object { $_ -replace "^package:","" }
        if ($disabled) { foreach ($p in $disabled) { $null = .\adb.exe shell pm enable $p 2>$null };
            Log "  re-enabled $($disabled.Count) package(s)" }
        else { Log "  none disabled" }
    }

    if ($boxes["sideload"].box.Checked) {
        Log "--- Side-load from .\apks\ ---" ([Drawing.Color]::Cyan)
        if (Test-Path .\apks) {
            Get-ChildItem .\apks -Filter *.apk | ForEach-Object {
                $r = .\adb.exe install $_.FullName 2>&1
                if ("$r" -match "Success") { Log "  installed: $($_.Name)" ([Drawing.Color]::LightGreen) }
                else { Log "  FAILED: $($_.Name) -> $r" ([Drawing.Color]::OrangeRed) }
            }
        } else { Log "  no .\apks folder found - skipped" ([Drawing.Color]::Khaki) }
    }

    foreach ($k in @("att","fb","sammini","gapps","sambig","misc")) {
        $cb = $boxes[$k].box
        if (-not $cb.Checked) { continue }
        Remove-Batch $cb.Text $boxes[$k].list
    }

    if ($boxes["gms"].box.Checked) {
        $ans = [Windows.Forms.MessageBox]::Show(
          "GMS is registered as a DEVICE ADMIN on this firmware.`n`n" +
          "On the phone, deactivate it FIRST:`n" +
          "Settings > Lock screen and security > Other security settings >`n" +
          "Device admin apps > deactivate Android Device Manager / Google.`n`n" +
          "Deactivated and ready to strip GMS?",
          "GMS strip - manual step", "YesNo", "Warning")
        if ($ans -eq "Yes") { Remove-Batch $boxes["gms"].box.Text $PkgsGMS }
        else { Log "  GMS strip SKIPPED by user." ([Drawing.Color]::Khaki) }
    }

    if ($boxes["harden"].box.Checked) {
        Log "--- PHASE H: captive portal hardening ---" ([Drawing.Color]::Cyan)
        $null = .\adb.exe shell settings put global captive_portal_mode 0
        $val  = (.\adb.exe shell settings get global captive_portal_mode) -replace "\r|\n",""
        Log "  captive_portal_mode = $val (expect 0)" ([Drawing.Color]::LightGreen)
    }

    $doneColor = [Drawing.Color]::LightGreen
    if ($script:bad -gt 0) { $doneColor = [Drawing.Color]::Khaki }
    Log "`nDONE.  Removed: $script:ok   Already absent: $script:gone   Failures: $script:bad" $doneColor
    Log "Any 'FAILED' lines that are NOT 'not installed for 0' need investigation."
    Log "Use REBOOT DEVICE now, then verify PIN unlock + Meshtastic/ATAK."
    $btnRun.Enabled = $true
})

[void]$form.ShowDialog()
