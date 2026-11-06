EUDinator - README

This is a simple powershell file, made to debloat, degoogle and strip AT&T Samsung phones (built and tested on SM-G891A) so they can be repurposed as bare bones EUDs for ATAK and Meshtastic only. kills carrier bloat, facebook, GMS (Google Mobile Services), samsung cruft, biometrics, and GMS itself. keeps the radio stack, knox (android BFU/security suite), GPS, clipboard, keyboard and everything the commo stack actually needs. Pin has been kept to keep the phone and BFU encryption secure, while fingerprint and face unlock are removed to prevent IR lights lighting you up like a flare under NODs, and no PII collection. captive portal pings get disabled too, so the phone never contacts google, samsung or AT&T home on wifi connect.

**before running**
These powershell scripts are meant to be installed into the /platform-tools folder, after extracting ADB/Android SDK. Put the /platform-tools folder somewhere you won't forget. ADB/Android Debug Bridge is what drives this entire process.

	USER WARNING:
This removes basically everything from the phone. While it would theoretically be possible to still use it as a regular phone, this is specifically designed to be used either via MANet, Mesh, or offline entirely.
You can still install apps via transferring an apk over USB, such as F-Droid, however this hasn't been tested.
This removes GMS, chrome and the play store. After running, no browsers are left on the phone to be used. install your APKs before stripping GMS.
This is meant outrightly to be used for an ATAK EUD on the Samsung S7 Active.
This is all undone by factory resetting the phone, so keep that in mind if you need to go back. With all things, there is a slight chance of having a brick. This list has been scrubbed (so many times) to make sure nothing that affects the core functionality of the device is removed or altered, however, **perform these actions at your own risk**

there are two tools included:

EUDinator.ps1
the plain CLI version; runs all phases top to bottom with stalls where you need to touch the phone. this is good for one off debloats or if you dont want a UI.

EUDinator-GUI.ps1
the GUI version; buttons, checkboxes, live log, simple use and pretty pushbutton, especially if you're gutting multiple S7s at once.

	SETUP:

1.) grab the android SDK platform tools zip from google and extract it anywhere simple. both scripts call adb.exe directly so they need to live in the same folder as it
2.) drop one or both .ps1 files into that folder
3.) on the phone enable developer options (tap build number 7 times) then enable USB debugging
4.) plug in the phone with a data cable, accept the "allow usb debugging" prompt on the phone
5.) for the GUI right click and run with powershell. for the CLI run this from the platform-tools folder in powershell:
	powershell -ExecutionPolicy Bypass -File .\EUDinator.ps1

	GUI:

1.) hit REFRESH, confirm your serial is listed
2.) check/uncheck the phases you want. defaults are sane, leave GMS unticked until youve done the device admin step
3.) for GMS: settings, lock screen and security, other security settings, device admin apps, deactivate the android device manager / google entry, then tick GMS and run
4.) run selected phases: green means removed, yellow means already absent (which is normal on re-runs), red means a failure has occurred.
5.) REBOOT DEVICE reboots the phone and waits for it to come back on its own
6.) after reboot verify PIN unlock still works, then open meshtastic and ATAK and confirm the mesh map populates

everything is reversible. every removal is pm uninstall --user 0 so a factory reset brings it all back, or a single package with:

adb shell cmd package install-existing <package.name>

	NOTES

"not installed for 0" failures are good on already stripped units, the script labels them as already absent, so dont panic. actually, you should. it'd be funny, however futile. i had a mental breakdown over this, i think it should be a shared experience. after all, that's what this is all about, right?
tested end to end on one SM-G891A, should map 1:1 to other AT&T samsung builds of this era. other firmwares will show more already absent results

Built with help from Lumo, by Proton.
