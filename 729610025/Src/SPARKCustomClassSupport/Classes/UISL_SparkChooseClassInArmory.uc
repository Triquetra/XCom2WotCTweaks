class UISL_SparkChooseClassInArmory extends UIScreenListener config(Game);

var config bool ForceDetectDefaultScreen;

event OnInit(UIScreen Screen)
{
	if (UISquadSelect(Screen) != none)
		RemoveUnclassedSparks(UISquadSelect(Screen));

	if(class'XComModOptions'.default.ActiveMods.Find("LW_PerkPack") != INDEX_NONE && !default.ForceDetectDefaultScreen)
	{
		if (Screen.IsA('UIArmory_LWExpandedPromotion'))
			ForcePickClass(UIArmory_Promotion(Screen));
		return;
	}

	if (UIArmory_Promotion(Screen) != none)
		ForcePickClass(UIArmory_Promotion(Screen));
}

event OnReceiveFocus(UIScreen Screen)
{
	if (UISquadSelect(Screen) != none)
		RemoveUnclassedSparks(UISquadSelect(Screen));

	if(class'XComModOptions'.default.ActiveMods.Find("LW_PerkPack") != INDEX_NONE && !default.ForceDetectDefaultScreen)
	{
		if (Screen.IsA('UIArmory_LWExpandedPromotion'))
			ForcePickClass(UIArmory_Promotion(Screen));
		return;
	}

	if (UIArmory_Promotion(Screen) != none)
		ForcePickClass(UIArmory_Promotion(Screen));
}

simulated function RemoveUnclassedSparks(UISquadSelect Screen)
{
	local int i, SlotIndex, PickedSlot;
	local XComGameState_Unit UnitState;
	local UISquadSelect_ListItem ListItem;
	local StateObjectReference EmptyRef;

	PickedSlot = -1;
	
	`log("Checking Squad List",, 'ChoosableSparks');
	for (i = 0; i < `XCOMHQ.Squad.Length; i++)
	{
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.Squad[i].ObjectID));
		if (UnitState != none && UnitState.GetSoldierClassTemplateName() == 'SparkChooseClass')
		{
			for (SlotIndex = 0; SlotIndex < Screen.SlotListOrder.Length; ++SlotIndex)
			{
				if (i == Screen.SlotListOrder[SlotIndex])
				{
					PickedSlot = SlotIndex;
				}
			}

			if (PickedSlot == -1)
				PickedSlot = i;

			`log("Clearing" @ PickedSlot @"slot from squad because that spark's class is not picked yet",, 'ChoosableSparks');
			ListItem = UISquadSelect_ListItem(Screen.m_kSlotList.GetItem(PickedSlot));
			ListItem.OnClickedDismissButton();
			`XCOMHQ.Squad[i] = EmptyRef;
		}
	}
}

simulated function ForcePickClass(UIArmory_Promotion Screen)
{
	local UI_SelectSparkClasses Alert;

	// Prevent double dialog
	if (`HQPRES.ScreenStack.HasInstanceOf(class'UI_SelectSparkClasses'))
		return;

	if (Screen.GetUnit() != none && Screen.GetUnit().GetSoldierClassTemplateName() == 'SparkChooseClass')
	{
		Alert = `HQPRES.Spawn(class'UI_SelectSparkClasses', `HQPRES);
		Alert.UnitRef = Screen.GetUnitRef();
		Screen.OnCancel(); // Pop out
		`HQPRES.ScreenStack.Push(Alert);
	}
}