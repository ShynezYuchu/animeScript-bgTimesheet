--Anime BG Timesheet
--author: shynez.com
--version 2.0
fileIn "SHYNEZ_TR_Util.ms"

if Util_IsScriptUIOpen "SHYNEZ_TR_BGTimesheet" do (
	return print "The script instance is already open.\nTry Execute This Script: \nUtil_DeleteScriptUIOpenState \"SHYNEZ_TR_BGTimesheet\"\n"
)
Util_AddScriptUIOpenState "SHYNEZ_TR_BGTimesheet"


Tcb
fn TimeCb = (
	-- print "fn: TimeCb"
	if isValidNode $BGTimesheetData and getUserProp $BGTimesheetData (sliderTime as string) != undefined do (
		bgBitmap = openBitMap (getUserProp $BGTimesheetData (sliderTime as string))
		setAsBackground bgBitmap
		renderWidth = bgBitmap.width
		renderHeight = bgBitmap.height
		setBkgImageAspect #output
		displaySafeFrames = true
		actionMan.executeAction 0 "620"
	)
)
fn Tcb = TimeCb()
unRegisterTimeCallback Tcb
registerTimeCallback Tcb

fn strCompareFN s1 s2 = (
	local int1 = (filterString s1 " >> ")[1] as integer
	local int2 = (filterString s2 " >> ")[1] as integer
	case of (
		(int1 < int2): -1
		(int1 > int2): 1
		default: 0
	)
)

SHYNEZ_TR_BGTimesheet

upBufferArray
fn GetSplitBgKeyString origin = (
	tmpString = ""
	leftRightSplit = filterString origin "f = "
	if leftRightSplit[1].count == 1 then tmpString = "  " else if leftRightSplit[1].count == 2 then tmpString = " "
	pathFolderSplit = filterString leftRightSplit[2] "\\"
	tmpString += leftRightSplit[1] + " >> " + pathFolderSplit[pathFolderSplit.count]
	tmpString
)

fn RefreshBgKeyListBox = (
	if isValidNode $BGTimesheetData do (
		upBuffer = getUserPropBuffer $BGTimesheetData
		upBufferArray = filterString upBuffer "\r\n"
		
        SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items = #()
		for i = 1 to upBufferArray.count do (
            tmpString = GetSplitBgKeyString upBufferArray[i]
			SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items = append SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items tmpString
		)
		qsort SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items StrCompareFN
		SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items = SHYNEZ_TR_BGTimesheet.bg_keys_listbox.items
	)
)

fn DeleteBgKey = (
	if isValidNode $BGTimesheetData do (
		upBuffer = getUserPropBuffer $BGTimesheetData
		upBufferArray = filterString upBuffer "\r\n"
		
		upBuffer = ""
		for i = 1 to upBufferArray.count do (
			tmpString = GetSplitBgKeyString upBufferArray[i]
			print (findString tmpString SHYNEZ_TR_BGTimesheet.bg_keys_listbox.selected != undefined)
			if findString tmpString SHYNEZ_TR_BGTimesheet.bg_keys_listbox.selected != undefined do (
				deleteItem upBufferArray i
				--delete (getNodeByName SHYNEZ_TR_BGTimesheet.bg_keys_listbox.selected)
				exit
			)
		)
		for i = 1 to upBufferArray.count do (
			append upBuffer (upBufferArray[i] + "\r\n")
		)
		setUserPropBuffer $BGTimesheetData upBuffer
		RefreshBgKeyListBox()
	)
)

rollout SHYNEZ_TR_BGTimesheet "BG Timesheet 2.1.1" (
	button delete_bg_key_btn "删除背景帧" width:100 height:34 across:2
	button clear_all_btn "清空" height:34 width:60
	
	listBox bg_keys_listbox "背景帧列表" height:16
	
	button add_bg_key_btn "添加" width:60 height:40 across:3
	button pre_bg_key_btn "<<" width:40 height:40
	button next_bg_key_btn ">>" width:40 height:40
	checkbox enable_callback "启用时间轴滑块监听" checked:true
	
	Label author "Author" align:#left across:2
	hyperLink authorLink "shynez语出" color:red hoverColor:red visitedColor:green address:"http://shynez.com/" align:#right

	on delete_bg_key_btn pressed do (
		DeleteBgKey()
	)
	
	on clear_all_btn pressed do (
		if isValidNode $BGTimesheetData do (
			setUserPropBuffer $BGTimesheetData ""
			RefreshBgKeyListBox()

			actionMan.executeAction 0 "617"
		)
	)
	
	on bg_keys_listbox doubleClicked itm do (
		sliderTime = (filterString bg_keys_listbox.selected " >> ")[1] as integer
	)
	
	on pre_bg_key_btn pressed do (
		local index = findItem bg_keys_listbox.items bg_keys_listbox.selected
		if index > 1 do (
			sliderTime = (filterString bg_keys_listbox.items[index - 1] " >> ")[1] as integer
			bg_keys_listbox.selection = index - 1
		)
		
	)
	on next_bg_key_btn pressed do (
		local index = findItem bg_keys_listbox.items bg_keys_listbox.selected
		if index > 0 and index < bg_keys_listbox.items.count do (
			sliderTime = (filterString bg_keys_listbox.items[index + 1] " >> ")[1] as integer
			bg_keys_listbox.selection = index + 1
		)
		
	)
	
	on add_bg_key_btn pressed do (
		renderSceneDialog.close()
		
		if not isValidNode $BGTimesheetData do (
			Point name:"BGTimesheetData" cross:false box:true constantscreensize:true drawontop:true
			freeze $BGTimesheetData
		)
		
		global f = getOpenFileName caption:"Select an image" types:"JPG(*.jpg)|*.jpg|PNG(*.png)|*.png|TGA(*.tga)|*.tga|BMP(*.bmp)|*.bmp|"
		if f != undefined do (
			bgBitmap = openBitMap f
			setAsBackground bgBitmap
			renderWidth = bgBitmap.width
			renderHeight = bgBitmap.height
			setBkgImageAspect #output
			displaySafeFrames = true
			actionMan.executeAction 0 "620"
			
			setUserProp $BGTimesheetData (sliderTime as string) f
			
			RefreshBgKeyListBox()
		)
	)

	on enable_callback changed value do (
		unRegisterTimeCallback Tcb
		if enable_callback.checked do registerTimeCallback Tcb
	)

    -- end of
	on SHYNEZ_TR_BGTimesheet open do (
		RefreshBgKeyListBox()
	)
	on SHYNEZ_TR_BGTimesheet close do (
        unRegisterTimeCallback Tcb
        Util_DeleteScriptUIOpenState "SHYNEZ_TR_BGTimesheet"
	)
)

createDialog SHYNEZ_TR_BGTimesheet width:220 height:340 pos:[300,285] style:#(#style_titlebar, #style_border, #style_sysmenu)

cui.RegisterDialogBar SHYNEZ_TR_BGTimesheet