#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=portknock.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Opt("MustDeclareVars", 1)

; ============================================================
; CONFIGURATION
; ============================================================

Global Const $CONFIG_FILE = @ScriptDir & "\config.ini"

Global $g_ConfigCount = 0
Global $g_ProfileNames[1]
Global $g_SelectedProfile = ""

; ============================================================
; NETWORK STARTUP
; ============================================================

TCPStartup()
UDPStartup()



; ============================================================
; GUI
; ============================================================

Global $Form1 = GUICreate("Port Knock", 470, 480)

Global $List1 = GUICtrlCreateList("", 24, 16, 420, 150)

; IP
Global $LabelIP = GUICtrlCreateLabel("IP", 20, 190, 30, 20)
Global $InIP = GUICtrlCreateInput("", 55, 187, 170, 22)

; Profile
Global $LabelDesc = GUICtrlCreateLabel("Profile", 245, 190, 45, 20)
Global $InDesc = GUICtrlCreateInput("", 295, 187, 145, 22)

; Headers
GUICtrlCreateLabel("Step", 20, 225, 40, 20)
GUICtrlCreateLabel("Type", 70, 225, 50, 20)
GUICtrlCreateLabel("Port", 155, 225, 50, 20)
GUICtrlCreateLabel("Text", 230, 225, 50, 20)

; ============================================================
; STEP 1
; ============================================================

GUICtrlCreateLabel("1", 25, 247, 20, 20)

Global $CBO1 = GUICtrlCreateCombo("TCP", 65, 245, 70, 22)
GUICtrlSetData($CBO1, "TCP|UDP")

Global $In1Port = GUICtrlCreateInput("", 145, 245, 80, 22)
Global $In1Text = GUICtrlCreateInput("", 235, 245, 205, 22)

; ============================================================
; STEP 2
; ============================================================

GUICtrlCreateLabel("2", 25, 277, 20, 20)

Global $CBO2 = GUICtrlCreateCombo("None", 65, 275, 70, 22)
GUICtrlSetData($CBO2, "None|TCP|UDP")

Global $In2Port = GUICtrlCreateInput("", 145, 275, 80, 22)
Global $In2Text = GUICtrlCreateInput("", 235, 275, 205, 22)

; ============================================================
; STEP 3
; ============================================================

GUICtrlCreateLabel("3", 25, 307, 20, 20)

Global $CBO3 = GUICtrlCreateCombo("None", 65, 305, 70, 22)
GUICtrlSetData($CBO3, "None|TCP|UDP")

Global $In3Port = GUICtrlCreateInput("", 145, 305, 80, 22)
Global $In3Text = GUICtrlCreateInput("", 235, 305, 205, 22)

; ============================================================
; STEP 4
; ============================================================

GUICtrlCreateLabel("4", 25, 337, 20, 20)

Global $CBO4 = GUICtrlCreateCombo("None", 65, 335, 70, 22)
GUICtrlSetData($CBO4, "None|TCP|UDP")

Global $In4Port = GUICtrlCreateInput("", 145, 335, 80, 22)
Global $In4Text = GUICtrlCreateInput("", 235, 335, 205, 22)

; ============================================================
; BUTTONS
; ============================================================

Global $BTNKnock = GUICtrlCreateButton("KNOCK", 45, 390, 90, 32)
Global $BTNSave = GUICtrlCreateButton("Save", 150, 390, 90, 32)
Global $BTNDelete = GUICtrlCreateButton("Delete", 255, 390, 90, 32)
Global $BTNNew = GUICtrlCreateButton("New", 360, 390, 70, 32)

Global $LBLStatus = GUICtrlCreateLabel("", 25, 440, 420, 25)

GUISetState(@SW_SHOW)

; ============================================================
; LOAD PROFILES
; ============================================================

LoadProfiles()

If $g_ConfigCount > 0 Then

    $g_SelectedProfile = $g_ProfileNames[1]

    LoadProfile($g_SelectedProfile)

EndIf

; ============================================================
; MAIN LOOP
; ============================================================

While 1

    Local $nMsg = GUIGetMsg()

    Switch $nMsg

        ; ----------------------------------------------------
        ; CLOSE
        ; ----------------------------------------------------

        Case $GUI_EVENT_CLOSE

            TCPShutdown()
            UDPShutdown()

            Exit

        ; ----------------------------------------------------
        ; NEW PROFILE
        ; ----------------------------------------------------

        Case $BTNNew

            ClearFields()

            $g_SelectedProfile = ""

            GUICtrlSetData($LBLStatus, "New profile")

        ; ----------------------------------------------------
        ; SAVE
        ; ----------------------------------------------------

        Case $BTNSave

            SaveCurrentProfile()

        ; ----------------------------------------------------
        ; DELETE
        ; ----------------------------------------------------

        Case $BTNDelete

            DeleteCurrentProfile()

        ; ----------------------------------------------------
        ; KNOCK
        ; ----------------------------------------------------

        Case $BTNKnock

            PerformKnock()

        ; ----------------------------------------------------
        ; PROFILE SELECTED
        ; ----------------------------------------------------

        Case $List1

            Local $selected = GUICtrlRead($List1)

            If $selected <> "" Then

                $g_SelectedProfile = $selected

                LoadProfile($selected)

            EndIf

    EndSwitch

WEnd


; ============================================================
; LOAD PROFILE LIST
; ============================================================

Func LoadProfiles()

    Local $i
    Local $name

    $g_ConfigCount = Number(IniRead($CONFIG_FILE, "Profiles", "Count", "0"))

    If $g_ConfigCount < 0 Then
        $g_ConfigCount = 0
    EndIf

    ReDim $g_ProfileNames[$g_ConfigCount + 1]

    GUICtrlSetData($List1, "")

    For $i = 1 To $g_ConfigCount

        $name = IniRead($CONFIG_FILE, "Profiles", "Name" & $i, "")

        If $name <> "" Then

            $g_ProfileNames[$i] = $name

            GUICtrlSetData($List1, $name)

        Else

            $g_ProfileNames[$i] = ""

        EndIf

    Next

EndFunc


; ============================================================
; LOAD ONE PROFILE
; ============================================================

Func LoadProfile($profile)

    If $profile = "" Then
        Return
    EndIf

    ClearFields()

    GUICtrlSetData($InDesc, $profile)

    ; IP
    GUICtrlSetData( _
        $InIP, _
        IniRead($CONFIG_FILE, $profile, "IP", "") _
    )

    ; STEP 1
    GUICtrlSetData( _
        $CBO1, _
        IniRead($CONFIG_FILE, $profile, "Type1", "TCP") _
    )

    GUICtrlSetData( _
        $In1Port, _
        IniRead($CONFIG_FILE, $profile, "Port1", "") _
    )

    GUICtrlSetData( _
        $In1Text, _
        IniRead($CONFIG_FILE, $profile, "Text1", "") _
    )

    ; STEP 2
    GUICtrlSetData( _
        $CBO2, _
        IniRead($CONFIG_FILE, $profile, "Type2", "None") _
    )

    GUICtrlSetData( _
        $In2Port, _
        IniRead($CONFIG_FILE, $profile, "Port2", "") _
    )

    GUICtrlSetData( _
        $In2Text, _
        IniRead($CONFIG_FILE, $profile, "Text2", "") _
    )

    ; STEP 3
    GUICtrlSetData( _
        $CBO3, _
        IniRead($CONFIG_FILE, $profile, "Type3", "None") _
    )

    GUICtrlSetData( _
        $In3Port, _
        IniRead($CONFIG_FILE, $profile, "Port3", "") _
    )

    GUICtrlSetData( _
        $In3Text, _
        IniRead($CONFIG_FILE, $profile, "Text3", "") _
    )

    ; STEP 4
    GUICtrlSetData( _
        $CBO4, _
        IniRead($CONFIG_FILE, $profile, "Type4", "None") _
    )

    GUICtrlSetData( _
        $In4Port, _
        IniRead($CONFIG_FILE, $profile, "Port4", "") _
    )

    GUICtrlSetData( _
        $In4Text, _
        IniRead($CONFIG_FILE, $profile, "Text4", "") _
    )

    GUICtrlSetData($LBLStatus, "Loaded: " & $profile)

EndFunc


; ============================================================
; SAVE CURRENT PROFILE
; ============================================================

Func SaveCurrentProfile()

    Local $profile
    Local $ip
    Local $found
    Local $i

    $profile = StringStripWS(GUICtrlRead($InDesc), 3)
    $ip = StringStripWS(GUICtrlRead($InIP), 3)

    If $profile = "" Then

        MsgBox(48, "Error", "Enter profile name.")

        Return

    EndIf

    If $ip = "" Then

        MsgBox(48, "Error", "Enter server IP.")

        Return

    EndIf

    ; --------------------------------------------------------
    ; Check whether profile already exists
    ; --------------------------------------------------------

    $found = 0

    For $i = 1 To $g_ConfigCount

        If $g_ProfileNames[$i] = $profile Then

            $found = 1

            ExitLoop

        EndIf

    Next

    ; --------------------------------------------------------
    ; Add new profile
    ; --------------------------------------------------------

    If $found = 0 Then

        $g_ConfigCount += 1

        ReDim $g_ProfileNames[$g_ConfigCount + 1]

        $g_ProfileNames[$g_ConfigCount] = $profile

        IniWrite( _
            $CONFIG_FILE, _
            "Profiles", _
            "Count", _
            $g_ConfigCount _
        )

        IniWrite( _
            $CONFIG_FILE, _
            "Profiles", _
            "Name" & $g_ConfigCount, _
            $profile _
        )

    EndIf

    ; --------------------------------------------------------
    ; Save IP
    ; --------------------------------------------------------

    IniWrite( _
        $CONFIG_FILE, _
        $profile, _
        "IP", _
        $ip _
    )

    ; --------------------------------------------------------
    ; Save steps
    ; --------------------------------------------------------

    SaveStep($profile, 1, $CBO1, $In1Port, $In1Text)
    SaveStep($profile, 2, $CBO2, $In2Port, $In2Text)
    SaveStep($profile, 3, $CBO3, $In3Port, $In3Text)
    SaveStep($profile, 4, $CBO4, $In4Port, $In4Text)

    $g_SelectedProfile = $profile

    LoadProfiles()

    LoadProfile($profile)

    GUICtrlSetData( _
        $LBLStatus, _
        "Saved: " & $profile _
    )

EndFunc


; ============================================================
; SAVE ONE STEP
; ============================================================

Func SaveStep($profile, $number, $combo, $portInput, $textInput)

    Local $type
    Local $port
    Local $text

    $type = GUICtrlRead($combo)
    $port = GUICtrlRead($portInput)
    $text = GUICtrlRead($textInput)

    IniWrite( _
        $CONFIG_FILE, _
        $profile, _
        "Type" & $number, _
        $type _
    )

    IniWrite( _
        $CONFIG_FILE, _
        $profile, _
        "Port" & $number, _
        $port _
    )

    IniWrite( _
        $CONFIG_FILE, _
        $profile, _
        "Text" & $number, _
        $text _
    )

EndFunc


; ============================================================
; DELETE CURRENT PROFILE
; ============================================================

Func DeleteCurrentProfile()

    Local $profile
    Local $answer
    Local $newCount
    Local $newNames[1]
    Local $i

    $profile = StringStripWS( _
        GUICtrlRead($InDesc), _
        3 _
    )

    If $profile = "" Then
        Return
    EndIf

    $answer = MsgBox( _
        36, _
        "Delete", _
        "Delete profile '" & $profile & "'?" _
    )

    If $answer <> 6 Then
        Return
    EndIf

    ; --------------------------------------------------------
    ; Delete profile section
    ; --------------------------------------------------------

    IniDelete($CONFIG_FILE, $profile)

    ; --------------------------------------------------------
    ; Build new profile list
    ; --------------------------------------------------------

    $newCount = 0

    For $i = 1 To $g_ConfigCount

        If $g_ProfileNames[$i] <> "" Then

            If $g_ProfileNames[$i] <> $profile Then

                $newCount += 1

                ReDim $newNames[$newCount + 1]

                $newNames[$newCount] = _
                    $g_ProfileNames[$i]

            EndIf

        EndIf

    Next

    ; --------------------------------------------------------
    ; Delete old profile names
    ; --------------------------------------------------------

    For $i = 1 To $g_ConfigCount

        IniDelete( _
            $CONFIG_FILE, _
            "Profiles", _
            "Name" & $i _
        )

    Next

    ; --------------------------------------------------------
    ; Save new profile list
    ; --------------------------------------------------------

    $g_ConfigCount = $newCount

    ReDim $g_ProfileNames[$g_ConfigCount + 1]

    IniWrite( _
        $CONFIG_FILE, _
        "Profiles", _
        "Count", _
        $g_ConfigCount _
    )

    For $i = 1 To $g_ConfigCount

        $g_ProfileNames[$i] = $newNames[$i]

        IniWrite( _
            $CONFIG_FILE, _
            "Profiles", _
            "Name" & $i, _
            $g_ProfileNames[$i] _
        )

    Next

    ; --------------------------------------------------------
    ; Refresh GUI
    ; --------------------------------------------------------

    LoadProfiles()

    ClearFields()

    $g_SelectedProfile = ""

    GUICtrlSetData( _
        $LBLStatus, _
        "Profile deleted" _
    )

EndFunc


; ============================================================
; CLEAR FIELDS
; ============================================================

Func ClearFields()

    GUICtrlSetData($InDesc, "")
    GUICtrlSetData($InIP, "")

    GUICtrlSetData($CBO1, "TCP")
    GUICtrlSetData($In1Port, "")
    GUICtrlSetData($In1Text, "")

    GUICtrlSetData($CBO2, "None")
    GUICtrlSetData($In2Port, "")
    GUICtrlSetData($In2Text, "")

    GUICtrlSetData($CBO3, "None")
    GUICtrlSetData($In3Port, "")
    GUICtrlSetData($In3Text, "")

    GUICtrlSetData($CBO4, "None")
    GUICtrlSetData($In4Port, "")
    GUICtrlSetData($In4Text, "")

EndFunc


; ============================================================
; COMPLETE KNOCK
; ============================================================

Func PerformKnock()

    Local $ip

    $ip = StringStripWS( _
        GUICtrlRead($InIP), _
        3 _
    )

    If $ip = "" Then

        MsgBox( _
            48, _
            "Error", _
            "Server IP is empty." _
        )

        Return

    EndIf

    GUICtrlSetData( _
        $LBLStatus, _
        "Sending knock..." _
    )

    ; --------------------------------------------------------
    ; STEP 1
    ; --------------------------------------------------------

    If Not PerformStep( _
        $ip, _
        $CBO1, _
        $In1Port, _
        $In1Text _
    ) Then

        Return

    EndIf

    Sleep(300)

    ; --------------------------------------------------------
    ; STEP 2
    ; --------------------------------------------------------

    If GUICtrlRead($CBO2) <> "None" Then

        If Not PerformStep( _
            $ip, _
            $CBO2, _
            $In2Port, _
            $In2Text _
        ) Then

            Return

        EndIf

        Sleep(300)

    EndIf

    ; --------------------------------------------------------
    ; STEP 3
    ; --------------------------------------------------------

    If GUICtrlRead($CBO3) <> "None" Then

        If Not PerformStep( _
            $ip, _
            $CBO3, _
            $In3Port, _
            $In3Text _
        ) Then

            Return

        EndIf

        Sleep(300)

    EndIf

    ; --------------------------------------------------------
    ; STEP 4
    ; --------------------------------------------------------

    If GUICtrlRead($CBO4) <> "None" Then

        If Not PerformStep( _
            $ip, _
            $CBO4, _
            $In4Port, _
            $In4Text _
        ) Then

            Return

        EndIf

    EndIf

    GUICtrlSetData( _
        $LBLStatus, _
        "Knock complete: " & $ip _
    )

EndFunc


; ============================================================
; ONE KNOCK STEP
; ============================================================

Func PerformStep($ip, $combo, $portInput, $textInput)

    Local $type
    Local $port
    Local $text

    $type = GUICtrlRead($combo)

    $port = StringStripWS( _
        GUICtrlRead($portInput), _
        3 _
    )

    $text = GUICtrlRead($textInput)

    ; --------------------------------------------------------
    ; NONE
    ; --------------------------------------------------------

    If $type = "None" Then
        Return True
    EndIf

    ; --------------------------------------------------------
    ; PORT EMPTY
    ; --------------------------------------------------------

    If $port = "" Then

        MsgBox( _
            48, _
            "Error", _
            "Port is empty." _
        )

        Return False

    EndIf

    ; --------------------------------------------------------
    ; SHOW STATUS
    ; --------------------------------------------------------

    GUICtrlSetData( _
        $LBLStatus, _
        "Knocking " & $ip & ":" & $port _
    )

    ; --------------------------------------------------------
    ; TCP
    ; --------------------------------------------------------

    If $type = "TCP" Then

        TCPKnock($ip, $port)

    ; --------------------------------------------------------
    ; UDP
    ; --------------------------------------------------------

    ElseIf $type = "UDP" Then

        UDPKnock($ip, $port, $text)

    Else

        MsgBox( _
            48, _
            "Error", _
            "Unknown protocol: " & $type _
        )

        Return False

    EndIf

    Return True

EndFunc


; ============================================================
; TCP KNOCK
; ============================================================

Func TCPKnock($ip, $port)

    Local $socket

    $socket = TCPConnect( _
        $ip, _
        Number($port) _
    )

    If $socket <> -1 Then

        TCPCloseSocket($socket)

    EndIf

EndFunc


; ============================================================
; UDP KNOCK
; ============================================================

Func UDPKnock($ip, $port, $text)

    Local $socket

    $socket = UDPOpen( _
        $ip, _
        Number($port) _
    )

    If $socket <> -1 Then

        UDPSend( _
            $socket, _
            $text _
        )

        UDPCloseSocket($socket)

    EndIf

EndFunc