Unicode true

!include "MUI2.nsh"

!define APP_NAME "PonyDownloader"
!define APP_PUBLISHER "MutantCat Working Group"
!define APP_URL "https://github.com/Mutantcat-Working-Group/PonyDownloader"
!define APP_EXE "PonyDownloader.exe"

!ifndef VERSION
  !define VERSION "1.0.20261007"
!endif
!ifndef RELEASE_DIR
  !error "RELEASE_DIR must be defined"
!endif
!ifndef OUTPUT_DIR
  !error "OUTPUT_DIR must be defined"
!endif
!ifndef ICON_FILE
  !define ICON_FILE "${RELEASE_DIR}\resources\app_icon.ico"
!endif

Name "${APP_NAME} ${VERSION}"
OutFile "${OUTPUT_DIR}\${APP_NAME}-v${VERSION}-windows-amd64.exe"
InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey HKLM "Software\${APP_NAME}" "InstallLocation"
; A per-machine install has to ask for elevation, otherwise $PROGRAMFILES
; stays unwritable for standard users.
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!define MUI_ICON "${ICON_FILE}"
!define MUI_UNICON "${ICON_FILE}"
!define MUI_ABORTWARNING
; Replaces the "Nullsoft Install System vX.YY.Z" footer with product info.
BrandingText "${APP_NAME} v${VERSION} - ${APP_PUBLISHER}"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

; The bundled language files ship their own "Nullsoft Install System" branding
; string, which wins over BrandingText once a language is loaded. Pin the footer
; per language so the product name and version are always shown instead.
LangString ^Branding ${LANG_SIMPCHINESE} "${APP_NAME} v${VERSION} - ${APP_PUBLISHER}"
LangString ^Branding ${LANG_ENGLISH} "${APP_NAME} v${VERSION} - ${APP_PUBLISHER}"

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "${RELEASE_DIR}\*"

  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "URLInfoAbout" "${APP_URL}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "InstallLocation" "$INSTDIR"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\${APP_NAME}.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
  DeleteRegKey HKLM "Software\${APP_NAME}"
SectionEnd
