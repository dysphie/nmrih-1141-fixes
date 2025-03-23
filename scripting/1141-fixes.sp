#include <sourcemod>
#include <dhooks>

#define GAMEDATA_FILE "1141-fixes.games"

#define ZOMBIE_HEAD_ZPOS 70.0
#define ZOMBIE_CRAWLER_HEAD_ZPOS 16.0
#define NOP 0x90

public Plugin myinfo =
{
	name = "1.14.1 Hotfixes",
	author = "Dysphie & Felis",
	description = "Fixes immortal zombies and bulleyes in 1.14.1",
	version = "1.0.0",
	url = ""
};

int offset_IsCrawler;
Address fn_PassesFilterImpl;
bool g_IsLinux;

public void OnPluginStart()
{
	ConVar version = FindConVar("nmrih_version");
	char versionStr[16];
	version.GetString(versionStr, sizeof(versionStr));
	if (!StrEqual(versionStr, "1.14.1")) SetFailState("This plugin is only needed in 1.14.1. You're in version %s", versionStr);

	GameData gamedata = new GameData(GAMEDATA_FILE);
	if (!gamedata) SetFailState("Failed to find gamedata/" ... GAMEDATA_FILE ... ".txt");
	
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, "CNMRiH_BaseZombie::CanAttackEntity");
	detour.Enable(Hook_Pre, Detour_CanAttackEntity);
	delete detour;

	offset_IsCrawler = gamedata.GetOffset("CNMRiH_BaseZombie::IsCrawler");
	if (offset_IsCrawler == -1) SetFailState("Failed to find CNMRiH_BaseZombie::IsCrawler offset");

	fn_PassesFilterImpl = gamedata.GetMemSig("CFilterName::PassesFilterImpl");
	if (!fn_PassesFilterImpl) SetFailState("Failed to find CFilterName::PassesFilterImpl address");

	char isLinux[2];
	gamedata.GetKeyValue("IsLinux", isLinux, sizeof(isLinux));
	g_IsLinux = StrEqual(isLinux, "1");

	PatchNameFilter();
	PrintToServer("Enabled 1.14.1 hotfixes");
	
	delete gamedata;
}

public void OnPluginEnd()
{
	UnpatchNameFilter();
	PrintToServer("Disabled 1.14.1 hotfixes");
}

void PatchNameFilter()
{
	// CFilterName::PassesFilterImpl incorrectly returns false for damage without a caller
	// remove the `if (!pCaller)` check altogether, it's handled elsewhere
	if (g_IsLinux)
	{
		PatchByte(fn_PassesFilterImpl, 19, 0x74, NOP);
		PatchByte(fn_PassesFilterImpl, 20, 0x5B, NOP);
	}
	else
	{
		PatchByte(fn_PassesFilterImpl, 11, 0x74, NOP);
		PatchByte(fn_PassesFilterImpl, 12, 0x72, NOP);
	}
}

void UnpatchNameFilter()
{
	if (g_IsLinux)
	{
		PatchByte(fn_PassesFilterImpl, 19, NOP, 0x74);
		PatchByte(fn_PassesFilterImpl, 20, NOP, 0x5B);
	}
	else
	{
		PatchByte(fn_PassesFilterImpl, 11, NOP, 0x74);
		PatchByte(fn_PassesFilterImpl, 12, NOP, 0x72);
	}
}

MRESReturn Detour_CanAttackEntity(int zombie, DHookReturn ret, DHookParam params)
{
	int target = params.Get(1);
	if (target == -1) return MRES_Ignored;
	
	// 1.14.1 accidentally removes bulleye handling for zombies, so reimplment it here
	char classname[13];
	GetEntityClassname(target, classname, sizeof(classname));

	if (StrEqual(classname, "npc_bullseye"))
	{
		float pos[3]; float targetPos[3];
		GetEntPropVector(zombie, Prop_Data, "m_vecAbsOrigin", pos);
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetPos);
		pos[2] += IsZombieCrawler(zombie) ? ZOMBIE_CRAWLER_HEAD_ZPOS : ZOMBIE_HEAD_ZPOS;

		TR_TraceRayFilter(pos, targetPos, MASK_SOLID, RayType_EndPoint, TraceFilter_IgnoreOne, zombie);

		if (!TR_DidHit())
		{
			if (!params.IsNull(2))
			{
				float startPos[3], endPos[3]; 
				TR_GetStartPosition(null, startPos);
				TR_GetEndPosition(endPos, null);

				// CNMRiH_BaseZombie::MeleeAttack1Conditions expects these to be set in the CGameTrace
				params.SetObjectVarVector(2, 0x0, ObjectValueType_Vector, startPos); // CGameTrace::startpos
				params.SetObjectVarVector(2, 0xC, ObjectValueType_Vector, endPos); // CGameTrace::endpos
				params.SetObjectVar(2, 0x2C, ObjectValueType_Float, TR_GetFraction()); // CGameTrace::fraction
				params.SetObjectVar(2, 0x4C, ObjectValueType_CBaseEntityPtr, zombie); // CGameTrace::m_pEnt
			}

			ret.Value = true;
			return MRES_Override;
		}
	}
	return MRES_Ignored;
}

bool TraceFilter_IgnoreOne(int entity, int contentsMask, int ignore)
{
	return entity != ignore;
}

bool IsZombieCrawler(int zombie)
{
    return GetEntData(zombie, offset_IsCrawler, 1) != 0;
}

void PatchByte(Address addr, int offset, int verify, int patch)
{
	int original = LoadFromAddress(addr + view_as<Address>(offset), NumberType_Int8);
	if (original != verify && original != patch)
	{
		SetFailState("Expected byte %x, got %x", verify, patch, original);
		return;
	}

	StoreToAddress(addr + view_as<Address>(offset), patch, NumberType_Int8);
}