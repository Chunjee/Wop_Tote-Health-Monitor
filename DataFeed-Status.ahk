﻿;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Renames FreePPs pdf files; then generates html for use with the normal FreePPs process.



;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
StartUp()
Version = v0.6

;Dependencies
#Include %A_ScriptDir%\Functions
#Include inireadwrite
#Include internet_fileread

;For Debug Only
#Include util_arrays

;Included Files
Sb_InstallFiles()

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Sb_GlobalNameSpace()


;The_Settings = %A_ScriptDir%\settings.ini
;Fn_InitializeIni(The_Settings)
;Fn_LoadIni(The_Settings)



GUI_x := 24
GUI_y1 := 20
GUI_y2 := 36

Loop, Read, %A_ScriptDir%\datafeed_dirs.txt
{
CurrentDir := A_LoopReadLine
	RegExMatch(CurrentDir, "\\\\(.+)\\", RE_Dir)
	If (RE_Dir1 != "")
	{
	The_SystemName := RE_Dir1
	StringUpper, The_SystemName, The_SystemName
	}





AllFiles_Array[A_Index,"Server"] := The_SystemName
Sb_UpdatePath()
AllFiles_Array[A_Index,"NotGrowingCounter"] := 0



;GUI Stuffs
GUI_y1 += 50 ;Box
GUI_y2 += 50 ;Text
GUI_y3 := GUI_y2 - 3 ;Image
Gui, Add, GroupBox, x6 y%GUI_y1% w310 h40, %The_SystemName%
Gui, Add, Text, x16 y%GUI_y2% w30 h20 vGUI_Time%A_Index%,
Gui, Add, Text, x90 y%GUI_y2% w40 h20 +Right vGUI_OldSize%A_Index%,
Gui, Add, Text, x136 y%GUI_y2% w130 h20 vGUI_Size%A_Index%,
Gui, Add, Picture, x230 y%GUI_y3% vGUI_Image%A_Index%, %A_ScriptDir%\Data\alf.png
}

Loop, Read, %A_ScriptDir%\TPAS_dirs.txt
{
;Split data from each line in file
;CODE



GUI_y1 += 50 ;Box
GUI_y2 += 50 ;Text
GUI_y3 := GUI_y2 + 20

	StringSplit, TPASdata_short, A_LoopReadLine, #,
	The_TPASName := Fn_QuickRegEx(TPASdata_short2,"\/\/(.+):")
	StringUpper, The_TPASName, The_TPASName

	TPAS_Array[A_Index,"Name"] := The_TPASName
	TPAS_Array[A_Index,"XML"] := TPASdata_short1
	TPAS_Array[A_Index,"HTML"] := TPASdata_short2

Gui, Font, s14, Arial
Gui, Add, Text, x20 y%GUI_y2% vGUI_TPASTime%A_Index%, 00:00
;Gui, Add, Text, x20 y%GUI_y3% vGUI_TPASSession%A_Index%, 000
Gui, Font, s10, Arial

Gui, Add, GroupBox, x6 y%GUI_y1% w310 h80 vGUI_TPASSession%A_Index%, % "TPAS   " . TPAS_Array[A_Index,"Name"]
Gui, Add, Text, x146 y%GUI_y2% w80 h20 +Right, Load
Gui, Add, Progress, x230 y%GUI_y2% w80 h14 vGUI_TPASLoad%A_Index%, 100
Gui, Add, Text, x146 y%GUI_y3% w80 h20 +Right, Latency
Gui, Add, Progress, x230 y%GUI_y3% w80 h14 vGUI_TPASLatency%A_Index%, 100
GUI_y3 := GUI_y2 + 40
Gui, Add, Text, x146 y%GUI_y3% w80 h20 +Right, Transactions
Gui, Add, Progress, x230 y%GUI_y3% w80 h14 vGUI_TPASTransactions%A_Index%, 100

GUI_y1 += 42 ;Box
GUI_y2 += 42 ;Text
}

GUI_Build()
;MSgbox, akf

;UnComment to see whats in the array
;Array_Gui(AllFiles_Array)
;Array_Gui(TPAS_Array)

SetTimer, CheckFiles, -1
SetTimer, CheckTPAS, -1
SetTimer, CheckTPASSession, -1
Sleep 400

SetTimer, CheckFiles, 90000
SetTimer, CheckTPASSession, 90000
SetTimer, CheckTPAS, 9000


Return




CheckTPAS:
Loop % TPAS_Array.MaxIndex()
{
DownloadXML := TPAS_Array[A_Index,"XML"]
;Download file and read to Variable. Note that the text file is all one line so don't try to loop read a line at a time
UrlDownloadToFile, %DownloadXML% , % A_ScriptDir . "\Data\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"
FileRead, FileContents, % A_ScriptDir . "\Data\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"

;Scan for each arrays value and assign
TPAS_Array[A_Index,"TFATimestamp"] := Fn_QuickRegEx(FileContents,"(\d\d:\d\d):\d\d<\/TFATimestamp>")
TPAS_Array[A_Index,"TotalTransactions"] := Fn_QuickRegEx(FileContents,"<TotalTransactions>(.*)<\/TotalTransactions>")
TPAS_Array[A_Index,"MaxTransRate"] := Fn_QuickRegEx(FileContents,"<MaxTransRate>(.*)<\/MaxTransRate>")
TPAS_Array[A_Index,"CurrentTransRate"] := Fn_QuickRegEx(FileContents,"<CurrentTransRate>(.*)<\/CurrentTransRate>")
TPAS_Array[A_Index,"TransQueueLen"] := Fn_QuickRegEx(FileContents,"<TransQueueLen>(.*)<\/TransQueueLen>")
TPAS_Array[A_Index,"ToteTimestamp"] := Fn_QuickRegEx(FileContents,"(\d\d:\d\d):\d\d<\/ToteTimestamp>")
TPAS_Array[A_Index,"LastSeqNo"] := Fn_QuickRegEx(FileContents,"<LastSeqNo>(.*)<\/LastSeqNo>")
TPAS_Array[A_Index,"saveTotalTrans"] := Fn_QuickRegEx(FileContents,"<saveTotalTrans>(.*)<\/saveTotalTrans>")
TPAS_Array[A_Index,"maxLoadRate"] := Fn_QuickRegEx(FileContents,"<maxLoadRate>(.*)<\/maxLoadRate>")
TPAS_Array[A_Index,"CurrentLoadRate"] := Fn_QuickRegEx(FileContents,"<CurrentLoadRate>(.*)<\/CurrentLoadRate>")
TPAS_Array[A_Index,"maxLatency"] := Fn_QuickRegEx(FileContents,"<maxLatency>(.*)<\/maxLatency>")
TPAS_Array[A_Index,"avgLatency"] := Fn_QuickRegEx(FileContents,"<avgLatency>(.*)<\/avgLatency>")


;View Array
;Array_Gui(TPAS_Array)

guicontrol, Text, GUI_TPASTime%A_Index%, % TPAS_Array[A_Index,"TFATimestamp"]

The_LoadPercent := (TPAS_Array[A_Index,"CurrentLoadRate"] / TPAS_Array[A_Index,"maxLoadRate"]) * 100
The_LoadPercent := Fn_PercentCheck(The_LoadPercent)
GuiControl,, GUI_TPASLoad%A_Index%, %The_LoadPercent%

The_LatencyPercent := (TPAS_Array[A_Index,"avgLatency"] / (TPAS_Array[A_Index,"maxLatency"] * 10)) * 100
The_LatencyPercent := Fn_PercentCheck(The_LatencyPercent)
GuiControl,, GUI_TPASLatency%A_Index%, %The_LatencyPercent%

The_TransactionsPercent := ((TPAS_Array[A_Index,"CurrentTransRate"]) / 300) * 100 ; TPAS_Array[A_Index,"MaxTransRate"] substituted for 300 as a test
The_TransactionsPercent := Fn_PercentCheck(The_TransactionsPercent)
GuiControl,, GUI_TPASTransactions%A_Index%, %The_TransactionsPercent%
}
Return



;Session Number STUFF
CheckTPASSession:
Loop % TPAS_Array.MaxIndex()
{
DownloadHTML := TPAS_Array[A_Index,"HTML"]
UrlDownloadToFile, %DownloadHTML% , % A_ScriptDir . "\Data\" . TPAS_Array[A_Index,"Name"] . "_HTML.txt"
FileRead, FileContents2, % A_ScriptDir . "\Data\" . TPAS_Array[A_Index,"Name"] . "_HTML.txt"
TPAS_Array[A_Index,"SessionNumber"] := Fn_QuickRegEx(FileContents2,"SESSION # \[ (\d*) \]")
guicontrol, Text, GUI_TPASSession%A_Index%, % TPAS_Array[A_Index,"Name"] . "      #" . TPAS_Array[A_Index,"SessionNumber"]
}
Return


CheckFiles:

;Loop for each system in the array
AllFiles_ArraX := AllFiles_Array.MaxIndex()
Loop % AllFiles_Array.MaxIndex()
{
;Update Todays Variable to check todays datafile
Sb_UpdatePath()


The_Dir := AllFiles_Array[A_Index,"FileDir"]

;Get Modified Time and assign it to the Array
AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(The_Dir)

;Get File Size and assign it to the Array
AllFiles_Array[A_Index,"Size"] := Fn_DataFileInfoSize(The_Dir)

	;Convert to MB for display GUI
	GUI_FileSizeMB := AllFiles_Array[A_Index,"Size"] / 1024
	StringTrimRight, GUI_FileSizeMB, GUI_FileSizeMB, 7

guicontrol, Text, GUI_Time%A_Index%, % AllFiles_Array[A_Index,"NewCheck"]
guicontrol, Text, GUI_Size%A_Index%, % AllFiles_Array[A_Index,"Size"] . "  (" . GUI_FileSizeMB . "MB)"

	;If the Filesize is the same as last time it was checked
	If (AllFiles_Array[A_Index,"LastCheck"] = AllFiles_Array[A_Index,"Size"])
	{
	;Then increment the Counter for not growing
	AllFiles_Array[A_Index,"NotGrowingCounter"] += 1
	}
	Else ;It is growing, Reset Counter to zero
	{
	AllFiles_Array[A_Index,"NotGrowingCounter"] := 0
	}

	;Set the color of the GUI picture
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 0) ;Green
	{
	ChosenImage := 0
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 1) ;Yellow
	{
	ChosenImage := 1
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 2) ;Orange
	{
	ChosenImage := 2
	Sb_FlashGUI() ; Flash the icon if it hasn't grown in this long
	Sb_EmailOps() ; An Empty function
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] >= 3) ;Red
	{
	ChosenImage := 3
	Sb_FlashGUI() ; Flash the icon if it hasn't grown in this long
	}

GuiControl,, GUI_Image%A_Index%, %A_ScriptDir%\Data\%ChosenImage%.png

AllFiles_Array[A_Index,"LastCheck"] := AllFiles_Array[A_Index,"Size"]
}
;UnComment to see whats in the array
;Array_Gui(AllFiles_Array)
Return





GuiClose:
ExitApp, 1





;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

Fn_QuickRegEx(para_Input,para_RegEx)
{
	RegExMatch(para_Input, para_RegEx, RE_Match)
	If (RE_Match1 != "")
	{
	Return %RE_Match1%
	}
Return "null"
}


Fn_PercentCheck(para_Input)
{
para_Input := Ceil(para_Input)
;Msgbox, %para_Input%
	If (para_Input >= 100)
	{
	Return 100
	}
	If (para_Input <= 1)
	{
	Return 1
	}
Return %para_Input%
}


;UNUSED
Fn_TPASArrayInsert(para_TPASIndex,para_Readline)
{
global TPAS_Array
;Example Input: <TFATimestamp>08/24/2014 09:17:50</TFATimestamp>
	;Grab what the Tag is
	RegExMatch(para_Readline, "<(\w*)>", RE_Tag)
	If (RE_Tag1 != "")
	{
	l_XMLElement := RE_Tag1
		;Grab Everything within the tag
		RegExMatch(para_Readline, ">(.*)<", RE_Value)
		If (RE_Value1 != "")
		{
		;Put it into the Array. Note that para_TPASIndex is the Index value assigned to each TPAS
		TPAS_Array[para_TPASIndex,l_XMLElement] := RE_Value1
		}
	}
}


Fn_CheckDataFile(para_FileDir)
{
global

AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(para_File)

}


Fn_DataFileInfoTime(para_File)
{
l_FileModified := 
FileGetTime, l_FileModified, %para_File%, M
	If (l_FileModified != "")
	{
	FormatTime, l_FileModified, %l_FileModified%, h:mm
	Return %l_FileModified%
	}
Return "ERROR"
}


Fn_DataFileInfoSize(para_File)
{
l_FileSize := ;MakeThis Variable Empty

;Check the size of the file specified in the Function argument/option
FileGetSize, l_FileSize, %para_File%, k

	;If the filesize is NOT blank
	If (l_FileSize != "")
	{
	;Exit the Function with the value of the filesize
	Return %l_FileSize%
	}
;filesize was blank or not understood. Return the word "ERROR"
Return "ERROR"
}




;/--\--/--\--/--\--/--\--/--\
; Subroutines
;\--/--\--/--\--/--\--/--\--/

;No Tray icon because it takes 2 seconds; Do not allow running more then one instance at a time
StartUp() {
#NoTrayIcon
#SingleInstance force
}


Sb_GlobalNameSpace() {
global

The_FancyName := "Tote Health Monitor"

AllFiles_Array := {Server:"", FileDir:"", Size:"", NewCheck:"", LastCheck:"", NotGrowingCounter: "", Result:""}
AllFiles_ArraX = 0

TPAS_Array := {Name:"", XML:"", HTML:"", SessionNumber:"", TFATimestamp:"", LastTFA:"", TotalTransactions:"", MaxTransRate:"", CurrentTransRate:"", TransQueueLen:"", ToteTimestamp:"", LastSeqNo:"", saveTotalTrans:"", maxLoadRate:"", CurrentLoadRate:"", maxLatency:"", avgLatency:"", tpas_stats:"Not Used"}
}


Sb_InstallFiles()
{
FileCreateDir, %A_ScriptDir%\Data\
FileInstall, Data\0.png, %A_ScriptDir%\Data\0.png, 1
FileInstall, Data\1.png, %A_ScriptDir%\Data\1.png, 1
FileInstall, Data\2.png, %A_ScriptDir%\Data\2.png, 1
FileInstall, Data\3.png, %A_ScriptDir%\Data\3.png, 1
}

Sb_EmailOps()
{
;Currently Does nothing
}

Sb_UpdatePath()
{
global
FormatTime, The_Today, %A_Now%, MM-dd-yyyy

	Loop % AllFiles_Array.MaxIndex()
	{
	The_Server := AllFiles_Array[A_Index,"Server"]
	
	FullPath = \\%The_Server%\LogFiles\%The_Today%\SGRData%The_Today%.txt
	AllFiles_Array[A_Index,"FileDir"] := FullPath
	}

}


Sb_FlashGUI()
{
SetTimer, FlashGUI, -1000
Return
FlashGUI:

	Loop, 6
	{
	Gui Flash
	Sleep 500  ;Do not change this value
	}
Return
}


GUI_Build()
{
global

GUI_AOT := 1
Gui +AlwaysOnTop

;Title
Gui, Font, s14 w70, Arial
Gui, Add, Text, x2 y4 w330 h40 +Center, %The_FancyName%
Gui, Font, s10 w70, Arial
Gui, Add, Text, x276 y0 w50 h20 +Right, %Version%

;Gui, Add, CheckBox, x30 y30 Checked1 gSwitchOnOff, Always On Top

;Gui, Add, Text, x10 y50, |-Modified-|
;Gui, Add, Text, x96 y50, |-FileSize-|
Gui, Add, Text, x230 y50, |-----Status-----|


;Menu
Menu, FileMenu, Add, &Update Now, CheckFiles
Menu, FileMenu, Add, Window &Always Top, SwitchOnOff
Menu, FileMenu, Add, R&estart`tCtrl+R, Menu_File-Restart
Menu, FileMenu, Add, E&xit`tCtrl+Q, Menu_File-Exit
Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the sub-menu that was created above
Menu, FileMenu, Check, Window &Always Top
;Menu, Default , FileMenu

Menu, HelpMenu, Add, &About, Menu_About
Menu, HelpMenu, Add, &Confluence`tCtrl+H, Menu_Confluence
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, Menu, MyMenuBar

;Create the final size of the GUI
GUI_y2 += 40
Gui, Show, h%GUI_y2% w330, %The_FancyName%
Return

;Menu Shortcuts
Menu_Confluence:
Run http://confluence.tvg.com/display/wog/Ops+Tool+-+Tote+Health+Monitor
Return

Menu_About:
Msgbox, Checks that the SGRDataFeed file is growing or exists yet.
Return

SwitchOnOff:
If (GUI_AOT = 0)
{
Gui +AlwaysOnTop
GUI_AOT := 1
Menu, FileMenu, Check, Window &Always Top
}
else
{
Gui -AlwaysOnTop
GUI_AOT := 0
Menu, FileMenu, UnCheck, Window &Always Top
}
gui, submit, NoHide
Return

Menu_File-Restart:
Reload
Menu_File-Exit:
ExitApp
}