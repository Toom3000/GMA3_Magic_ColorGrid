--[[
Magic_ColorGrid v1.0.0.0

MIT License

Copyright 2020 Thomas Baumann

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
--]]

local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

_DEBUG = false

if _DEBUG == true then
	function Cmd(a)
	end

	function Confirm(a,b)
		return true
	end

	function Printf(a)
	end

	function Echo(a)
	end

	function GetTokenName(a)
	end
	
	function DataPool(a)
	end

	function PopupInput(a,b,c)
		return 1,"Install ColorGrid"
	end
end

-- Some wrappers to the internal functions
local C = Cmd
local Printf = Printf
local Echo = Echo

-- Some kind of version string
local cColorGridVersionText = "Magic ColorGrid by Toom"

local cGridTypeMacro = "macro"
local cGridTypeLabel = "label"

-- Main parameters structure
local gParams = {
	mVar = {
		mDelaytimeName = "CG_DELAYTIME",
		mDelaytimeDefaultVal = "0",
		mFadetimeName = "CG_FADETIME",
		mFadetimeDefaultVal = "0",
		mDelayDirStateNamePrefix = "CG_DELAYDIR_STATE_GROUP_",
		mDelayDirStateMaxNo = 0,
		mColorValStateNamePrefix = "CG_COLORVAL_STATE_GROUP_",
		mColorValStateMaxNo = 0,
		mColorExecModeName = "CG_COLOREXEC_MODE",
		mColorExecModeDefaultVal = "direct",
		mSeqInvalidOffsetName = "CG_MACROINVALID_OFFSET",
		mSeqInvalidOffsetNameValActive = 10000,
		mSeqInvalidOffsetNameValInactive = 0,
	},
	mGroup = {
		mMaxCheckNo = 128,
		mCurrentGroupNo = 0,
		mGroups = {
		},
	},
	mImage = {
		mBaseExecNo = 2000,
		mBaseStorageNo = 0,
		mBaseStorageCurrentPos = 0,
		mGridItemInactiveNo,
		mGridItemActiveNo,
		mGridItemAllNo,
		mDelayLeftInactiveNo,
		mDelayRightInactiveNo,
		mDelayInOutInactiveNo,
		mDelayOutInInactiveNo,
		mDelayOffInactiveNo,
		mDelayLeftActiveNo,
		mDelayRightActiveNo,
		mDelayInOutActiveNo,
		mDelayOutInActiveNo,
		mDelayOffActiveNo,
	},
	mAppearance = {
		mBaseNo = 2000,
	},
	mPreset = {
		mBaseNo = 2000,
	},
	mSequence = {
		mBaseNo = 2000,
	},
	mMacro = {
		mBaseNo = 2000,
		mWaitTime = "0.1",
		mDelayWaitTime = "0.2",
		mDelayOffMacroNo = 0,
		mAllColorWhiteMacroNo = 0,
		mDelayTimeZeroMacroNo = 0,
		mFadeTimeZeroMacroNo = 0,
		mColorExecModeMacroNo = 0,
	},
	mLayout = {
		mBaseNo = 2000,
		mWidth = 50,
		mHeight = 50,
		mVisibilityObjectName = "off",
		mLayoutName = "Magic ColorGrid",
	},
	mMaxGelNo = 13,
	mMaxDelayMacroNo = 5,
	mMaxDelayTimeNo = 5,
	mColorGrid = {
		mCurrentRowNo = 1;
		mGrid = {
		}
	},
}

-- Gels array
-- Holds the names and the appearance colors in RGB-A
local gMaGels = {
	[1] = {
		mName = "White",
		mColor = "1.00,1.00,1.00,1.00"
	},
	[2] = {
		mName = "Red",
		mColor = "1.00,0.00,0.00,1.00"
	},
	[3] = {
		mName = "Orange",
		mColor = "1.00,0.50,0.00,1.00"
	},
	[4] = {
		mName = "Yellow",
		mColor = "1.00,1.00,0.00,1.00"
	},
	[5] = {
		mName = "Fern Green",
		mColor = "0.50,1.00,0.00,1.00"
	},
	[6] = {
		mName = "Green",
		mColor = "0.00,1.00,0.00,1.00"
	},
	[7] = {
		mName = "Sea Green",
		mColor = "0.00,1.00,0.50,1.00"
	},
	[8] = {
		mName = "Cyan",
		mColor = "0.00,1.00,1.00,1.00"
	},
	[9] = {
		mName = "Lavender",
		mColor = "0.00,0.50,1.00,1.00"
	},
	[10] = {
		mName = "Blue",
		mColor = "0.00,0.00,1.00,1.00"
	},
	[11] = {
		mName = "Violet",
		mColor = "0.50,0.00,1.00,1.00"
	},
	[12] = {
		mName = "Magenta",
		mColor = "1.00,0.00,1.00,1.00"
	},
	[13] = {
		mName = "Pink",
		mColor = "1.00,0.00,0.50,1.00"
	}
}

-- *********************************************************************
-- Shortcut Table for grandMA3 pools
-- *********************************************************************

function getGma3Pools()
    return {
        -- token = PoolHandle
        Sequence        = DataPool().Sequences;
        World           = DataPool().Worlds;
        Filter          = DataPool().Filters;
        Group           = DataPool().Groups;
        Plugin          = DataPool().Plugins;
        Macro           = DataPool().Macros;
        Matricks        = DataPool().Matricks;
        Configuration   = DataPool().Configurations;
        Page            = DataPool().Pages;
        Layout          = DataPool().Layouts;
        Timecode        = DataPool().Timecodes;
        Preset          = DataPool().PresetPools;
        View            = Root().ShowData.UserProfiles.Default.ViewPool;
        Appearance      = Root().ShowData.Appearances;
        Camera          = Root().ShowData.UserProfiles.Default.CameraPool;
        Sound           = Root().ShowData.Sounds;
        User            = Root().ShowData.Users;
        Userprofile     = Root().ShowData.Userprofiles;
        Scribble        = Root().ShowData.ScribblePool;
        ViewButton      = Root().ShowData.UserProfiles.Default.ScreenConfigurations.Default["ViewButtonPages 2"];
        Screencontents  = Root().ShowData.UserProfiles.Default.ScreenConfigurations.Default.ScreenContents;
        Display         = Root().GraphicsRoot.PultCollect["Pult 1"].DisplayCollect;
        DataPool        = Root().ShowData.DataPools;
        Image           = Root().ShowData.ImagePools;
        Fixturetype     = Root().ShowData.LivePatch.FixtureTypes;
    }
end

function log(inText)
	Printf("CG Generator: " .. inText)
end

-- *************************************************************
-- prepare_console
-- *************************************************************

function prepare_console()
    C('cd root')
    C('clearall')
    C('off page *.*; off sequence thru')
    C('unpark fixture thru')
    C('world 1; page 1; filter 1; configuration 1')
    C('select datapool "Default"')
end

-- *************************************************************
-- RegisterGridItem
-- *************************************************************

function RegisterGridItem(inRow,inCol,inX,inY,inWidth,inHeight,inType,inTypeExecNo,inVisibleName)
	myGridItem = {
		mRow = inRow,
		mCol = inCol,
		mX = inX,
		mY = inY,
		mWidth = inWidth,
		mHeight = inHeight,
		mType = inType,
		mTypeExecNo = inTypeExecNo,
		mVisibleName = inVisibleName,
	}
	table.insert(gParams.mColorGrid.mGrid,myGridItem);
end

-- *************************************************************
-- RegisterGroupItem
-- *************************************************************

function RegisterGroupItem(inGroup)
	log("[RegisterGroupItem] Registering group item no " .. inGroup.no .. "(" .. inGroup.name .. ")");
	myGroupItem = {
		mNo = inGroup.no,
		mName = inGroup.name,
		mInclude = false,
	}
	table.insert(gParams.mGroup.mGroups,myGroupItem);
end

-- *************************************************************
-- ImageSetDefault
-- *************************************************************

function ImageCopy(inSourceNo,inTargetNo)
	C("Copy image 'Custom'." .. tostring(inSourceNo) .. " at image 'Custom'." .. tostring(inTargetNo) .. " /o" );
end

-- *************************************************************
-- ImagePrepare
-- *************************************************************

function ImagePrepare(inName,inFileName)
	local myImageNo = gParams.mImage.mBaseStorageCurrentPos;
	if myImageNo == 0 then
		myImageNo = gParams.mImage.mBaseStorageNo;
	end
	log("[ImagePrepare] Handling image no " .. myImageNo );
	C("Delete Image 'Custom'." .. tostring(myImageNo));
	C("Import Image 'Custom'." .. tostring(myImageNo) .. " /File '" .. inFileName .. "' /nc /o" );
	C("set image 'Custom'." ..  tostring(myImageNo) .. " Property \"Name\" \"[" .. inName .. "]\"" );
	gParams.mImage.mBaseStorageCurrentPos = myImageNo + 1;
	return myImageNo;
end

-- *************************************************************
-- getGroupOffset
-- *************************************************************

function getGroupOffset(inGroupNo)
	myGroupNo = tonumber(inGroupNo) or 0
	return myGroupNo * (gParams.mMaxGelNo + gParams.mMaxDelayMacroNo + 1 );
end

-- *************************************************************
-- getSeqNo
-- *************************************************************

function getSeqNo(inNo,inGroupNo)
	return gParams.mSequence.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getMacroNo
-- *************************************************************

function getMacroNo(inNo,inGroupNo)
	return gParams.mMacro.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getPresetNo
-- *************************************************************

function getPresetNo(inNo,inGroupNo)
	return gParams.mPreset.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getAppearanceNo
-- *************************************************************

function getAppearanceNo(inNo,inGroupNo)
	return gParams.mAppearance.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getExecNo
-- *************************************************************

function getExecNo(inNo,inGroupNo)
	return gParams.mImage.mBaseExecNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getImageActiveStorageNo
-- *************************************************************

function getImageActiveStorageNo(inNo,inGroupNo)
	return gParams.mImage.mGridItemActiveNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getImageInactiveStorageNo
-- *************************************************************

function getImageInactiveStorageNo(inNo,inGroupNo)
	return gParams.mImage.mGridItemInactiveNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- initGroupRegister
-- *************************************************************

function initGroupRegister()
	local myPools = getGma3Pools();
	local myGroups = myPools.Group;
	-- Since i have no sense on how to find out how many groups are actually present we 
	-- will check up to mMaxCheckNo groups. That should be sufficient for most applications.
	for myGroupNo=1,gParams.mGroup.mMaxCheckNo,1 do	
		myGroup = myGroups:Ptr(myGroupNo);
		if myGroup ~= nil then
			RegisterGroupItem(myGroup);
		end
	end		
end

-- *************************************************************
-- initGroupRegister
-- *************************************************************

function ParseCSVLine (line,sep) 

end

-- *************************************************************
-- getAllGroupNoAsCsvString
-- *************************************************************

function getAllGroupNoAsCsvString()
	local myResult = ""
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		myNo = myGValue["mNo"];
		if next(gParams.mGroup.mGroups,myGKey) ~= nil then
			myResult = myResult .. myNo .. ",";
		else
			myResult = myResult .. myNo;
		end
	end
	return myResult;
end

-- *************************************************************
-- getAllGroupHandlingState
-- *************************************************************

function setGroupHandlingState(inNo,inState)
	local myResult = false;
	log("[setGroupHandlingState] Setting group " .. inNo .. " to include state " .. tostring(inState));
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		if ( myGValue["mNo"] == inNo ) then
			myGValue["mInclude"] = inState;
			gParams.mGroup.mCurrentGroupNo = gParams.mGroup.mCurrentGroupNo + 1;
			myResult = true;
		end
	end
	return myResult;
end

-- *************************************************************
-- setGroupsForColorGridFromCsv
-- *************************************************************

function setGroupsForColorGridFromCsv(inCsv)
	local myResult = false;
	local myPos = 1
	while true do 
		local myChar = string.sub(inCsv,myPos,myPos)
		if (myChar == "") then 
			break 
		end
		
		local myStart,myEnd = string.find(inCsv,',',myPos)
		if (myStart) then 
			myNo = tonumber(string.sub(inCsv,myPos,myStart-1));
			myResult = setGroupHandlingState(myNo,true);
			myPos = myEnd + 1
		else
			myNo = tonumber(string.sub(inCsv,myPos));
			myResult = setGroupHandlingState(myNo,true);
			myResult = true;
			break
		end 
	end
	return myResult;
end

-- *************************************************************
-- ColorPresetCreate
-- *************************************************************

function ColorPresetCreate(inNo,inGroupNo,inName,inGroupName)
	local myPresetNo = getPresetNo(inNo,inGroupNo);
	log("[ColorPresetCreate] Creating preset no " .. myPresetNo .. " for group " .. inGroupName);
	C("At Gel \"Ma\".\"" .. inName .. "\"" );
	C("Store Preset 'Color'." .. myPresetNo .. " /Selective /o" );
	C("Label Preset 'Color'." .. myPresetNo .. " \"" .. inGroupName.. "(" .. inName .. ")\"" );
end

-- *************************************************************
-- AppearanceCreate
-- *************************************************************

function AppearanceCreate(inNo,inGroupNo,inColor)
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	log("[AppearanceCreate] Creating appearance no " .. myAppearanceNo .." with color \"" .. inColor .. "\"" );
	C("del appearance " .. myAppearanceNo .. "/NC");
	C("store appearance " .. myAppearanceNo);
	C("Set Appearance " .. myAppearanceNo .. " \"Appearance\" \"ShowData.ImagePools.Custom." .. myAppearanceNo .. "\"" );
	C("Set Appearance " .. myAppearanceNo .. " Property \"COLOR\" \"" .. inColor .. "\"" );
	C("Set Appearance " .. myAppearanceNo .. " Property \"ImageMode\" \"Stretch\"" );
end

-- *************************************************************
-- SequenceCreate
-- *************************************************************

function SequenceCreate(inNo,inGroupNo,inName,inGroupName)
	local mySeqNo = getSeqNo(inNo,inGroupNo);
	local myPresetNo = getPresetNo(inNo,inGroupNo);
	log("[SequenceCreate] Creating sequence no " .. mySeqNo .. " for group " .. inGroupName);
	mySeqCmd = "";
	C("At Preset 'Color'." .. myPresetNo);
	C("Delete seq " .. mySeqNo .. "/NC");
	C("Store seq " .. mySeqNo);

	-- Add cmds to handle the images according to the sequence status
	C("set sequence " .. mySeqNo .. " cue 1 Property \"Cmd\" \"" .. mySeqCmd .. "\"" )

	C("Label Sequence " .. mySeqNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
end

-- *************************************************************
-- MacroCreate
-- *************************************************************

function MacroCreate(inNo,inGroupNo,inName,inGroupName)
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local mySeqNo = getSeqNo(inNo,inGroupNo);
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;
	myInactivateText = ""
	log("[MacroCreate] Creating macro no " .. myMacroNo);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Store our current state in a console user variable
	gParams.mVar.mColorValStateMaxNo = inGroupNo;
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo ..	")\" Command \"SetUserVar " .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. " '" .. mySeqNo .. "'\"");

	C("store macro " .. myMacroNo .. " \"GoSeq" .. mySeqNo .. "\" Command \"go+ seq $" .. gParams.mVar.mSeqInvalidOffsetName .. "$" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. "\"");
	for myPos=1,gParams.mMaxGelNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			myInactivateText = myInactivateText .. " image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos);
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. gParams.mImage.mGridItemActiveNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	C("store macro " .. myMacroNo .. " \"InactivateImage \" Command \"copy image 'Custom'." .. gParams.mImage.mGridItemInactiveNo .. " at " .. myInactivateText .. "\"");

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- MacroDelayCreate
-- *************************************************************

function MacroDelayCreate(inNo,inGroupNo,inName,inGroupName)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myPresetStart = getPresetNo(1,inGroupNo);
	local myPresetEnd = myPresetStart + getGroupOffset(1) - 1;
	local myDelayString = "0"
	local myFadeString = "$" .. gParams.mVar.mFadetimeName;
	local myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
	local myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	local myCmdString = ""
	if inName == ">" then
		myDelayString = "0 thru $" .. gParams.mVar.mDelaytimeName
		myActiveStorageNo = gParams.mImage.mDelayRightActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayRightInactiveNo;
	elseif inName == "<" then
		myDelayString = "$" .. gParams.mVar.mDelaytimeName ..  " thru 0"
		myActiveStorageNo = gParams.mImage.mDelayLeftActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo;
	elseif inName == "<>" then
		myDelayString = "$" .. gParams.mVar.mDelaytimeName ..  " thru 0 thru " .. "$" .. gParams.mVar.mDelaytimeName
		myActiveStorageNo = gParams.mImage.mDelayInOutActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayInOutInactiveNo;
	elseif inName == "><" then
		myDelayString = "0 thru $" .. gParams.mVar.mDelaytimeName ..  " thru 0"
		myActiveStorageNo = gParams.mImage.mDelayOutInActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOutInInactiveNo;
	else
		myDelayString = "0"
		myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	end
	log("[MacroDelayCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,"white");

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Store our current state in a console user variable
	gParams.mVar.mDelayDirStateMaxNo = inGroupNo;
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelayDirStateNamePrefix .. gParams.mVar.mDelayDirStateMaxNo .. ")\" Command \"SetUserVar " .. gParams.mVar.mDelayDirStateNamePrefix .. gParams.mVar.mDelayDirStateMaxNo .. " '" .. myMacroNo .. "'\"");

	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"Group '" .. inGroupName .. "'\"");
	myCmdString = "Attribute 'ColorRGB_R' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_G' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_B' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_RY' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_W' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_G' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_UV' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. " Attribute 'ColorRGB_GY' at delay " .. myDelayString .. " at fade " .. myFadeString
	
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"" .. myCmdString ..  "\"");
	-- Unfortunately the behaviour of the different approaches of removing the absolute values changes unpredictably from grandMA3 Release Version to Version.
	-- So this has to be adjusted on every release until they find a convenient solution for this.
	-- C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"off absolute\""); -- This has been working until version 1.4.0.2, after that it knocks out the delay and fade values as well...However, the syntax of the command could be intended to do it this way :)
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"off FeatureGroup 'Color'.'RGB' Absolute\""); -- This seems to work with version 1.4.0.2 and newer, it knocks out the absolute values and keeps the fade and delay values by not touching the other programmer values.
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"store preset 4." .. myPresetStart .. " thru " .. myPresetEnd .. " /m\"");

	for myPos=1,gParams.mMaxDelayMacroNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo) + gParams.mMaxGelNo;
		local myTargetInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo + myPos - 1;
		local myTargetActiveStorageNo =gParams.mImage.mDelayLeftActiveNo + myPos - 1;
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myTargetInactiveStorageNo .. " at image 'Custom'." .. myImagePos .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myTargetActiveStorageNo .. " at image 'Custom'." .. myImagePos .. "\"");
		end
	end

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- MacroDelayCreateAll
-- *************************************************************

function MacroDelayCreateAll(inNo,inName,inMaxGroups)
	local myExecNo = getExecNo(inNo,0);
	local myMacroNo = getMacroNo(inNo,0); 
	local myAppearanceNo = getAppearanceNo(inNo,0);
	local myNewMacroCount = 0;
	local myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
	local myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	if inName == ">" then
		myActiveStorageNo = gParams.mImage.mDelayRightActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayRightInactiveNo;
	elseif inName == "<" then
		myActiveStorageNo = gParams.mImage.mDelayLeftActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo;
	elseif inName == "<>" then
		myActiveStorageNo = gParams.mImage.mDelayInOutActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayInOutInactiveNo;
	elseif inName == "><" then
		myActiveStorageNo = gParams.mImage.mDelayOutInActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOutInInactiveNo;
	else
		myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
		gParams.mMacro.mDelayOffMacroNo = myMacroNo;
	end
	log("[MacroDelayCreateAll] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,0,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Activate all macros that are bound to this delay on all groups
	for myGroupNo=1,inMaxGroups,1 do
		local myExecMacroNo = getMacroNo(inNo,myGroupNo); 
		C("store macro " .. myMacroNo .. " \"GoMacro" .. myExecMacroNo .. "\" Command \"go+ macro " .. myExecMacroNo .. "\"");
		C("set macro " .. myMacroNo .. "." .. myNewMacroCount .. " Property \"wait\" " .. gParams.mMacro.mDelayWaitTime );
		myNewMacroCount = myNewMacroCount + 1;
	end

	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(0,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end


-- *************************************************************
-- MacroColorExecModeCreate
-- *************************************************************

function MacroColorExecModeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroColorExecModeCreate] Creating " .. inName .. " color exec mode macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myInactiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValInactive .. "'; copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. myExecNo .. "; Label macro " .. myMacroNo .. " 'direct'\" Property 'wait' 'Go'");
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValActive   .. "'; copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. myExecNo .. "; Label macro " .. myMacroNo .. " 'manual'\"\" Property 'wait' 'Go'");

	C("Label macro " .. myMacroNo .. " \"direct\"" )
	gParams.mMacro.mColorExecModeMacroNo = myMacroNo;
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- MacroUpdateColor
-- *************************************************************

function MacroUpdateColor(inMacroNo)
	for myGroupNo=1,gParams.mVar.mDelayDirStateMaxNo do
		C("store macro " .. inMacroNo .. " \"GoMacro" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Command \"go+ macro $" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Property \"wait\" " .. gParams.mMacro.mWaitTime );
	end
end

-- *************************************************************
-- MacroGoSeqColor
-- *************************************************************

function MacroGoSeqColor(inMacroNo)
	for myGroupNo=1,gParams.mVar.mDelayDirStateMaxNo do
		C("store macro " .. inMacroNo .. " \"GoSeq" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Command \"go+ seq $" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\"");
	end
end

-- *************************************************************
-- MacroColorExecModeTriggerCreate
-- *************************************************************

function MacroColorExecModeTriggerCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroColorExecModeCreate] Creating " .. inName .. " color exec mode trigger macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myInactiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValInactive .. "'\"");

	C("store macro " .. myMacroNo .. " \"ActivateImage" .. myActiveStorageNo .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. myExecNo .. "\"");
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroGoSeqColor(myMacroNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValActive .. "'\"");
	C("store macro " .. myMacroNo .. " \"InactivateImage" .. myInactiveStorageNo .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. myExecNo .. "\"");

	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,100,nil,200,nil,cGridTypeMacro,myMacroNo,nil);

end

-- *************************************************************
-- MacroUpdateDelayDir
-- *************************************************************

function MacroUpdateDelayDir(inMacroNo)
	for myGroupNo=1,gParams.mVar.mDelayDirStateMaxNo do
		C("store macro " .. inMacroNo .. " \"GoMacro" .. gParams.mVar.mDelayDirStateNamePrefix .. myGroupNo .. "\" Command \"go+ macro $" .. gParams.mVar.mDelayDirStateNamePrefix .. myGroupNo .. "\" Property \"wait\" " .. gParams.mMacro.mDelayWaitTime );
	end
end

-- *************************************************************
-- MacroFadeTimeCreate
-- *************************************************************

function MacroFadeTimeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroFadeTimeCreate] Creating " .. inName .. " fade macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mFadetimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mFadetimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end

	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	if inName == "0" then
		gParams.mMacro.mFadeTimeZeroMacroNo = myMacroNo;
	end
	
	-- Dirty hack due to schedule
	if inName == "0.5s" then
		inName = "1/2s";
	end
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- MacroDelaySwapCreate
-- *************************************************************

function MacroDelaySwapCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroDelaySwapCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- We will read the swap the delaydirs by with the next group
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelaytimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mDelaytimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )

end

-- *************************************************************
-- MacroDelayTimeCreate
-- *************************************************************

function MacroDelayTimeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroDelayTimeCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelaytimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mDelaytimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	if inName == "0" then
		gParams.mMacro.mDelayTimeZeroMacroNo = myMacroNo;
	end
	
	-- Dirty hack due to schedule
	if inName == "0.5s" then
		inName = "1/2s";
	end
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end


-- *************************************************************
-- MacroAllCreate
-- *************************************************************

function MacroAllCreate(inNo,inGroupNo,inName,inMaxGroups)
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;
	local myNewMacroCount = 0;
	log("[MacroAllCreate] Creating macro no " .. myMacroNo);

	if inName == "White" then
		gParams.mMacro.mAllColorWhiteMacroNo = myMacroNo;
	end

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Activate all seqs in advance to speed up the color change and afterwards call the colorchange macro
	for myGroupNo=1,inMaxGroups,1 do
		local myExecSeqNo = getSeqNo(inNo,myGroupNo);
		C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo ..	")\" Command \"SetUserVar " .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. " '" .. myExecSeqNo .. "'\"");
		C("store macro " .. myMacroNo .. " \"GoSeq" .. myExecSeqNo .. "\" Command \"go+ seq $" .. gParams.mVar.mSeqInvalidOffsetName .. "$" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. "\"");
		-- C("store macro " .. myMacroNo .. " \"GoSeq" .. myExecSeqNo .. "\" Command \"go+ seq " .. myExecSeqNo .. "\"");
		myNewMacroCount = myNewMacroCount + 2;
	end
	myNewMacroCount = myNewMacroCount + 1;
	-- Activate all macros that are bound to this color on all groups
	for myGroupNo=1,inMaxGroups,1 do
		local myExecMacroNo = getMacroNo(inNo,myGroupNo); 
		C("store macro " .. myMacroNo .. " \"GoMacro" .. myExecMacroNo .. "\" Command \"go+ macro " .. myExecMacroNo .. "\"");
		C("set macro " .. myMacroNo .. "." .. myNewMacroCount .. " Property \"wait\" " .. gParams.mMacro.mWaitTime );
		myNewMacroCount = myNewMacroCount + 1;
	end

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(inGroupNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- LabelCreate
-- *************************************************************

function LabelCreate(inGroupNo,inName,inX,inY,inWidth,inHeight)
	local pools = getGma3Pools();
	local myMacroNo = getMacroNo(0,inGroupNo);
	local myAppearanceNo = gParams.mAppearance.mBaseNo + getGroupOffset(inGroupNo);
	if inName ~= nil then
		myGroupName = inName;
	else
		-- In this case we will add the group name as label.
		local groups = pools.Group;
		local group = groups:Ptr(inGroupNo);
		myGroupName = group.name;
	end
	log("[LabelCreate] Creating label macro " .. myMacroNo .. " for group no " .. inGroupNo .. "(" .. myGroupName .. ")");
	-- Set default image at execute location
	C("Delete Image 'Custom'." .. gParams.mImage.mBaseExecNo + getGroupOffset(inGroupNo) .. "/NC");
	-- Prepare appearance
	AppearanceCreate(0,inGroupNo,gMaGels[1].mColor);
	-- Create empty macro as label...Workaround since i have no clue how to do it otherwise
	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("Label macro " .. myMacroNo .. " \"" .. myGroupName .. "\"" )
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,0,inX,inY,inWidth,inHeight,cGridTypeMacro,myMacroNo,nil);
	return myMacroNo;
end

-- *************************************************************
-- LabelCreateAll
-- *************************************************************

function LabelCreateAll(inGroupNo)
	local myMacroNo = getMacroNo(0,inGroupNo);
	local myAppearanceNo = gParams.mAppearance.mBaseNo + getGroupOffset(inGroupNo);
	myGroupName = "ALL";
	log("[LabelCreateAll] Creating label macro " .. myMacroNo .. " for group no " .. inGroupNo .. "(" .. myGroupName .. ")");
	-- Set default image at execute location
	C("Delete Image 'Custom'." .. gParams.mImage.mBaseExecNo + getGroupOffset(inGroupNo) .. "/NC");
	-- Prepare appearance
	AppearanceCreate(0,inGroupNo,gMaGels[1].mColor);
	-- Create empty macro as label...Workaround since i have no clue how to do it otherwise
	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("Label macro " .. myMacroNo .. " \"" .. myGroupName .. "\"" )
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);
	RegisterGridItem(inGroupNo,0,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- LayoutItemSetPositionAndSize
-- *************************************************************
function LayoutItemSetPositionAndSize(inLayoutNo,inItemNo,inX,inY,inWidth,inHeight,inVisibleName)
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PosX\" " ..  inX);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PosY\" " ..  inY);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PositionW\" " ..  inWidth);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PositionH\" " ..  inHeight);
	if inVisibleName ~= nil then
		C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"VisibilityObjectName\" " ..  inVisibleName .. " Executor");
	end
end

-- *************************************************************
-- LayoutCreate
-- *************************************************************

function LayoutCreate()
	local myLayoutNo = gParams.mLayout.mBaseNo;
	myLayoutItemNo = 1;
	log("[LayoutCreate] Creating layout no " .. myLayoutNo);
	-- Create Layout view
	C("delete layout " .. myLayoutNo);
	
	for myGKey,myGValue in pairs(gParams.mColorGrid.mGrid) do
		local myHeight = myGValue["mHeight"] or gParams.mLayout.mHeight;
		local myWidth = myGValue["mWidth"] or gParams.mLayout.mWidth;
		local myCol = myGValue["mCol"] or 0;
		local myRow = myGValue["mRow"];
		local myX = myGValue["mX"] or myWidth * myCol;
		local myY = myGValue["mY"] or myHeight * myRow * -1;
		local myType = myGValue["mType"];
		local myTypeExecNo = myGValue["mTypeExecNo"];
		local myVisibleName = myGValue["mVisibleName"];
		log("myX=" .. myX .. " myY=" .. myY .. " myHeight=" .. myHeight .. " myWidth=" .. myWidth .. " myType=" .. myType .. " myTypeExecNo=" .. myTypeExecNo .. " myRow=" .. myRow);
		C("Assign " .. myType .. " " .. myTypeExecNo .. " at layout " .. myLayoutNo);
		LayoutItemSetPositionAndSize(myLayoutNo,myLayoutItemNo,myX,myY,myWidth,myHeight,myVisibleName);
		myLayoutItemNo = myLayoutItemNo + 1;
	end
	
	C("Label layout " .. myLayoutNo .. " \"" .. gParams.mLayout.mLayoutName .. "\"" );
end

-- *************************************************************
-- CreateGridEntry
-- *************************************************************

function CreateGridEntry(inNo,inGroupNo,inGroupName)
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myGelName = gMaGels[inNo].mName;
	local myGelColor = gMaGels[inNo].mColor;
	log("Creating entry no " .. inNo .. "[" .. myGelName .. "] for group " .. inGroupNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,myGelColor);

	-- Create Color Presets
	C("SelFix Group " .. inGroupNo );
	ColorPresetCreate(inNo,inGroupNo,myGelName,inGroupName);

	-- Create sequence from preset
	SequenceCreate(inNo,inGroupNo,myGelName,inGroupName);

	-- Create macros for sequence launch and image replacement
	MacroCreate(inNo,inGroupNo,myGelName,inGroupName);
end

-- *************************************************************
-- CreateGridEntryAll
-- *************************************************************

function CreateGridEntryAll(inNo,inGroupNo,inMaxGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myGelName = gMaGels[inNo].mName;
	local myGelColor = gMaGels[inNo].mColor;
	log("[CreateGridEntryAll] Creating entry no " .. inNo .. "[" .. myGelName .. "] for group " .. inGroupNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,myGelColor);

	-- Create macros for multi sequence launch and image replacement
	MacroAllCreate(inNo,inGroupNo,myGelName,inMaxGroupNo);
end

-- *************************************************************
-- CreateAllGroup
-- *************************************************************

local function CreateAllGroup(inMaxGroupNo)
	log("[CreateAllGroup] Installing group (ALL)");
	local myEntryNoBackup = 0;
	-- Install entries for all colors in our gel
	for myEntryNo=1,gParams.mMaxGelNo do
		CreateGridEntryAll(myEntryNo,0,inMaxGroupNo);
		myEntryNoBackup = myEntryNo;
	end
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"<",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,">",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"<>",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"><",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"off",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	-- Create Label for layout view
	LabelCreateAll(0);
end

-- *************************************************************
-- CreateFadeGroup
-- *************************************************************

local function CreateFadeGroup(inGroupNo)
	log("[CreateFadeGroup] Installing group (Fade)");
	local myNo = 0;
	-- Install fade group macros
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"0",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"0.5s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"1s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"2s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"5s",inGroupNo);
	myNo = myNo + 1;
	-- Create Label for layout view
	LabelCreate(inGroupNo,"Fade");
end

-- *************************************************************
-- CreateDelayGroup
-- *************************************************************

local function CreateDelayGroup(inGroupNo)
	log("[CreateDelayGroup] Installing group (Delay)");
	local myNo = 0;
	-- Install delay group macros
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"0",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"0.5s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"1s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"2s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"5s",inGroupNo);
	myNo = myNo + 1;
	-- Create Label for layout view
	LabelCreate(inGroupNo,"Delay");
end

-- *************************************************************
-- CreateColorExecModeGroup
-- *************************************************************

local function CreateColorExecModeGroup(inGroupNo)
	log("[CreateColorExecModeGroup] Installing group (ColorExecMode)");
	local myNo = 0;
	myNo = myNo + 1;
	MacroColorExecModeCreate(myNo,"Mode",inGroupNo);
	myNo = myNo + 1;
	MacroColorExecModeTriggerCreate(myNo,"Trigger",inGroupNo);	
	LabelCreate(inGroupNo,"ColorExec");
end

-- *************************************************************
-- CreateDelaySwapGroup
-- *************************************************************

local function CreateDelaySwapGroup(inGroupNo)
	log("[CreateDelaySwapGroup] Installing group (DelaySwap)");
	local myNo = 0;
	-- Install delay swap macro
	myNo = myNo + 1;
	MacroDelaySwapCreate(myNo,"SWAP",inGroupNo);
	-- Create Label for layout view
	LabelCreate(inGroupNo,"DelaySwap");
end

-- *************************************************************
-- PrepareImages
-- *************************************************************

local function PrepareImages()
	log("[PrepareImages] Loading images to storage location.");
	gParams.mImage.mGridItemAllNo = ImagePrepare("active","grid_item_active.png.xml");
	gParams.mImage.mGridItemActiveNo = ImagePrepare("active","grid_item_active.png.xml");
	gParams.mImage.mGridItemInactiveNo = ImagePrepare("inactive","grid_item_inactive.png.xml");
	gParams.mImage.mDelayLeftActiveNo = ImagePrepare("delay_left_active","grid_item_delay_left_active.png.xml");
	gParams.mImage.mDelayRightActiveNo = ImagePrepare("delay_right_active","grid_item_delay_right_active.png.xml");
	gParams.mImage.mDelayInOutActiveNo = ImagePrepare("delay_in_out_active","grid_item_delay_in_out_active.png.xml");
	gParams.mImage.mDelayOutInActiveNo = ImagePrepare("delay_out_in_active","grid_item_delay_out_in_active.png.xml");
	gParams.mImage.mDelayOffActiveNo = ImagePrepare("delay_off_active","grid_item_delay_off_active.png.xml");
	gParams.mImage.mDelayLeftInactiveNo = ImagePrepare("delay_left_inactive","grid_item_delay_left_inactive.png.xml");
	gParams.mImage.mDelayRightInactiveNo = ImagePrepare("delay_right_inactive","grid_item_delay_right_inactive.png.xml");
	gParams.mImage.mDelayInOutInactiveNo = ImagePrepare("delay_in_out_inactive","grid_item_delay_in_out_inactive.png.xml");
	gParams.mImage.mDelayOutInInactiveNo = ImagePrepare("delay_out_in_inactive","grid_item_delay_out_in_inactive.png.xml");
	gParams.mImage.mDelayOffInactiveNo = ImagePrepare("delay_off_inactive","grid_item_delay_off_inactive.png.xml");
end

-- *************************************************************
-- CreateDialogFinish
-- *************************************************************

local function CreateDialogFinish()
	local myResult = {
		title="Installation finished",                 
		backColor="Global.Focus",                       
		icon="wizard",                                
		titleTextColor="Global.OrangeIndicator",		
		messageTextColor=nil,                           
		message="Yeeeehaaaa, the installation was successful.\nYou may now use your freshly squeezed ColorGrid on:\n\nLayout " .. gParams.mLayout.mBaseNo .. "(" .. gParams.mLayout.mLayoutName .. ")",   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="Nice, Thank you :)"},                       --int, string
		},
	}
	return myResult;
end

-- *************************************************************
-- install
-- *************************************************************

local function CgInstall(display_handle)
	local myEntryNoBackup = 0;
	local myGroupNo = 1;
	log("[CgInstall] Installing colorgrid");
	local myProgress = StartProgress("Installing Magic ColorGrid");
	-- SetProgressRange(myProgress,1,1);
	-- SetProgress(myProgress,100);
	prepare_console();
	
	-- Prepare Image pool
	PrepareImages();
	-- Install colorgrid for each group we have found
	for myKey,myValue in pairs(gParams.mGroup.mGroups) do
		myGroupIncluded = myValue["mInclude"];
		if myGroupIncluded == true  then
			local myGroupName = myValue["mName"];
			myGroupNo = myValue["mNo"];
			log("[CgInstall] Installing group " .. myGroupNo .. "(" .. myGroupName .. ")");
			-- Install entries for all colors in our gel
			for myEntryNo=1,gParams.mMaxGelNo do
				CreateGridEntry(myEntryNo,myGroupNo,myGroupName);
				myEntryNoBackup = myEntryNo;
			end
			-- Create Delay Macros
			myEntryNoBackup = myEntryNoBackup + 1;
			MacroDelayCreate(myEntryNoBackup,myGroupNo,"<",myGroupName);
			myEntryNoBackup = myEntryNoBackup + 1;
			MacroDelayCreate(myEntryNoBackup,myGroupNo,">",myGroupName);
			myEntryNoBackup = myEntryNoBackup + 1;
			MacroDelayCreate(myEntryNoBackup,myGroupNo,"<>",myGroupName);
			myEntryNoBackup = myEntryNoBackup + 1;
			MacroDelayCreate(myEntryNoBackup,myGroupNo,"><",myGroupName);
			myEntryNoBackup = myEntryNoBackup + 1;
			MacroDelayCreate(myEntryNoBackup,myGroupNo,"off",myGroupName);
			myEntryNoBackup = myEntryNoBackup + 1;
			
			-- Create Label for layout view
			LabelCreate(myGroupNo,nil);
			gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
		end
	end
	
	-- Add "All" Grid items
	CreateAllGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	
	-- Create delay time buttons
	CreateDelayGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create delay time buttons
	CreateFadeGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create color exec mode buttons
	CreateColorExecModeGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create signature label
	LabelCreate(myGroupNo,cColorGridVersionText,600,nil,200,nil);
	
	-- Actually create our colorgrid
	LayoutCreate();

	-- Set default delaytime variable
	C("SetUserVar " .. gParams.mVar.mDelaytimeName .. " \"" .. gParams.mVar.mDelaytimeDefaultVal .. "\"");
	-- Set first color and delay macro to off as default
	C("Go+ macro " .. gParams.mMacro.mDelayOffMacroNo);
	C("Go+ macro " .. gParams.mMacro.mDelayTimeZeroMacroNo);
	C("Go+ macro " .. gParams.mMacro.mFadeTimeZeroMacroNo);
	C("Go+ macro " .. gParams.mMacro.mAllColorWhiteMacroNo);
	C("Go+ macro " .. gParams.mMacro.mColorExecModeMacroNo);
	
	StopProgress(myProgress);
	
	MessageBox(CreateDialogFinish());
	log("[CgInstall] Finished sucessfully");
end

-- *************************************************************
-- CreateMainDialogChoose
-- *************************************************************

local function CreateMainDialogChoose()
	local myGroups = getAllGroupNoAsCsvString();
	local myResult = {
		title="Colorgrid, Choose your destiny :)", 
		backColor="Global.Focus",               
		icon="wizard",                          
		titleTextColor="Global.OrangeIndicator",
		messageTextColor=nil,                   
		message="Please choose wheter you want to use the easy or expert installation configuration.",   --string
		display= nil,                           
		commands={
			{value=0, name="EASY (For regular human beings)"},          
			{value=1, name="EXPERT (For badass operators)"}
		},
	}
	return myResult;
end

-- *************************************************************
-- CreateMainDialogEasy
-- *************************************************************

local function CreateMainDialogEasy()
	local myGroups = getAllGroupNoAsCsvString();
	local myResult = {
		title="Installation Options",                   --string
		backColor="Global.Focus",                       --string: Color based on current theme.
		icon="wizard",                                  --int|string
		titleTextColor="Global.OrangeIndicator",		--int|string
		messageTextColor=nil,                           --int|string
		message="Please choose the fixture groups that should be included in the color grid by their number.\n\nBy default all groups will be added.",   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="INSTALL"},                       --int, string
			{value=1, name="ABORT"}
		},
		inputs={
			{name="Groups", value=myGroups, blackFilter="", whiteFilter="0123456789,", vkPlugin="TextInput"},
		},
	}
	return myResult;
end

local gDialogImageText="Base storage no";

-- *************************************************************
-- CreateMainDialogExpert
-- *************************************************************

local function CreateMainDialogExpert()
	local myGroups = getAllGroupNoAsCsvString();
	local myResult = {
		title="Installation Options",                   --string
		backColor="Global.Focus",                       --string: Color based on current theme.
		icon="wizard",                                  --int|string
		titleTextColor="Global.OrangeIndicator",		--int|string
		messageTextColor=nil,                           --int|string
		message="Please choose the fixture groups that should be included in the color grid by their number.\n\nBy default all groups will be added.\n\nFurthermore you are able to adjust the maximum number of groups that are supported as well as the starting storage position for the new objects.",   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="INSTALL"},                       --int, string
			{value=1, name="ABORT"}
		},
		inputs={
			{name="Groups", value=myGroups, blackFilter="", whiteFilter="0123456789,", vkPlugin="TextInput"},
			{name="Maximum group number", value=gParams.mGroup.mMaxCheckNo, blackFilter="", whiteFilter="0123456789", vkPlugin="TextInputNumOnly"},
			{name=gDialogImageText, value=gParams.mImage.mBaseExecNo, blackFilter="", whiteFilter="0123456789", vkPlugin="TextInputNumOnly"},
		},
	}
	return myResult;
end

-- *************************************************************
-- initDefaults
-- *************************************************************

local function initDefaults()
	gParams.mGroup.mGroups = {};
	gParams.mColorGrid.mGrid = {};	
	gParams.mImage.mBaseStorageNo = gParams.mImage.mBaseExecNo + 1024;
end

-- *************************************************************
-- main
-- *************************************************************

local function main(display_handle,arguments)
	local myRet;
	log("Magic ColorGrid Starting up... Tadaaa.");
	if GetTokenName(arguments) ~= "/NoConfirm" then
		-- warning message
		local x = Confirm('Warning','Colorgrid will alter your current showfile and maybe break anything.\nYou have been warned :)',display_handle)
		if x == false then return; end
	end
	initDefaults();
	initGroupRegister();
	-- select mode
	myRet = MessageBox(CreateMainDialogChoose());
	if  (myRet["result"] == 0) then
		myRet = MessageBox(CreateMainDialogEasy());	
	elseif  (myRet["result"] == 1) then
		myRet = MessageBox(CreateMainDialogExpert());	
		gParams.mGroup.mMaxCheckNo = tonumber(myRet["inputs"]["Maximum group number"]);
		gParams.mImage.mBaseStorageNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mAppearance.mBaseNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mPreset.mBaseNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mSequence.mBaseNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mMacro.mBaseNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mLayout.mBaseNo = tonumber(myRet["inputs"][gDialogImageText]);
		gParams.mImage.mBaseStorageNo = gParams.mImage.mBaseExecNo + 1024;
	else
		goto exit;
	end
	-- Register groups that should be included in the grid
	-- for k,v in pairs(myRet.result) do
		-- log("Key=" .. tostring(k) .. " Value=" .. tostring(v))
	-- end
	if ( setGroupsForColorGridFromCsv(myRet["inputs"]["Groups"]) == false ) then
		local x = Confirm('Warning','No groups selected. At least one group is needed to work properly',display_handle)
		if x == false then return; end
	else
		if  (myRet["result"] == 0) then
			CgInstall(display_handle);
		end
	end
::exit::
end


if _DEBUG == true then
	return main(1,0)
else
	return main
end
