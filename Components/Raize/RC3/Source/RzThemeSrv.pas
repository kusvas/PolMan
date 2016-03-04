{=======================================================================================================================
  RzThemeSrv Unit

  Raize Components - Component Source Unit

  This unit contains Mike Lischke's ThemeServices class and supporting code. This unit is required for XP visual
  style support in versions 5 and 6 of the VCL.


  Modification History
  ----------------------------------------------------------------------------------------------------------------------
  3.0.6  (11 Apr 2003)  * Incorporated changes from 1.9.17 release of Mike Lischke's ThemeServices.

  3.0    (20 Dec 2002)  * Initial release.

=======================================================================================================================}

unit RzThemeSrv;

//----------------------------------------------------------------------------------------------------------------------
// Windows XP Theme Manager is freeware. You may freely use it in any software, including commercial software, provided
// you accept the following conditions:
//
// 1) The software may not be included into component collections and similar compilations which are sold. If you want
//    to distribute this software for money then contact me first and ask for my permission.
// 2) My copyright notices in the source code may not be removed or modified.
// 3) If you modify and/or distribute the code to any third party then you must not veil the original author. It must
//    always be clearly identifiable that I, Mike Lischke, am the original author.
// Although it is not required it would be a nice move to recognize my work by adding a citation to the application's
// about box or a similar place.
//
// The original code is ThemeSrv.pas, released 03. February 2002.
//
// The initial developer of the original code is:
//   Dipl. Ing. Mike Lischke (public@lischke-online.de, www.lischke-online.de).
//
// Portions created by Mike Lischke are
// (C) 2001-2002 Mike Lischke. All Rights Reserved.
//----------------------------------------------------------------------------------------------------------------------
//
// This unit contains the implementation of TThemeServices which is a designed to manage all necessary aspects of
// the Windows XP (and up) theme APIs. The component is responsible for loading and unloading of the theme DLL
// and offers properties and methods to test for various aspects of the theme APIs and to ease painting of themed
// window content.
//
// The TThemeServices class is designed to work for controls which need XP paint stuff. It does not manipulate
// any VCL class (for this TThemeManager is responsible) and can be used standalone (also as general support
// tool in an application) or together with any theme manager class. However TThemeManager also includes a theme services
// instance, so you can use this instead creating yet another one.
//----------------------------------------------------------------------------------------------------------------------
// For version information and history see ThemeMgr.pas source file.
//----------------------------------------------------------------------------------------------------------------------

interface

uses
  Windows, Classes, Messages, Graphics, Controls,
  // Theme units, from www.delphi-jedi.org (Win32API, translated by Marcel van Brakel, improved by Mike Lischke).
  RzUxTheme, RzTmSchema;

// Include file to determine which compiler is currently being used to build the project/component.
// This file uses ideas from Brad Stowers DFS.inc file (www.delphifreestuff.com).
//----------------------------------------------------------------------------------------------------------------------
// The following symbols are defined:
//
// COMPILER_1    : Kylix/Delphi/BCB 1.x is the compiler.
// COMPILER_1_UP : Kylix/Delphi/BCB 1.x or higher is the compiler.
// COMPILER_2    : Kylix/Delphi 2.x or BCB 1.x is the compiler.
// COMPILER_2_UP : Kylix/Delphi 2.x or higher, or BCB 1.x or higher is the compiler.
// COMPILER_3    : Kylix/Delphi/BCB 3.x is the compiler.
// COMPILER_3_UP : Kylix/Delphi/BCB 3.x or higher is the compiler.
// COMPILER_4    : Kylix/Delphi/BCB 4.x is the compiler.
// COMPILER_4_UP : Kylix/Delphi/BCB 4.x or higher is the compiler.
// COMPILER_5    : Kylix/Delphi/BCB 5.x is the compiler.
// COMPILER_5_UP : Kylix/Delphi/BCB 5.x or higher is the compiler.
// COMPILER_6    : Kylix/Delphi/BCB 6.x is the compiler.
// COMPILER_6_UP : Kylix/Delphi/BCB 6.x or higher is the compiler.
// COMPILER_7    : Kylix/Delphi/BCB 7.x is the compiler.
// COMPILER_7_UP : Kylix/Delphi/BCB 7.x or higher is the compiler.
//
// Only defined if Windows is the target:
// CPPB        : Any version of BCB is being used.
// CPPB_1      : BCB v1.x is being used.
// CPPB_3      : BCB v3.x is being used.
// CPPB_3_UP   : BCB v3.x or higher is being used.
// CPPB_4      : BCB v4.x is being used.
// CPPB_4_UP   : BCB v4.x or higher is being used.
// CPPB_5      : BCB v5.x is being used.
// CPPB_5_UP   : BCB v5.x or higher is being used.
//
// Only defined if Windows is the target:
// DELPHI      : Any version of Delphi is being used.
// DELPHI_1    : Delphi v1.x is being used.
// DELPHI_2    : Delphi v2.x is being used.
// DELPHI_2_UP : Delphi v2.x or higher is being used.
// DELPHI_3    : Delphi v3.x is being used.
// DELPHI_3_UP : Delphi v3.x or higher is being used.
// DELPHI_4    : Delphi v4.x is being used.
// DELPHI_4_UP : Delphi v4.x or higher is being used.
// DELPHI_5    : Delphi v5.x is being used.
// DELPHI_5_UP : Delphi v5.x or higher is being used.
// DELPHI_6    : Delphi v6.x is being used.
// DELPHI_6_UP : Delphi v6.x or higher is being used.
// DELPHI_7    : Delphi v7.x is being used.
// DELPHI_7_UP : Delphi v7.x or higher is being used.
//
// Only defined if Linux is the target:
// KYLIX       : Any version of Kylix is being used.
// KYLIX_1     : Kylix 1.x is being used.
// KYLIX_1_UP  : Kylix 1.x or higher is being used.
//----------------------------------------------------------------------------------------------------------------------

{$ifdef Win32}
  {$ifdef VER150}        
    {$define COMPILER_7}
    {$define DELPHI}
    {$define DELPHI_7}
  {$endif}

  {$ifdef VER140}
    {$define COMPILER_6}
    {$define DELPHI}
    {$define DELPHI_6}
  {$endif}

  {$ifdef VER130}
    {$define COMPILER_5}
    {$ifdef BCB}
      {$define CPPB}
      {$define CPPB_5}
    {$else}
      {$define DELPHI}
      {$define DELPHI_5}
    {$endif}
  {$endif}

  {$ifdef VER125}
    {$define COMPILER_4}
    {$define CPPB}
    {$define CPPB_4}
  {$endif}

  {$ifdef VER120}
    {$define COMPILER_4}
    {$define DELPHI}
    {$define DELPHI_4}
  {$endif}

  {$ifdef VER110}
    {$define COMPILER_3}
    {$define CPPB}
    {$define CPPB_3}
  {$endif}

  {$ifdef VER100}
    {$define COMPILER_3}
    {$define DELPHI}
    {$define DELPHI_3}
  {$endif}

  {$ifdef VER93}
    {$define COMPILER_2} // C_UP_UPB v1 compiler is really v2 
    {$define CPPB}
    {$define CPPB_1}
  {$endif}

  {$ifdef VER90}
    {$define COMPILER_2}
    {$define DELPHI}
    {$define DELPHI_2}
  {$endif}

  {$ifdef VER80}
    {$define COMPILER_1}
    {$define DELPHI}
    {$define DELPHI_1}
  {$endif}

  {$ifdef COMPILER_1}
    {$define COMPILER_1_UP}
  {$endif}

  {$ifdef COMPILER_2}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
  {$endif}

  {$ifdef COMPILER_3}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
    {$define COMPILER_3_UP}
  {$endif}

  {$ifdef COMPILER_4}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
    {$define COMPILER_3_UP}
    {$define COMPILER_4_UP}
  {$endif}

  {$ifdef COMPILER_5}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
    {$define COMPILER_3_UP}
    {$define COMPILER_4_UP}
    {$define COMPILER_5_UP}
  {$endif}

  {$ifdef COMPILER_6}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
    {$define COMPILER_3_UP}
    {$define COMPILER_4_UP}
    {$define COMPILER_5_UP}
    {$define COMPILER_6_UP}
  {$endif}

  {$ifdef COMPILER_7}
    {$define COMPILER_1_UP}
    {$define COMPILER_2_UP}
    {$define COMPILER_3_UP}
    {$define COMPILER_4_UP}
    {$define COMPILER_5_UP}
    {$define COMPILER_6_UP}
    {$define COMPILER_7_UP}
  {$endif}

  {$ifdef DELPHI_2}
    {$define DELPHI_2_UP}
  {$endif}

  {$ifdef DELPHI_3}
    {$define DELPHI_2_UP}
    {$define DELPHI_3_UP}
  {$endif}

  {$ifdef DELPHI_4}
    {$define DELPHI_2_UP}
    {$define DELPHI_3_UP}
    {$define DELPHI_4_UP}
  {$endif}

  {$ifdef DELPHI_5}
    {$define DELPHI_2_UP}
    {$define DELPHI_3_UP}
    {$define DELPHI_4_UP}
    {$define DELPHI_5_UP}
  {$endif}

  {$ifdef DELPHI_6}
    {$define DELPHI_2_UP}
    {$define DELPHI_3_UP}
    {$define DELPHI_4_UP}
    {$define DELPHI_5_UP}
    {$define DELPHI_6_UP}
  {$endif}

  {$ifdef DELPHI_7}
    {$define DELPHI_2_UP}
    {$define DELPHI_3_UP}
    {$define DELPHI_4_UP}
    {$define DELPHI_5_UP}
    {$define DELPHI_6_UP}
    {$define DELPHI_7_UP}
  {$endif}

  {$ifdef CPPB_3}
    {$define CPPB_3_UP}
  {$endif}

  {$ifdef CPPB_4}
    {$define CPPB_3_UP}
    {$define CPPB_4_UP}
  {$endif}

  {$ifdef CPPB_5}
    {$define CPPB_3_UP}
    {$define CPPB_4_UP}
    {$define CPPB_5_UP}
  {$endif}

  {$ifdef CPPB_3_UP}
    // C++ Builder requires this if you use Delphi components in run-time packages.
    {$ObjExportAll On}
  {$endif}

{$else (not Windows)}
  // Linux is the target
  {$define KYLIX}
  {$define KYLIX_1}
  {$define KYLIX_1_UP}
{$endif}

//----------------------------------------------------------------------------------------------------------------------



type
  // These are all elements which can be themed.
  TThemedElement = (
    teButton,
    teClock,
    teComboBox,
    teEdit,
    teExplorerBar,
    teHeader,
    teListView,
    teMenu,
    tePage,
    teProgress,
    teRebar,
    teScrollBar,
    teSpin,
    teStartPanel,
    teStatus,
    teTab,
    teTaskBand,
    teTaskBar,
    teToolBar,
    teToolTip,
    teTrackBar,
    teTrayNotify,
    teTreeview,
    teWindow
  );

  // 'Button' theme data
  TThemedButton = (
    tbButtonDontCare,
    tbButtonRoot,       // The root part of each element is sometimes used for special painting and does not
                        // belong to a certain state.
    tbPushButtonNormal, tbPushButtonHot, tbPushButtonPressed, tbPushButtonDisabled, tbPushButtonDefaulted,
    tbRadioButtonUncheckedNormal, tbRadioButtonUncheckedHot, tbRadioButtonUncheckedPressed, tbRadioButtonUncheckedDisabled,
    tbRadioButtonCheckedNormal, tbRadioButtonCheckedHot, tbRadioButtonCheckedPressed, tbRadioButtonCheckedDisabled,
    tbCheckBoxUncheckedNormal, tbCheckBoxUncheckedHot, tbCheckBoxUncheckedPressed, tbCheckBoxUncheckedDisabled,
    tbCheckBoxCheckedNormal, tbCheckBoxCheckedHot, tbCheckBoxCheckedPressed, tbCheckBoxCheckedDisabled,
    tbCheckBoxMixedNormal, tbCheckBoxMixedHot, tbCheckBoxMixedPressed, tbCheckBoxMixedDisabled,
    tbGroupBoxNormal, tbGroupBoxDisabled,
    tbUserButton
  );

  // 'Clock' theme data
  TThemedClock = (
    tcClockDontCare,
    tcClockRoot,
    tcTimeNormal
  );

  // 'ComboBox' theme data
  TThemedComboBox = (
    tcComboBoxDontCare,
    tcComboBoxRoot,
    tcDropDownButtonNormal, tcDropDownButtonHot,  tcDropDownButtonPressed,  tcDropDownButtonDisabled
  );

  // 'Edit' theme data
  TThemedEdit = (
    teEditDontCare,
    teEditRoot,
    teEditTextNormal, teEditTextHot, teEditTextSelected, teEditTextDisabled, teEditTextFocused, teEditTextReadOnly, teEditTextAssist,
    teEditCaret
  );

  // 'ExplorerBar' theme data
  TThemedExplorerBar = (
    tebExplorerBarDontCare,
    tebExplorerBarRoot,
    tebHeaderBackgroundNormal, tebHeaderBackgroundHot,  tebHeaderBackgroundPressed,
    tebHeaderCloseNormal, tebHeaderCloseHot, tebHeaderClosePressed,
    tebHeaderPinNormal, tebHeaderPinHot, tebHeaderPinPressed,
    tebHeaderPinSelectedNormal, tebHeaderPinSelectedHot, tebHeaderPinSelectedPressed,
    tebIEBarMenuNormal, tebIEBarMenuHot, tebIEBarMenuPressed,
    tebNormalGroupBackground,
    tebNormalGroupCollapseNormal, tebNormalGroupCollapseHot,  tebNormalGroupCollapsePressed,
    tebNormalGroupExpandNormal, tebNormalGroupExpandHot,  tebNormalGroupExpandPressed,
    tebNormalGroupHead,
    tebSpecialGroupBackground,
    tebSpecialGroupCollapseSpecial, tebSpecialGroupCollapseHot,  tebSpecialGroupCollapsePressed,
    tebSpecialGroupExpandSpecial, tebSpecialGroupExpandHot,  tebSpecialGroupExpandPressed,
    tebSpecialGroupHead
  );

  // 'Header' theme data
  TThemedHeader = (
    thHeaderDontCare,
    thHeaderRoot,
    thHeaderItemNormal, thHeaderItemHot, thHeaderItemPressed,
    thHeaderItemLeftNormal, thHeaderItemLeftHot, thHeaderItemLeftPressed,
    thHeaderItemRightNormal, thHeaderItemRightHot, thHeaderItemRightPressed,
    thHeaderSortArrowSortedUp, thHeaderSortArrowSortedDown
  );

  // 'ListView' theme data
  TThemedListview = (
    tlListviewDontCare,
    tlListviewRoot,
    tlListItemNormal, tlListItemHot, tlListItemSelected, tlListItemDisabled, tlListItemSelectedNotFocus,
    tlListGroup,
    tlListDetail,
    tlListSortDetail,
    tlEmptyText
  );

  // 'Menu' theme data
  TThemedMenu = (
    tmMenuDontCare,
    tmMenuRoot,
    tmMenuItemNormal, tmMenuItemSelected, tmMenuItemDemoted,
    tmMenuDropDown,
    tmMenuBarItem,
    tmMenuBarDropDown,
    tmChevron,
    tmSeparator
  );

  // 'Page' theme data
  TThemedPage = (
    tpPageDontCare,
    tpPageRoot,
    tpUpNormal, tpUpHot, tpUpPressed, tpUpDisabled,
    tpDownNormal, tpDownHot, tpDownPressed, tpDownDisabled,
    tpUpHorzNormal, tpUpHorzHot, tpUpHorzPressed, tpUpHorzDisabled,
    tpDownHorzNormal, tpDownHorzHot, tpDownHorzPressed, tpDownHorzDisabled
  );

  // 'Progress' theme data
  TThemedProgress = (
    tpProgressDontCare,
    tpProgressRoot,
    tpBar,
    tpBarVert,
    tpChunk,
    tpChunkVert
  );

  // 'Rebar' theme data
  TThemedRebar = (
    trRebarDontCare,
    trRebarRoot,
    trGripper,
    trGripperVert,
    trBandNormal, trBandHot, trBandPressed, trBandDisabled, trBandChecked, trBandHotChecked,
    trChevronNormal, trChevronHot, trChevronPressed, trChevronDisabled,
    trChevronVertNormal, trChevronVertHot, trChevronVertPressed, trChevronVertDisabled
  );

  // 'ScrollBar' theme data
  TThemedScrollBar = (
    tsScrollBarDontCare,
    tsScrollBarRoot,
    tsArrowBtnUpNormal, tsArrowBtnUpHot, tsArrowBtnUpPressed, tsArrowBtnUpDisabled,
    tsArrowBtnDownNormal, tsArrowBtnDownHot, tsArrowBtnDownPressed, tsArrowBtnDownDisabled,
    tsArrowBtnLeftNormal, tsArrowBtnLeftHot, tsArrowBtnLeftPressed, tsArrowBtnLeftDisabled,
    tsArrowBtnRightNormal, tsArrowBtnRightHot, tsArrowBtnRightPressed, tsArrowBtnRightDisabled,
    tsThumbBtnHorzNormal, tsThumbBtnHorzHot, tsThumbBtnHorzPressed, tsThumbBtnHorzDisabled,
    tsThumbBtnVertNormal, tsThumbBtnVertHot, tsThumbBtnVertPressed, tsThumbBtnVertDisabled,
    tsLowerTrackHorzNormal, tsLowerTrackHorzHot, tsLowerTrackHorzPressed, tsLowerTrackHorzDisabled,
    tsUpperTrackHorzNormal, tsUpperTrackHorzHot, tsUpperTrackHorzPressed, tsUpperTrackHorzDisabled,
    tsLowerTrackVertNormal, tsLowerTrackVertHot, tsLowerTrackVertPressed, tsLowerTrackVertDisabled,
    tsUpperTrackVertNormal, tsUpperTrackVertHot, tsUpperTrackVertPressed, tsUpperTrackVertDisabled,
    tsGripperHorzNormal, tsGripperHorzHot, tsGripperHorzPressed, tsGripperHorzDisabled,
    tsGripperVertNormal, tsGripperVertHot, tsGripperVertPressed, tsGripperVertDisabled,
    tsSizeBoxRightAlign, tsSizeBoxLeftAlign
  );

  // 'Spin' theme data
  TThemedSpin = (
    tsSpinDontCare,
    tsSpinRoot,
    tsUpNormal, tsUpHot, tsUpPressed, tsUpDisabled,
    tsDownNormal, tsDownHot, tsDownPressed, tsDownDisabled,
    tsUpHorzNormal, tsUpHorzHot, tsUpHorzPressed, tsUpHorzDisabled,
    tsDownHorzNormal, tsDownHorzHot, tsDownHorzPressed, tsDownHorzDisabled
  );

  // 'StartPanel' theme data
  TThemedStartPanel = (
    tspStartPanelDontCare,
    tspStartPanelRoot,
    tspUserPane,
    tspMorePrograms,
    tspMoreProgramsArrowNormal, tspMoreProgramsArrowHot, tspMoreProgramsArrowPressed,
    tspProgList,
    tspProgListSeparator,
    tspPlacesList,
    tspPlacesListSeparator,
    tspLogOff,
    tspLogOffButtonsNormal, tspLogOffButtonsHot, tspLogOffButtonsPressed,
    tspUserPicture,
    tspPreview
  );

  // 'Status' theme data
  TThemedStatus = (
    tsStatusDontCare,
    tsStatusRoot,
    tsPane,
    tsGripperPane,
    tsGripper
  );

  // 'Tab' theme data
  TThemedTab = (
    ttTabDontCare,
    ttTabRoot,
    ttTabItemNormal, ttTabItemHot, ttTabItemSelected, ttTabItemDisabled, ttTabItemFocused,
    ttTabItemLeftEdgeNormal, ttTabItemLeftEdgeHot, ttTabItemLeftEdgeSelected, ttTabItemLeftEdgeDisabled, ttTabItemLeftEdgeFocused,
    ttTabItemRightEdgeNormal, ttTabItemRightEdgeHot, ttTabItemRightEdgeSelected, ttTabItemRightEdgeDisabled, ttTabItemRightEdgeFocused,
    ttTabItemBothEdgeNormal, ttTabItemBothEdgeHot, ttTabItemBothEdgeSelected, ttTabItemBothEdgeDisabled, ttTabItemBothEdgeFocused,
    ttTopTabItemNormal, ttTopTabItemHot, ttTopTabItemSelected, ttTopTabItemDisabled, ttTopTabItemFocused,
    ttTopTabItemLeftEdgeNormal, ttTopTabItemLeftEdgeHot, ttTopTabItemLeftEdgeSelected, ttTopTabItemLeftEdgeDisabled, ttTopTabItemLeftEdgeFocused,
    ttTopTabItemRightEdgeNormal, ttTopTabItemRightEdgeHot, ttTopTabItemRightEdgeSelected, ttTopTabItemRightEdgeDisabled, ttTopTabItemRightEdgeFocused,
    ttTopTabItemBothEdgeNormal, ttTopTabItemBothEdgeHot, ttTopTabItemBothEdgeSelected, ttTopTabItemBothEdgeDisabled, ttTopTabItemBothEdgeFocused,
    ttPane,
    ttBody
  );

  // 'TaskBand' theme data
  TThemedTaskBand = (
    ttbTaskBandDontCare,
    ttbTaskBandRoot,
    ttbGroupCount,
    ttbFlashButton,
    ttpFlashButtonGroupMenu
  );

  // 'TaskBar' theme data
  TThemedTaskBar = (
    ttTaskBarDontCare,
    ttTaskBarRoot,
    ttbTimeNormal
  );

  // 'ToolBar' theme data
  TThemedToolBar = (
    ttbToolBarDontCare,
    ttbToolBarRoot,
    ttbButtonNormal, ttbButtonHot, ttbButtonPressed, ttbButtonDisabled, ttbButtonChecked, ttbButtonCheckedHot,
    ttbDropDownButtonNormal, ttbDropDownButtonHot, ttbDropDownButtonPressed, ttbDropDownButtonDisabled, ttbDropDownButtonChecked, ttbDropDownButtonCheckedHot,
    ttbSplitButtonNormal, ttbSplitButtonHot, ttbSplitButtonPressed, ttbSplitButtonDisabled, ttbSplitButtonChecked, ttbSplitButtonCheckedHot,
    ttbSplitButtonDropDownNormal, ttbSplitButtonDropDownHot, ttbSplitButtonDropDownPressed, ttbSplitButtonDropDownDisabled, ttbSplitButtonDropDownChecked, ttbSplitButtonDropDownCheckedHot,
    ttbSeparatorNormal, ttbSeparatorHot, ttbSeparatorPressed, ttbSeparatorDisabled, ttbSeparatorChecked, ttbSeparatorCheckedHot,
    ttbSeparatorVertNormal, ttbSeparatorVertHot, ttbSeparatorVertPressed, ttbSeparatorVertDisabled, ttbSeparatorVertChecked, ttbSeparatorVertCheckedHot
  );

  // 'ToolTip' theme data
  TThemedToolTip = (
    tttToolTipDontCare,
    tttToolTipRoot,
    tttStandardNormal, tttStandardLink,
    tttStandardTitleNormal, tttStandardTitleLink,
    tttBaloonNormal, tttBaloonLink,
    tttBaloonTitleNormal, tttBaloonTitleLink,
    tttCloseNormal, tttCloseHot, tttClosePressed
  );

  // 'TrackBar' theme data
  TThemedTrackBar = (
    ttbTrackBarDontCare,
    ttbTrackBarRoot,
    ttbTrack,
    ttbTrackVert,
    ttbThumbNormal, ttbThumbHot, ttbThumbPressed, ttbThumbFocused, ttbThumbDisabled,
    ttbThumbBottomNormal, ttbThumbBottomHot, ttbThumbBottomPressed, ttbThumbBottomFocused, ttbThumbBottomDisabled,
    ttbThumbTopNormal, ttbThumbTopHot, ttbThumbTopPressed, ttbThumbTopFocused, ttbThumbTopDisabled,
    ttbThumbVertNormal, ttbThumbVertHot, ttbThumbVertPressed, ttbThumbVertFocused, ttbThumbVertDisabled,
    ttbThumbLeftNormal, ttbThumbLeftHot, ttbThumbLeftPressed, ttbThumbLeftFocused, ttbThumbLeftDisabled,
    ttbThumbRightNormal, ttbThumbRightHot, ttbThumbRightPressed, ttbThumbRightFocused, ttbThumbRightDisabled,
    ttbThumbTics, 
    ttbThumbTicsVert
  );

  // 'TrayNotify' theme data
  TThemedTrayNotify = (
    ttnTrayNotifyDontCare,
    ttnTrayNotifyRoot,
    ttnBackground,
    ttnAnimBackground
  );

  // 'Treeview' theme data
  TThemedTreeview = (
    ttTreeviewDontCare,
    ttTreeviewRoot,
    ttItemNormal, ttItemHot, ttItemSelected, ttItemDisabled, ttItemSelectedNotFocus,
    ttGlyphClosed, ttGlyphOpened, 
    ttBranch
  );

  // 'Window' theme data
  TThemedWindow = (
    twWindowDontCare,
    twWindowRoot,
    twCaptionActive, twCaptionInactive, twCaptionDisabled,
    twSmallCaptionActive, twSmallCaptionInactive, twSmallCaptionDisabled,
    twMinCaptionActive, twMinCaptionInactive, twMinCaptionDisabled,
    twSmallMinCaptionActive, twSmallMinCaptionInactive, twSmallMinCaptionDisabled,
    twMaxCaptionActive, twMaxCaptionInactive, twMaxCaptionDisabled,
    twSmallMaxCaptionActive, twSmallMaxCaptionInactive, twSmallMaxCaptionDisabled,

    twFrameLeftActive, twFrameLeftInactive,
    twFrameRightActive, twFrameRightInactive,
    twFrameBottomActive, twFrameBottomInactive,
    twSmallFrameLeftActive, twSmallFrameLeftInactive,
    twSmallFrameRightActive, twSmallFrameRightInactive,
    twSmallFrameBottomActive, twSmallFrameBottomInactive,

    twSysButtonNormal, twSysButtonHot, twSysButtonPushed, twSysButtonDisabled,
    twMDISysButtonNormal, twMDISysButtonHot, twMDISysButtonPushed, twMDISysButtonDisabled,
    twMinButtonNormal, twMinButtonHot, twMinButtonPushed, twMinButtonDisabled,
    twMDIMinButtonNormal, twMDIMinButtonHot, twMDIMinButtonPushed, twMDIMinButtonDisabled,
    twMaxButtonNormal, twMaxButtonHot, twMaxButtonPushed, twMaxButtonDisabled,
    twCloseButtonNormal, twCloseButtonHot, twCloseButtonPushed, twCloseButtonDisabled,
    twSmallCloseButtonNormal, twSmallCloseButtonHot, twSmallCloseButtonPushed, twSmallCloseButtonDisabled,
    twMDICloseButtonNormal, twMDICloseButtonHot, twMDICloseButtonPushed, twMDICloseButtonDisabled,
    twRestoreButtonNormal, twRestoreButtonHot, twRestoreButtonPushed, twRestoreButtonDisabled,
    twMDIRestoreButtonNormal, twMDIRestoreButtonHot, twMDIRestoreButtonPushed, twMDIRestoreButtonDisabled,
    twHelpButtonNormal, twHelpButtonHot, twHelpButtonPushed, twHelpButtonDisabled,
    twMDIHelpButtonNormal, twMDIHelpButtonHot, twMDIHelpButtonPushed, twMDIHelpButtonDisabled,

    twHorzScrollNormal, twHorzScrollHot, twHorzScrollPushed, twHorzScrollDisabled,
    twHorzThumbNormal, twHorzThumbHot, twHorzThumbPushed, twHorzThumbDisabled,
    twVertScrollNormal, twVertScrollHot, twVertScrollPushed, twVertScrollDisabled,
    twVertThumbNormal, twVertThumbHot, twVertThumbPushed, twVertThumbDisabled,

    twDialog,
    twCaptionSizingTemplate,
    twSmallCaptionSizingTemplate,
    twFrameLeftSizingTemplate,
    twSmallFrameLeftSizingTemplate,
    twFrameRightSizingTemplate,
    twSmallFrameRightSizingTemplate,
    twFrameBottomSizingTemplate,
    twSmallFrameBottomSizingTemplate
  );

  TThemeData = array[TThemedElement] of HTHEME;

  PThemedElementDetails = ^TThemedElementDetails;
  TThemedElementDetails = record
    Element: TThemedElement;
    Part,
    State: Integer;
  end;

  // TThemeServices is a small foot print class to provide the user with pure Windows XP theme related abilities like
  // painting elements and text or retrieving certain info.
  TThemeServices = class(TObject)
  private
    FThemesAvailable,
    FUseThemes,
    FControlsEnabled: Boolean;
    FWindowHandle: HWND;
    FDefWindowProc,
    FObjectInstance: Pointer;
    FThemeData: TThemeData;            // Holds a list of theme data handles.
    FOnThemeChange: TNotifyEvent;      // Called when the current window theme has changed.

    function GetTheme(Element: TThemedElement): HTHEME;
    function GetThemesEnabled: Boolean;
    procedure WindowProc(var Message: TMessage);
  protected
    procedure DoOnThemeChange; virtual;
    procedure UnloadThemeData;
  public
    constructor Create(ClientWindow: HWND);
    destructor Destroy; override;

    function GetElementDetails(Detail: TThemedButton): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedClock): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedComboBox): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedEdit): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedExplorerBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedHeader): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedListView): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedMenu): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedPage): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedProgress): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedRebar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedScrollBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedSpin): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedStartPanel): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedStatus): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTab): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTaskBand): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTaskBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedToolBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedToolTip): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTrackBar): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTrayNotify): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedTreeview): TThemedElementDetails; overload;
    function GetElementDetails(Detail: TThemedWindow): TThemedElementDetails; overload;

    function ColorToRGB(Color: TColor; Details: PThemedElementDetails = nil): COLORREF;
    function ContentRect(DC: HDC; Details: TThemedElementDetails; BoundingRect: TRect): TRect;
    procedure DrawEdge(DC: HDC; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal;
      ContentRect: PRect = nil);
    procedure DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect = nil);
    procedure DrawIcon(DC: HDC; Details: TThemedElementDetails; const R: TRect; himl: HIMAGELIST; Index: Integer);
    procedure DrawParentBackground(Window: HWND; Target: HDC; Details: PThemedElementDetails; OnlyIfTransparent: Boolean;
      Bounds: PRect = nil);
    procedure DrawText(DC: HDC; Details: TThemedElementDetails; const S: WideString; R: TRect; Flags, Flags2: Cardinal);
    function HasTransparentParts(Details: TThemedElementDetails): Boolean;
    procedure PaintBorder(Control: TWinControl; EraseLRCorner: Boolean);
    procedure UpdateThemes;

    property ClientWindow: HWND read FWindowHandle;
    property Theme[Element: TThemedElement]: HTHEME read GetTheme;
    property ThemesAvailable: Boolean read FThemesAvailable;
    property ThemesEnabled: Boolean read GetThemesEnabled;

    property OnThemeChange: TNotifyEvent read FOnThemeChange write FOnThemeChange;
  end;

function ThemeServices: TThemeServices;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Forms, // MakeObjectInstance is located in Forms in pre 6 VCL versions.
  SysUtils, ComCtrls;

const
  // Do not modify the copyright in any way! Usage of this unit is prohibited without the copyright notice
  // in the compiled binary file.
  Copyright: string = 'Theme manager � 2001, 2002 Mike Lischke';

  ThemeDataNames: array[TThemedElement] of PWideChar = (
    'button',      // teButton
    'clock',       // teClock
    'combobox',    // teComboBox
    'edit',        // teEdit
    'explorerbar', // teExplorerBar
    'header',      // teHeader
    'listview',    // teListView
    'menu',        // teMenu
    'page',        // tePage
    'progress',    // teProgress
    'rebar',       // teRebar
    'scrollbar',   // teScrollBar
    'spin',        // teSpin
    'startpanel',  // teStartPanel
    'status',      // teStatus
    'tab',         // teTab
    'taskband',    // teTaskBand
    'taskbar',     // teTaskBar
    'toolbar',     // teToolBar
    'tooltip',     // teToolTip
    'trackbar',    // teTrackBar
    'traynotify',  // teTrayNotify
    'treeview',    // teTreeview
    'window'       // teWindow
  );

var
  InternalThemeServices: TThemeServices;

//----------------------------------------------------------------------------------------------------------------------

function ThemeServices: TThemeServices;

begin
  if InternalThemeServices = nil then
    InternalThemeServices := TThemeServices.Create(Application.Handle);
  Result := InternalThemeServices;
end;

//----------------- TThemeServices -------------------------------------------------------------------------------------

constructor TThemeServices.Create(ClientWindow: HWND);

begin
  FWindowHandle := ClientWindow;
  if FWindowHandle <> 0 then
  begin
    // If a window handle is given then subclass the window to get notified about theme changes.
    {$ifdef COMPILER_6_UP}
      FObjectInstance := Classes.MakeObjectInstance(WindowProc);
    {$else}
      FObjectInstance := MakeObjectInstance(WindowProc);
    {$endif COMPILER_6_UP}
    FDefWindowProc := Pointer(GetWindowLong(FWindowHandle, GWL_WNDPROC));
    SetWindowLong(FWindowHandle, GWL_WNDPROC, Integer(FObjectInstance));
  end;

  FThemesAvailable := InitThemeLibrary;
  UpdateThemes;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TThemeServices.Destroy;

begin
  if Assigned(FObjectInstance) then
  begin
    SetWindowLong(FWindowHandle, GWL_WNDPROC, Integer(FDefWindowProc));
    {$ifdef COMPILER_6_UP}
      Classes.FreeObjectInstance(FObjectInstance);
    {$else}
      FreeObjectInstance(FObjectInstance);
    {$endif COMPILER_6_UP}
  end;
  UnloadThemeData;
  FreeThemeLibrary;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetTheme(Element: TThemedElement): HTHEME;

// Returns the theme data handle for the given element. The theme is opened if not yet done.

begin
  if FUseThemes and (FThemeData[Element] = 0) then
    FThemeData[Element] := OpenThemeData(FWindowHandle, ThemeDataNames[Element]);
  Result := FThemeData[Element];
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetThemesEnabled: Boolean;

begin
  Result := FThemesAvailable and FUseThemes and FControlsEnabled;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.WindowProc(var Message: TMessage);

begin
  case Message.Msg of
    WM_THEMECHANGED:
      begin
        // This message only appears if the services serve a particular window. If the services are part of some other theme
        // management structure (without an own window, e.g. in a TThemeManager class) then this structure is responsible to
        // call UpdateThemes explicitely.
        UpdateThemes;
        DoOnThemeChange;
      end;
    WM_DESTROY:
      begin
        // If we are connected to a window then we have to listen to its destruction. 
        SetWindowLong(FWindowHandle, GWL_WNDPROC, Integer(FDefWindowProc));
        {$ifdef COMPILER_6_UP}
          Classes.FreeObjectInstance(FObjectInstance);
        {$else}
          FreeObjectInstance(FObjectInstance);
        {$endif COMPILER_6_UP}
        FObjectInstance := nil;
      end;
  end;

  with Message do
    Result := CallWindowProc(FDefWindowProc, FWindowHandle, Msg, WParam, LParam);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DoOnThemeChange;

begin
  if Assigned(FOnThemeChange) then
    FOnThemeChange(Self);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.UnloadThemeData;

// Closes all opened theme data handles and frees the theme records.

var
  Entry: TThemedElement;

begin
  if (FWindowHandle = 0) or IsWindow(FWindowHandle) then
  begin
    for Entry := Low(TThemeData) to High(TThemeData) do
      if FThemeData[Entry] <> 0 then
      begin
        CloseThemeData(FThemeData[Entry]);
        FThemeData[Entry] := 0;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedButton): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teButton;
  with Result do
  begin
    case Detail of
      tbPushButtonNormal..tbPushButtonDefaulted:
        begin
          Part := BP_PUSHBUTTON;
          Base := Ord(tbPushButtonNormal);
        end;
      tbRadioButtonUncheckedNormal..tbRadioButtonCheckedDisabled:
        begin
          Part := BP_RADIOBUTTON;
          Base := Ord(tbRadioButtonUncheckedNormal);
        end;
      tbCheckBoxUncheckedNormal..tbCheckBoxMixedDisabled:
        begin
          Part := BP_CHECKBOX;
          Base := Ord(tbCheckBoxUncheckedNormal);
        end;
      tbGroupBoxNormal..tbGroupBoxDisabled:
        begin
          Part := BP_GROUPBOX;
          Base := Ord(tbGroupBoxNormal);
        end;
      tbUserButton:
        begin
          Part := BP_USERBUTTON;
          Base := Ord(tbUserButton);
        end;
    else
      Part := 0;              
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedClock): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teClock;
  with Result do
  begin
    case Detail of
      tcTimeNormal:
        begin
          Part := CLP_TIME;
          Base := Ord(tcTimeNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedComboBox): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teComboBox;
  with Result do
  begin
    case Detail of
      tcDropDownButtonNormal..tcDropDownButtonDisabled:
        begin
          Part := CP_DROPDOWNBUTTON;
          Base := Ord(tcDropDownButtonNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedEdit): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teEdit;
  with Result do
  begin
    case Detail of
      teEditTextNormal..teEditTextAssist:
        begin
          Part := EP_EDITTEXT;
          Base := Ord(teEditTextNormal);
        end;
      teEditCaret:
        begin
          Part := EP_CARET;
          Base := Ord(teEditCaret);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedExplorerBar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teExplorerBar;
  with Result do
  begin
    case Detail of
      tebHeaderBackgroundNormal..tebHeaderBackgroundPressed:
        begin
          Part := EBP_HEADERBACKGROUND;
          Base := Ord(tebHeaderBackgroundNormal);
        end;
      tebHeaderCloseNormal..tebHeaderClosePressed:
        begin
          Part := EBP_HEADERCLOSE;
          Base := Ord(tebHeaderCloseNormal);
        end;
      tebHeaderPinNormal..tebHeaderPinSelectedPressed:
        begin
          Part := EBP_HEADERPIN;
          Base := Ord(tebHeaderPinSelectedNormal);
        end;
      tebIEBarMenuNormal..tebIEBarMenuPressed:
        begin
          Part := EBP_IEBARMENU;
          Base := Ord(tebIEBarMenuNormal);
        end;
      tebNormalGroupBackground:
        begin
          Part := EBP_NORMALGROUPBACKGROUND;
          Base := Ord(tebNormalGroupBackground);
        end;
      tebNormalGroupCollapseNormal..tebNormalGroupCollapsePressed:
        begin
          Part := EBP_NORMALGROUPCOLLAPSE;
          Base := Ord(tebNormalGroupCollapseNormal);
        end;
      tebNormalGroupExpandNormal..tebNormalGroupExpandPressed:
        begin
          Part := EBP_NORMALGROUPEXPAND;
          Base := Ord(tebNormalGroupExpandNormal);
        end;
      tebNormalGroupHead:
        begin
          Part := EBP_NORMALGROUPHEAD;
          Base := Ord(tebNormalGroupHead);
        end;
      tebSpecialGroupBackground:
        begin
          Part := EBP_SPECIALGROUPBACKGROUND;
          Base := Ord(tebSpecialGroupBackground);
        end;
      tebSpecialGroupCollapseSpecial..tebSpecialGroupCollapsePressed:
        begin
          Part := EBP_SPECIALGROUPCOLLAPSE;
          Base := Ord(tebSpecialGroupCollapseSpecial);
        end;
      tebSpecialGroupExpandSpecial..tebSpecialGroupExpandPressed:
        begin
          Part := EBP_SPECIALGROUPEXPAND;
          Base := Ord(tebSpecialGroupExpandSpecial);
        end;
      tebSpecialGroupHead:
        begin
          Part := EBP_SPECIALGROUPHEAD;
          Base := Ord(tebSpecialGroupHead);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedHeader): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teHeader;
  with Result do
  begin
    case Detail of
      thHeaderItemNormal..thHeaderItemPressed:
        begin
          Part := HP_HEADERITEM;
          Base := Ord(thHeaderItemNormal);
        end;
      thHeaderItemLeftNormal..thHeaderItemLeftPressed:
        begin
          Part := HP_HEADERITEMLEFT;
          Base := Ord(thHeaderItemLeftNormal);
        end;
      thHeaderItemRightNormal..thHeaderItemRightPressed:
        begin
          Part := HP_HEADERITEMRIGHT;
          Base := Ord(thHeaderItemRightNormal);
        end;
      thHeaderSortArrowSortedUp..thHeaderSortArrowSortedDown:
        begin
          Part := HP_HEADERSORTARROW;
          Base := Ord(thHeaderSortArrowSortedUp);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedListview): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teListView;
  with Result do
  begin
    case Detail of
      tlListItemNormal..tlListItemSelectedNotFocus:
        begin
          Part := LVP_LISTITEM;
          Base := Ord(tlListItemNormal);
        end;
      tlListGroup:
        begin
          Part := LVP_LISTGROUP;
          Base := Ord(tlListGroup);
        end;
      tlListDetail:
        begin
          Part := LVP_LISTDETAIL;
          Base := Ord(tlListDetail);
        end;
      tlListSortDetail:
        begin
          Part := LVP_LISTSORTEDDETAIL;
          Base := Ord(tlListSortDetail);
        end;
      tlEmptyText:
        begin
          Part := LVP_EMPTYTEXT;
          Base := Ord(tlEmptyText);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedMenu): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teMenu;
  with Result do
  begin
    case Detail of
      tmMenuItemNormal..tmMenuItemDemoted:
        begin
          Part := MP_MENUITEM;
          Base := Ord(tmMenuItemNormal);
        end;
      tmMenuDropDown:
        begin
          Part := MP_MENUDROPDOWN;
          Base := Ord(tmMenuDropDown);
        end;
      tmMenuBarItem:
        begin
          Part := MP_MENUBARITEM;
          Base := Ord(tmMenuBarItem);
        end;
      tmMenuBarDropDown:
        begin
          Part := MP_MENUBARDROPDOWN;
          Base := Ord(tmMenuBarDropDown);
        end;
      tmChevron:
        begin
          Part := MP_CHEVRON;
          Base := Ord(tmChevron);
        end;
      tmSeparator:
        begin
          Part := MP_SEPARATOR;
          Base := Ord(tmSeparator);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedPage): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := tePage;
  with Result do
  begin
    case Detail of
      tpUpNormal..tpUpDisabled:
        begin
          Part := PGRP_UP;
          Base := Ord(tpUpNormal);
        end;
      tpDownNormal..tpDownDisabled:
        begin
          Part := PGRP_DOWN;
          Base := Ord(tpDownNormal);
        end;
      tpUpHorzNormal..tpUpHorzDisabled:
        begin
          Part := PGRP_UPHORZ;
          Base := Ord(tpUpHorzNormal);
        end;
      tpDownHorzNormal..tpDownHorzDisabled:
        begin
          Part := PGRP_DOWNHORZ;
          Base := Ord(tpDownHorzNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;  
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedProgress): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teProgress;
  with Result do
  begin
    case Detail of
      tpBar:
        begin
          Part := PP_BAR;
          Base := Ord(tpBar);
        end;
      tpBarVert:
        begin
          Part := PP_BARVERT;
          Base := Ord(tpBarVert);
        end;
      tpChunk:
        begin
          Part := PP_CHUNK;
          Base := Ord(tpChunk);
        end;
      tpChunkVert:
        begin
          Part := PP_CHUNKVERT;
          Base := Ord(tpChunkVert);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedRebar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teRebar;
  with Result do
  begin
    case Detail of
      trGripper:
        begin
          Part := RP_GRIPPER;
          Base := Ord(trGripper);
        end;
      trGripperVert:
        begin
          Part := RP_GRIPPERVERT;
          Base := Ord(trGripperVert);
        end;
      trBandNormal..trBandHotChecked:
        begin
          Part := RP_BAND;
          Base := Ord(trBandNormal);
        end;
      trChevronNormal..trChevronDisabled:
        begin
          Part := RP_CHEVRON;
          Base := Ord(trChevronNormal);
        end;
      trChevronVertNormal..trChevronVertDisabled:
        begin
          Part := RP_CHEVRONVERT;
          Base := Ord(trChevronVertNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedScrollBar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teScrollBar;
  with Result do
  begin
    case Detail of
      tsArrowBtnUpNormal..tsArrowBtnRightDisabled:
        begin
          Part := SBP_ARROWBTN;
          Base := Ord(tsArrowBtnUpNormal);
        end;
      tsThumbBtnHorzNormal..tsThumbBtnHorzDisabled:
        begin
          Part := SBP_THUMBBTNHORZ;
          Base := Ord(tsThumbBtnHorzNormal);
        end;
      tsThumbBtnVertNormal..tsThumbBtnVertDisabled:
        begin
          Part := SBP_THUMBBTNVERT;
          Base := Ord(tsThumbBtnVertNormal);
        end;
      tsLowerTrackHorzNormal..tsLowerTrackHorzDisabled:
        begin
          Part := SBP_LOWERTRACKHORZ;
          Base := Ord(tsLowerTrackHorzNormal);
        end;
      tsUpperTrackHorzNormal..tsUpperTrackHorzDisabled:
        begin
          Part := SBP_UPPERTRACKHORZ;
          Base := Ord(tsUpperTrackHorzNormal);
        end;
      tsLowerTrackVertNormal..tsLowerTrackVertDisabled:
        begin
          Part := SBP_LOWERTRACKVERT;
          Base := Ord(tsLowerTrackVertNormal);
        end;
      tsUpperTrackVertNormal..tsUpperTrackVertDisabled:
        begin
          Part := SBP_UPPERTRACKVERT;
          Base := Ord(tsUpperTrackVertNormal);
        end;
      tsGripperHorzNormal..tsGripperHorzDisabled:
        begin
          Part := SBP_GRIPPERHORZ;
          Base := Ord(tsGripperHorzNormal);
        end;
      tsGripperVertNormal..tsGripperVertDisabled:
        begin
          Part := SBP_GRIPPERVERT;
          Base := Ord(tsGripperVertNormal);
        end;
      tsSizeBoxRightAlign..tsSizeBoxLeftAlign:
        begin
          Part := SBP_SIZEBOX;
          Base := Ord(tsSizeBoxRightAlign);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedSpin): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teSpin;
  with Result do
  begin
    case Detail of
      tsUpNormal..tsUpDisabled:
        begin
          Part := SPNP_UP;
          Base := Ord(tsUpNormal);
        end;
      tsDownNormal..tsDownDisabled:
        begin
          Part := SPNP_DOWN;
          Base := Ord(tsDownNormal);
        end;
      tsUpHorzNormal..tsUpHorzDisabled:
        begin
          Part := SPNP_UPHORZ;
          Base := Ord(tsUpHorzNormal);
        end;
      tsDownHorzNormal..tsDownHorzDisabled:
        begin
          Part := SPNP_DOWNHORZ;
          Base := Ord(tsDownHorzNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedStartPanel): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teStartPanel;
  with Result do
  begin
    case Detail of
      tspUserPane:
        begin
          Part := SPP_USERPANE;
          Base := Ord(tspUserPane);
        end;
      tspMorePrograms:
        begin
          Part := SPP_MOREPROGRAMS;
          Base := Ord(tspMorePrograms);
        end;
      tspMoreProgramsArrowNormal..tspMoreProgramsArrowPressed:
        begin
          Part := SPP_MOREPROGRAMSARROW;
          Base := Ord(tspMoreProgramsArrowNormal);
        end;
      tspProgList:
        begin
          Part := SPP_PROGLIST;
          Base := Ord(tspProgList);
        end;
      tspProgListSeparator:
        begin
          Part := SPP_PROGLISTSEPARATOR;
          Base := Ord(tspProgListSeparator);
        end;
      tspPlacesList:
        begin
          Part := SPP_PLACESLIST;
          Base := Ord(tspPlacesList);
        end;
      tspPlacesListSeparator:
        begin
          Part := SPP_PLACESLISTSEPARATOR;
          Base := Ord(tspPlacesListSeparator);
        end;
      tspLogOff:
        begin
          Part := SPP_LOGOFF;
          Base := Ord(tspLogOff);
        end;
      tspLogOffButtonsNormal..tspLogOffButtonsPressed:
        begin
          Part := SPP_LOGOFFBUTTONS;
          Base := Ord(tspLogOffButtonsNormal);
        end;
      tspUserPicture:
        begin
          Part := SPP_USERPICTURE;
          Base := Ord(tspUserPicture);
        end;
      tspPreview:
        begin
          Part := SPP_PREVIEW;
          Base := Ord(tspPreview);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedStatus): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teStatus;
  with Result do
  begin
    case Detail of
      tsPane:
        begin
          Part := SP_PANE;
          Base := Ord(tsPane);
        end;
      tsGripperPane:
        begin
          Part := SP_GRIPPERPANE;
          Base := Ord(tsGripperPane);
        end;
      tsGripper:
        begin
          Part := SP_GRIPPER;
          Base := Ord(tsGripper);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTab): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTab;
  with Result do
  begin
    case Detail of
      ttTabItemNormal..ttTabItemFocused:
        begin
          Part := TABP_TABITEM;
          Base := Ord(ttTabItemNormal);
        end;
      ttTabItemLeftEdgeNormal..ttTabItemLeftEdgeFocused:
        begin
          Part := TABP_TABITEMLEFTEDGE;
          Base := Ord(ttTabItemLeftEdgeNormal);
        end;
      ttTabItemRightEdgeNormal..ttTabItemRightEdgeFocused:
        begin
          Part := TABP_TABITEMRIGHTEDGE;
          Base := Ord(ttTabItemRightEdgeNormal);
        end;
      ttTabItemBothEdgeNormal..ttTabItemBothEdgeFocused:
        begin
          Part := TABP_TABITEMBOTHEDGE;
          Base := Ord(ttTabItemBothEdgeNormal);
        end;
      ttTopTabItemNormal..ttTopTabItemFocused:
        begin
          Part := TABP_TOPTABITEM;
          Base := Ord(ttTopTabItemNormal);
        end;
      ttTopTabItemLeftEdgeNormal..ttTopTabItemLeftEdgeFocused:
        begin
          Part := TABP_TOPTABITEMLEFTEDGE;
          Base := Ord(ttTopTabItemLeftEdgeNormal);
        end;
      ttTopTabItemRightEdgeNormal..ttTopTabItemRightEdgeFocused:
        begin
          Part := TABP_TOPTABITEMRIGHTEDGE;
          Base := Ord(ttTopTabItemRightEdgeNormal);
        end;
      ttTopTabItemBothEdgeNormal..ttTopTabItemBothEdgeFocused:
        begin
          Part := TABP_TOPTABITEMBOTHEDGE;
          Base := Ord(ttTopTabItemBothEdgeNormal);
        end;
      ttPane:
        begin
          Part := TABP_PANE;
          Base := Ord(ttPane);
        end;
      ttBody:
        begin
          Part := TABP_BODY;
          Base := Ord(ttBody);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTaskBand): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTaskBand;
  with Result do
  begin
    case Detail of
      ttbGroupCount:
        begin
          Part := TDP_GROUPCOUNT;
          Base := Ord(ttbGroupCount);
        end;
      ttbFlashButton:
        begin
          Part := TDP_FLASHBUTTON;
          Base := Ord(ttbFlashButton);
        end;
      ttpFlashButtonGroupMenu:
        begin
          Part := TDP_FLASHBUTTONGROUPMENU;
          Base := Ord(ttpFlashButtonGroupMenu);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTaskBar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTaskBar;
  with Result do
  begin
    case Detail of
      ttbTimeNormal:
        begin
          Part := CLP_TIME;
          Base := Ord(ttbTimeNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedToolBar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teToolBar;
  with Result do
  begin
    case Detail of
      ttbButtonNormal..ttbButtonCheckedHot:
        begin
          Part := TP_BUTTON;
          Base := Ord(ttbButtonNormal);
        end;
      ttbDropDownButtonNormal..ttbDropDownButtonCheckedHot:
        begin
          Part := TP_DROPDOWNBUTTON;
          Base := Ord(ttbDropDownButtonNormal);
        end;
      ttbSplitButtonNormal..ttbSplitButtonCheckedHot:
        begin
          Part := TP_SPLITBUTTON;
          Base := Ord(ttbSplitButtonNormal);
        end;
      ttbSplitButtonDropDownNormal..ttbSplitButtonDropDownCheckedHot:
        begin
          Part := TP_SPLITBUTTONDROPDOWN;
          Base := Ord(ttbSplitButtonDropDownNormal);
        end;
      ttbSeparatorNormal..ttbSeparatorCheckedHot:
        begin
          Part := TP_SEPARATOR;
          Base := Ord(ttbSeparatorNormal);
        end;
      ttbSeparatorVertNormal..ttbSeparatorVertCheckedHot:
        begin
          Part := TP_SEPARATORVERT;
          Base := Ord(ttbSeparatorVertNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedToolTip): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teToolTip;
  with Result do
  begin
    case Detail of
      tttStandardNormal..tttStandardLink:
        begin
          Part := TTP_STANDARD;
          Base := Ord(tttStandardNormal);
        end;
      tttStandardTitleNormal..tttStandardTitleLink:
        begin
          Part := TTP_STANDARDTITLE;
          Base := Ord(tttStandardTitleNormal);
        end;
      tttBaloonNormal..tttBaloonLink:
        begin
          Part := TTP_BALLOON;
          Base := Ord(tttBaloonNormal);
        end;
      tttBaloonTitleNormal..tttBaloonTitleLink:
        begin
          Part := TTP_BALLOONTITLE;
          Base := Ord(tttBaloonTitleNormal);
        end;
      tttCloseNormal..tttClosePressed:
        begin
          Part := TTP_CLOSE;
          Base := Ord(tttCloseNormal);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTrackBar): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTrackBar;
  with Result do
  begin
    case Detail of
      ttbTrack:
        begin
          Part := TKP_TRACK;
          Base := Ord(ttbTrack);
        end;
      ttbTrackVert:
        begin
          Part := TKP_TRACKVERT;
          Base := Ord(ttbTrackVert);
        end;
      ttbThumbNormal..ttbThumbDisabled:
        begin
          Part := TKP_THUMB;
          Base := Ord(ttbThumbNormal);
        end;
      ttbThumbBottomNormal..ttbThumbBottomDisabled:
        begin
          Part := TKP_THUMBBOTTOM;
          Base := Ord(ttbThumbBottomNormal);
        end;
      ttbThumbTopNormal..ttbThumbTopDisabled:
        begin
          Part := TKP_THUMBTOP;
          Base := Ord(ttbThumbTopNormal);
        end;
      ttbThumbVertNormal..ttbThumbVertDisabled:
        begin
          Part := TKP_THUMBVERT;
          Base := Ord(ttbThumbVertNormal);
        end;
      ttbThumbLeftNormal..ttbThumbLeftDisabled:
        begin
          Part := TKP_THUMBLEFT;
          Base := Ord(ttbThumbLeftNormal);
        end;
      ttbThumbRightNormal..ttbThumbRightDisabled:
        begin
          Part := TKP_THUMBRIGHT;
          Base := Ord(ttbThumbRightNormal);
        end;
      ttbThumbTics:
        begin
          Part := TKP_TICS;
          Base := Ord(ttbThumbTics);
        end;
      ttbThumbTicsVert:
        begin
          Part := TKP_TICSVERT;
          Base := Ord(ttbThumbTicsVert);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTrayNotify): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTrayNotify;
  with Result do
  begin
    case Detail of
      ttnBackground:
        begin
          Part := TNP_BACKGROUND;
          Base := Ord(ttnBackground);
        end;
      ttnAnimBackground:
        begin
          Part := TNP_ANIMBACKGROUND;
          Base := Ord(ttnAnimBackground);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedTreeview): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teTreeView;
  with Result do
  begin
    case Detail of
      ttItemNormal..ttItemSelectedNotFocus:
        begin
          Part := TVP_TREEITEM;
          Base := Ord(ttItemNormal);
        end;
      ttGlyphClosed..ttGlyphOpened:
        begin
          Part := TVP_GLYPH;
          Base := Ord(ttGlyphClosed);
        end;
      ttBranch:
        begin
          Part := TVP_BRANCH;
          Base := Ord(ttBranch);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.GetElementDetails(Detail: TThemedWindow): TThemedElementDetails;

var
  Base: Integer;

begin
  Result.Element := teWindow;
  with Result do
  begin
    case Detail of
      twCaptionActive..twCaptionDisabled:
        begin
          Part := WP_CAPTION;
          Base := Ord(twCaptionActive);
        end;
      twSmallCaptionActive..twSmallCaptionDisabled:
        begin
          Part := WP_SMALLCAPTION;
          Base := Ord(twSmallCaptionActive);
        end;
      twMinCaptionActive..twMinCaptionDisabled:
        begin
          Part := WP_MINCAPTION;
          Base := Ord(twMinCaptionActive);
        end;
      twSmallMinCaptionActive..twSmallMinCaptionDisabled:
        begin
          Part := WP_SMALLMINCAPTION;
          Base := Ord(twSmallMinCaptionActive);
        end;
      twMaxCaptionActive..twMaxCaptionDisabled:
        begin
          Part := WP_MAXCAPTION;
          Base := Ord(twMaxCaptionActive);
        end;
      twSmallMaxCaptionActive..twSmallMaxCaptionDisabled:
        begin
          Part := WP_SMALLMAXCAPTION;
          Base := Ord(twSmallMaxCaptionActive);
        end;
      twFrameLeftActive..twFrameLeftInactive:
        begin
          Part := WP_FRAMELEFT;
          Base := Ord(twFrameLeftActive);
        end;
      twFrameRightActive..twFrameRightInactive:
        begin
          Part := WP_FRAMERIGHT;
          Base := Ord(twFrameRightActive);
        end;
      twFrameBottomActive..twFrameBottomInactive:
        begin
          Part := WP_FRAMEBOTTOM;
          Base := Ord(twFrameBottomActive);
        end;
      twSmallFrameLeftActive..twSmallFrameLeftInactive:
        begin
          Part := WP_SMALLFRAMELEFT;
          Base := Ord(twSmallFrameLeftActive);
        end;
      twSmallFrameRightActive..twSmallFrameRightInactive:
        begin
          Part := WP_SMALLFRAMERIGHT;
          Base := Ord(twSmallFrameRightActive);
        end;
      twSmallFrameBottomActive..twSmallFrameBottomInactive:
        begin
          Part := WP_SMALLFRAMEBOTTOM;
          Base := Ord(twSmallFrameBottomActive);
        end;
      twSysButtonNormal..twSysButtonDisabled:
        begin
          Part := WP_SYSBUTTON;
          Base := Ord(twSysButtonNormal);
        end;
      twMDISysButtonNormal..twMDISysButtonDisabled:
        begin
          Part := WP_MDISYSBUTTON;
          Base := Ord(twMDISysButtonNormal);
        end;
      twMinButtonNormal..twMinButtonDisabled:
        begin
          Part := WP_MINBUTTON;
          Base := Ord(twMinButtonNormal);
        end;
      twMDIMinButtonNormal..twMDIMinButtonDisabled:
        begin
          Part := WP_MDIMINBUTTON;
          Base := Ord(twMDIMinButtonNormal);
        end;
      twMaxButtonNormal..twMaxButtonDisabled:
        begin
          Part := WP_MAXBUTTON;
          Base := Ord(twMaxButtonNormal);
        end;
      twCloseButtonNormal..twCloseButtonDisabled:
        begin
          Part := WP_CLOSEBUTTON;
          Base := Ord(twCloseButtonNormal);
        end;
      twSmallCloseButtonNormal..twSmallCloseButtonDisabled:
        begin
          Part := WP_SMALLCLOSEBUTTON;
          Base := Ord(twSmallCloseButtonNormal);
        end;
      twMDICloseButtonNormal..twMDICloseButtonDisabled:
        begin
          Part := WP_MDICLOSEBUTTON;
          Base := Ord(twMDICloseButtonNormal);
        end;
      twRestoreButtonNormal..twRestoreButtonDisabled:
        begin
          Part := WP_RESTOREBUTTON;
          Base := Ord(twRestoreButtonNormal);
        end;
      twMDIRestoreButtonNormal..twMDIRestoreButtonDisabled:
        begin
          Part := WP_MDIRESTOREBUTTON;
          Base := Ord(twMDIRestoreButtonNormal);
        end;
      twHelpButtonNormal..twHelpButtonDisabled:
        begin
          Part := WP_HELPBUTTON;
          Base := Ord(twHelpButtonNormal);
        end;
      twMDIHelpButtonNormal..twMDIHelpButtonDisabled:
        begin
          Part := WP_MDIHELPBUTTON;
          Base := Ord(twMDIHelpButtonNormal);
        end;
      twHorzScrollNormal..twHorzScrollDisabled:
        begin
          Part := WP_HORZSCROLL;
          Base := Ord(twHorzScrollNormal);
        end;
      twHorzThumbNormal..twHorzThumbDisabled:
        begin
          Part := WP_HORZTHUMB;
          Base := Ord(twHorzThumbNormal);
        end;
      twVertScrollNormal..twVertScrollDisabled:
        begin
          Part := WP_VERTSCROLL;
          Base := Ord(twVertScrollNormal);
        end;
      twVertThumbNormal..twVertThumbDisabled:
        begin
          Part := WP_VERTTHUMB;
          Base := Ord(twVertThumbNormal);
        end;
      twDialog:
        begin
          Part := WP_DIALOG;
          Base := Ord(twDialog);
        end;
      twCaptionSizingTemplate:
        begin
          Part := WP_CAPTIONSIZINGTEMPLATE;
          Base := Ord(twCaptionSizingTemplate);
        end;
      twSmallCaptionSizingTemplate:
        begin
          Part := WP_SMALLCAPTIONSIZINGTEMPLATE;
          Base := Ord(twSmallCaptionSizingTemplate);
        end;
      twFrameLeftSizingTemplate:
        begin
          Part := WP_FRAMELEFTSIZINGTEMPLATE;
          Base := Ord(twFrameLeftSizingTemplate);
        end;
      twSmallFrameLeftSizingTemplate:
        begin
          Part := WP_SMALLFRAMELEFTSIZINGTEMPLATE;
          Base := Ord(twSmallFrameLeftSizingTemplate);
        end;
      twFrameRightSizingTemplate:
        begin
          Part := WP_FRAMERIGHTSIZINGTEMPLATE;
          Base := Ord(twFrameRightSizingTemplate);
        end;
      twSmallFrameRightSizingTemplate:
        begin
          Part := WP_SMALLFRAMERIGHTSIZINGTEMPLATE;
          Base := Ord(twSmallFrameRightSizingTemplate);
        end;
      twFrameBottomSizingTemplate:
        begin
          Part := WP_FRAMEBOTTOMSIZINGTEMPLATE;
          Base := Ord(twFrameBottomSizingTemplate);
        end;
      twSmallFrameBottomSizingTemplate:
        begin
          Part := WP_SMALLFRAMEBOTTOMSIZINGTEMPLATE;
          Base := Ord(twSmallFrameBottomSizingTemplate);
        end;
    else
      Part := 0;
      Base := 0;
    end;
    State := Ord(Detail) - Base + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.ColorToRGB(Color: TColor; Details: PThemedElementDetails = nil): COLORREF;

begin
  if (Color and $80000000 = 0) or (Details = nil) then
    Result := Color
  else
    Result := GetThemeSysColor(Theme[Details.Element], Color and not $80000000);
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.ContentRect(DC: HDC; Details: TThemedElementDetails; BoundingRect: TRect): TRect;

begin
  with Details do
    GetThemeBackgroundContentRect(Theme[Element], DC, Part, State, BoundingRect, @Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DrawEdge(DC: HDC; Details: TThemedElementDetails; const R: TRect; Edge, Flags: Cardinal;
  ContentRect: PRect = nil);

begin
  with Details do
    DrawThemeEdge(Theme[Element], DC, Part, State, R, Edge, Flags, ContentRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DrawElement(DC: HDC; Details: TThemedElementDetails; const R: TRect; ClipRect: PRect = nil);

begin
  with Details do
    DrawThemeBackground(Theme[Element], DC, Part, State, R, ClipRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DrawIcon(DC: HDC; Details: TThemedElementDetails; const R: TRect; himl: HIMAGELIST;
  Index: Integer);

begin
  with Details do
    DrawThemeIcon(Theme[Element], DC, Part, State, R, himl, Index);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DrawParentBackground(Window: HWND; Target: HDC; Details: PThemedElementDetails;
  OnlyIfTransparent: Boolean; Bounds: PRect = nil);

var
  DoDraw: Boolean;

begin
  if OnlyIfTransparent and Assigned(Details) then
  begin
    with Details^ do
      DoDraw := IsThemeBackgroundPartiallyTransparent(Theme[Element], Part, State);
  end
  else
    DoDraw := True;
  if DoDraw then
    DrawThemeParentBackground(Window, Target, Bounds);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.DrawText(DC: HDC; Details: TThemedElementDetails; const S: WideString; R: TRect; Flags,
  Flags2: Cardinal);

begin
  with Details do
    DrawThemeText(Theme[Element], DC, Part, State, PWideChar(S), Length(S), Flags, Flags2, R);
end;

//----------------------------------------------------------------------------------------------------------------------

function TThemeServices.HasTransparentParts(Details: TThemedElementDetails): Boolean;

begin
  with Details do
    Result := IsThemeBackgroundPartiallyTransparent(Theme[Element], Part, State);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TThemeServices.PaintBorder(Control: TWinControl; EraseLRCorner: Boolean);

var
  EmptyRect,
  DrawRect: TRect;
  DC: HDC;
  H, W: Integer;
  AStyle,
  ExStyle: Integer;
  Details: TThemedElementDetails;

begin
  with Control do
  begin
    ExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if (ExStyle and WS_EX_CLIENTEDGE) <> 0 then
    begin
      GetWindowRect(Handle, DrawRect);
      OffsetRect(DrawRect, -DrawRect.Left, -DrawRect.Top);
      DC := GetWindowDC(Handle);
      try
        EmptyRect := DrawRect;
        if EraseLRCorner then
        begin
          AStyle := GetWindowLong(Handle, GWL_STYLE);
          if ((AStyle and WS_HSCROLL) <> 0) and ((AStyle and WS_VSCROLL) <> 0) then
          begin
            W := GetSystemMetrics(SM_CXVSCROLL);
            H := GetSystemMetrics(SM_CYHSCROLL);
            InflateRect(EmptyRect, -2, -2);
            with EmptyRect do
              EmptyRect := Rect(Right - W, Bottom - H, Right, Bottom);
            FillRect(DC, EmptyRect, GetSysColorBrush(COLOR_BTNFACE));
          end;
        end;
        with DrawRect do
          ExcludeClipRect(DC, Left + 2, Top + 2, Right - 2, Bottom - 2);
        Details := GetElementDetails(teEditTextNormal);
        DrawElement(DC, Details, DrawRect);
      finally
        ReleaseDC(Handle, DC);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

const
  ComCtlVersionIE6 = $00060000;

procedure TThemeServices.UpdateThemes;

var
  Flags: DWORD;
  
begin
  if FUseThemes then
    UnloadThemeData;
  FUseThemes := UseThemes and (GetComCtlVersion >= ComCtlVersionIE6);

  if FUseThemes then
  begin
    Flags := GetThemeAppProperties;
    if (Flags and STAP_ALLOW_CONTROLS) = 0 then
      FControlsEnabled := False
    else
      FControlsEnabled := True;
  end
  else
    FControlsEnabled := False;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization
finalization
  InternalThemeServices.Free;
end.