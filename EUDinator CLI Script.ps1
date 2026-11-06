# =============================================================================
# EUDinator  --  CLI version
# Strips AT&T Samsung firmware (built and tested on SM-G891A) down to a bare
# EUD for ATAK + Meshtastic use. Kills carrier bloat, facebook, google apps,
# samsung cruft, biometrics, and GMS. Keeps radio stack, knox, GPS, keyboard,
# clipboard, and everything the commo stack needs.
#
# USAGE:
#   1. Put this script in the same folder as adb.exe (android platform-tools)
#   2. Enable Developer options + USB debugging on the phone
#   3. Plug in ONE device, accept the USB debugging prompt
#   4. From the platform-tools folder:
#        powershell -ExecutionPolicy Bypass -File .\EUDinator.ps1
#
# REVERSIBILITY: everything uses "pm uninstall --user 0". Factory reset
# restores all. Single-app restore:
#   adb shell cmd package install-existing <package.name>
# =============================================================================

$ErrorActionPreference = "Continue"
$script:successCount = 0
$script:alreadyGone   = 0
$script:failCount     = 0
$script:failedPkgs    = @()

function Wait-ForDevice {
    Write-Host "`n=== Waiting for authorized device ===" -ForegroundColor Cyan
    while ($true) {
        $raw   = .\adb.exe devices
        $lines = $raw | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" }
        if ($lines.Count -gt 0) {
            Write-Host "Device connected: $($lines -join ', ')" -ForegroundColor Green
            return
        }
        Write-Host "No authorized device. Plug in phone, enable USB debugging," -ForegroundColor Yellow
        Write-Host "accept the on-screen prompt, then press Enter to retry (Ctrl+C to abort)." -ForegroundColor Yellow
        Read-Host | Out-Null
    }
}

function Stall([string]$msg) {
    Write-Host "`n>>> STALL POINT: $msg" -ForegroundColor Magenta
    Read-Host "Press Enter when ready" | Out-Null
}

function Remove-Packages {
    param([string[]]$names, [string]$phase, [string]$desc)
    Write-Host "`n=== PHASE $phase : $desc ===" -ForegroundColor Cyan
    foreach ($p in $names) {
        $result = .\adb.exe shell pm uninstall --user 0 $p 2>&1
        if ("$result" -match "Success") {
            $script:successCount++
            Write-Host "  REMOVED  $p" -ForegroundColor Green
        }
        elseif ("$result" -match "not installed for 0") {
            $script:alreadyGone++
            Write-Host "  ALREADY ABSENT (expected on re-runs)  $p" -ForegroundColor DarkYellow
        }
        else {
            $script:failCount++
            $script:failedPkgs += "$p :: $result"
            Write-Host "  FAILED   $p  ->  $result" -ForegroundColor Red
        }
    }
}

Write-Host "EUDinator - CLI" -ForegroundColor Magenta
Wait-ForDevice

# ---- PHASE 1: re-enable everything disabled (precondition for removal) ------
Write-Host "`n=== PHASE 1: Re-enabling all disabled packages ===" -ForegroundColor Cyan
$disabled = .\adb.exe shell pm list packages -d | ForEach-Object { $_ -replace "^package:", "" }
if ($disabled) {
    foreach ($p in $disabled) { $null = .\adb.exe shell pm enable $p 2>$null }
    Write-Host "Re-enabled $($disabled.Count) package(s)."
} else { Write-Host "None disabled." }

# ---- PHASE 2: manual GMS device-admin deactivation --------------------------
Write-Host "`n=== PHASE 2: MANUAL STEP (required before GMS strip) ===" -ForegroundColor Yellow
Write-Host "Settings > Lock screen and security > Other security settings >"
Write-Host "Device admin apps > DEACTIVATE Android Device Manager / Google entry."
Stall "Deactivate the Google device admin on the phone, THEN continue"

# ---- PHASE 3: optional APK sideload -----------------------------------------
Write-Host "`n=== PHASE 3: APK sideload (.\apks\) ===" -ForegroundColor Cyan
if (Test-Path .\apks) {
    Get-ChildItem .\apks -Filter *.apk | ForEach-Object {
        $r = .\adb.exe install $_.FullName 2>&1
        if ("$r" -match "Success") { Write-Host "  installed: $($_.Name)" -ForegroundColor Green }
        else { Write-Host "  FAILED: $($_.Name) -> $r" -ForegroundColor Red }
    }
} else { Write-Host "No .\apks folder - skipping (install apps manually before GMS strip)." }

# ---- PHASE 4: AT&T carrier bloat --------------------------------------------
Remove-Packages @(
    "com.asurion.android.protech.att",
    "com.att.myWireless",
    "com.locationlabs.cni.att",
    "com.synchronoss.dcs.att.r2g",
    "com.aetherpal.attdh.se",
    "net.aetherpal.device",
    "com.att.iqi"
) -phase "4" -desc "AT&T bloat + telemetry"

# ---- PHASE 5: Facebook trio --------------------------------------------------
Remove-Packages @(
    "com.facebook.katana",
    "com.facebook.system",
    "com.facebook.appmanager"
) -phase "5" -desc "Facebook trio"

# ---- PHASE 6: Samsung mini-batch ---------------------------------------------
Remove-Packages @(
    "com.samsung.android.scloud",
    "com.samsung.android.spay",
    "com.samsung.android.spayfw",
    "com.samsung.android.svoiceime",
    "com.samsung.android.drivelink.stub",
    "com.sec.android.easyMover.Agent",
    "com.samsung.android.smartswitchassistant",
    "com.samsung.android.themestore",
    "com.sec.android.daemonapp",
    "com.samsung.android.app.sbrowseredge"
) -phase "6" -desc "Samsung cloud/pay/voice/car/store"

# ---- PHASE 7: Google consumer apps (pre-GMS) ---------------------------------
Remove-Packages @(
    "com.google.android.youtube",
    "com.google.android.gm",
    "com.google.android.music",
    "com.google.android.apps.docs",
    "com.google.android.apps.maps",
    "com.google.android.apps.photos",
    "com.google.android.apps.walletnfcrel",
    "com.google.android.videos",
    "com.google.android.talk",
    "com.google.android.googlequicksearchbox",
    "com.google.android.feedback",
    "com.google.android.printservice.recommendation",
    "com.google.android.partnersetup",
    "com.google.android.onetimeinitializer",
    "com.google.android.syncadapters.contacts",
    "com.google.android.syncadapters.calendar",
    "com.google.android.backuptransport"
) -phase "7" -desc "Google consumer apps"

# ---- MIDPOINT CHECKPOINT ----------------------------------------------------
Stall "OPTIONAL CHECKPOINT. If the phone has acted odd, run '.\adb reboot' now,`nlet it reboot, re-unlock PIN, re-authorize USB debug, THEN continue. Otherwise just press Enter."

# ---- PHASE 8: Samsung consumer layer + biometrics (big sweep) ----------------
Remove-Packages @(
    "com.samsung.faceservice",
    "com.samsung.smartface",
    "com.samsung.android.smartface",
    "com.samsung.android.fingerprint.service",
    "com.samsung.android.authfw",
    "com.samsung.android.samsungpass",
    "com.samsung.android.samsungpassautofill",
    "com.samsung.android.fmm",
    "com.samsung.android.mobileservice",
    "com.samsung.storyservice",
    "com.samsung.ucs.agent.boot",
    "com.samsung.ucs.agent.ese",
    "com.samsung.android.app.watchmanager",
    "com.samsung.android.app.watchmanagerstub",
    "com.samsung.android.app.simplesharing",
    "com.samsung.android.allshare.service.fileshare",
    "com.samsung.android.allshare.service.mediashare",
    "com.samsung.android.app.withtv",
    "com.samsung.android.smartmirroring",
    "com.samsung.android.app.mirrorlink",
    "com.samsung.android.video",
    "com.samsung.android.app.memo",
    "com.samsung.android.calendar",
    "com.sec.android.gallery3d.panorama360view",
    "com.samsung.android.app.selfmotionpanoramaviewer",
    "com.samsung.android.app.motionpanoramaviewer",
    "com.samsung.android.app.interactivepanoramaviewer",
    "com.samsung.app.slowmotion",
    "com.samsung.app.newtrim",
    "com.samsung.app.highlightplayer",
    "com.samsung.android.app.smartcapture",
    "com.samsung.android.app.camera.sticker.stamp.preload",
    "com.samsung.android.app.aodservice",
    "com.samsung.android.themecenter",
    "com.samsung.helphub",
    "com.samsung.android.keyguardwallpaperupdator",
    "com.samsung.android.personalpage.service",
    "com.samsung.android.app.accesscontrol",
    "com.samsung.android.beaconmanager",
    "com.samsung.android.stickercenter",
    "com.samsung.android.stickerplugin",
    "com.samsung.android.provider.filterprovider",
    "com.samsung.android.provider.shootingmodeprovider",
    "com.samsung.android.provider.stickerprovider",
    "com.samsung.android.easysetup",
    "com.samsung.android.app.filterinstaller",
    "com.samsung.android.app.assistantmenu",
    "com.samsung.android.universalswitch",
    "com.samsung.android.app.talkback",
    "com.samsung.android.voicewakeup",
    "com.samsung.android.svcagent",
    "com.samsung.android.bbc.bbcagent",
    "com.samsung.android.lool",
    "com.samsung.android.bluelightfilter",
    "com.samsung.vvm",
    "com.samsung.dcmservice",
    "com.samsung.qosindicator",
    "com.samsung.ipservice",
    "com.samsung.aasaservice",
    "com.samsung.upsmtheme",
    "com.samsung.svoice",
    "com.samsung.svoice.sync",
    "com.samsung.voiceserviceplatform",
    "com.samsung.android.app.color",
    "com.samsung.android.sdk.handwriting",
    "com.samsung.android.networkdiagnostic",
    "com.samsung.android.shortcutbackupservice",
    "com.samsung.android.sdk.professionalaudio.utility.jammonitor",
    "com.samsung.android.sdk.professionalaudio.app.audioconnectionservice",
    "com.samsung.advp.imssettings",
    "com.samsung.android.app.galaxyfinder",
    "com.sec.android.widgetapp.samsungapps",
    "com.sec.android.app.samsungapps",
    "com.samsung.android.game.gamehome",
    "com.samsung.android.game.gametools",
    "com.samsung.android.securitylogagent",
    "com.samsung.da.daagent",
    "com.samsung.android.da.daagent"
) -phase "8" -desc "Samsung consumer layer + biometrics"

# ---- PHASE 9: batch-5 misc ----------------------------------------------------
Remove-Packages @(
    "com.android.chrome",
    "com.android.vending",
    "com.amazon.kindle",
    "com.ubercab",
    "flipboard.boxer.app",
    "com.yellowpages.android.ypmobile",
    "com.americanexpress.plenti",
    "com.lookout",
    "com.directv.dvrscheduler",
    "com.directv.promo.shade",
    "com.cequint.ecid",
    "com.osp.app.signin",
    "com.sec.android.app.sbrowser",
    "com.sec.android.app.billing",
    "com.sec.android.ofviewer",
    "com.sec.android.mimage.photoretouching",
    "com.sec.android.app.vepreload",
    "com.sec.android.app.ringtoneBR",
    "com.sec.android.service.health",
    "com.sec.android.app.shealth",
    "com.sec.android.splitsound",
    "com.sec.hearingadjust",
    "com.sec.android.app.magnifier",
    "com.sec.android.app.popupcalculator",
    "com.sec.android.app.clockpackage",
    "com.sec.android.widgetapp.easymodecontactswidget",
    "com.sec.android.easyonehand",
    "com.sec.svoice.lang.en_US",
    "com.sec.svoice.lang.es_US",
    "com.enhance.gameservice",
    "com.drivemode",
    "com.hancom.office.editor.hidden",
    "com.dsi.ant.service.socket",
    "com.dsi.ant.sample.acquirechannels",
    "com.dsi.ant.plugins.antplus",
    "com.dsi.ant.server",
    "com.android.egg",
    "com.android.dreams.basic",
    "com.android.dreams.phototable",
    "com.android.bookmarkprovider",
    "com.android.providers.partnerbookmarks",
    "com.android.printspooler",
    "com.android.bips",
    "com.sec.android.diagmonagent",
    "com.sec.spp.push",
    "com.sec.android.preloadinstaller"
) -phase "9" -desc "Batch-5 misc (chrome/vending/ANT+/cruft)"

# ---- PHASE 10: GMS core strip ---------------------------------------------------
Remove-Packages @(
    "com.google.android.gms",
    "com.google.android.gsf"
) -phase "10" -desc "GMS/GSF core"

# ---- REBOOT CHECKPOINT -------------------------------------------------------
Stall "REQUIRED REBOOT. Run '.\adb reboot' now (or reboot by hand), wait for full boot,`nunlock the PIN, reconnect USB if needed, accept the USB debug prompt, THEN press Enter. Script will re-detect the device before continuing."

Wait-ForDevice   # re-establish connection after reboot

# ---- PHASE 11: captive portal hardening -----------------------------------------
Write-Host "`n=== PHASE 11: Captive portal hardening ===" -ForegroundColor Cyan
.\adb.exe shell settings put global captive_portal_mode 0
$cpm = .\adb.exe shell settings get global captive_portal_mode
Write-Host "captive_portal_mode = $cpm (expect 0)"

# ---- PHASE 12: report -----------------------------------------------------------
Write-Host "`n================ REPORT ================" -ForegroundColor Magenta
Write-Host "Removed this run  : $script:successCount"
Write-Host "Already absent    : $script:alreadyGone  (normal on re-runs)"
Write-Host "Real failures     : $script:failCount"
if ($script:failedPkgs.Count -gt 0) {
    Write-Host "`nFailed packages:" -ForegroundColor Red
    $script:failedPkgs | ForEach-Object { Write-Host "  $_" }
    Write-Host "Anything NOT 'not installed for 0' here needs investigation."
}
.\adb.exe shell pm list packages -s | Out-File -Encoding utf8 .\remaining-packages.txt
Write-Host "Remaining system packages -> remaining-packages.txt"

Write-Host "`nFINAL CHECKS:" -ForegroundColor Cyan
Write-Host " 1. PIN unlock works (did it survive the reboot?)"
Write-Host " 2. Meshtastic launches, connects to node"
Write-Host " 3. ATAK launches, Meshtastic plugin enabled, nodes render on map"
Write-Host " 4. If TAK stack broke over GMS:"
Write-Host "    adb shell cmd package install-existing com.google.android.gms"

Stall "Done with this device. Press Enter to close the script"
