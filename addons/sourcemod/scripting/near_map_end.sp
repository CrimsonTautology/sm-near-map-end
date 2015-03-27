#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION		"1.0.0"
#define PLUGIN_NAME         "[FoF] Near Map End Gimmicks"

new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_NearMapEndTime = INVALID_HANDLE;
new bool:g_InNearMapEnd = false;

#define MAX_GIMMICKS		4
enum gimmicks
{
    GIMMICK_MELEE = 0,
    GIMMICK_JETPACK,
    GIMMICK_SUPER_KICK,
    GIMMICK_TINY
}

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Choose a random gimmick near map end",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/"
};

public OnPluginStart()
{
    CreateConVar( "sm_near_map_end_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar(
            "sm_near_map_end",
            "1",
            "Set to 1 to enable the near map end plugin",
            FCVAR_PLUGIN | FCVAR_REPLICATED | FCVAR_NOTIFY,
            true,
            0.0,
            true,
            1.0);
    g_Cvar_NearMapEndTime = CreateConVar(
            "sm_near_map_end_time",
            "60",
            "Enable near map end at this time from end (in seconds)",
            FCVAR_PLUGIN,
            true,
            0.0);

    AutoExecConfig();
}

public OnMapStart()
{
    g_InNearMapEnd = false;
    CreateTimer( 1.0, Timer_Repeat, .flags = TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
    PrecacheSound( "vehicles/train/whistle.wav", true );
}

bool:IsNearMapEndEnabled()
{
    return GetConVarBool(g_Cvar_Enabled) && GetConVarInt(g_Cvar_NearMapEndTime) > 0;
}

bool:InNearMapEnd()
{
    return g_InNearMapEnd;
}

public Action:Timer_Repeat( Handle:timer, any:player )
{
    if(!IsNearMapEndEnabled()) return Plugin_Handled;
    if(InNearMapEnd()) return Plugin_Handled;

    new time_left, near_map_end_time;
    GetMapTimeLeft(time_left);
    near_map_end_time = GetConVarInt(g_Cvar_NearMapEndTime);

    //LogMessage("HIT %d", time_left);//TODO
    
    if(time_left > 0 && time_left <= near_map_end_time)
    {
        g_InNearMapEnd = true;
        StartNearMapEnd();
    }

    return Plugin_Handled;
}

public StartNearMapEnd()
{
    new pitch = GetRandomInt(85, 110);

    //Set some end of map settings
    ServerCommand("fof_sv_item_respawn_time 1.0");
    ServerCommand("fof_sv_wcrate_regentime 1.0");
    ServerCommand("mp_disable_respawn_times 1"); //Does this do anything?

    //Get random gimmick
    switch(GetRandomInt(0, MAX_GIMMICKS - 1))
    {
        case(GIMMICK_MELEE):
        {
            PrintCenterTextAll("IT'S A FISTFIGHT TIME!");
            ServerCommand("fof_melee_only 1");
            LogMessage("Started melee only");//TODO
        }

        case(GIMMICK_JETPACK):
        {
            PrintCenterTextAll("STEAM POWERED JETPACKS ENABLED (hold jump)");
            ServerCommand("sm_jetpack 1");
            LogMessage("Started jetpacks");//TODO
        }

        case(GIMMICK_SUPER_KICK):
        {
            PrintCenterTextAll("SUPER KICKS ENABLED (kick people)");
            ServerCommand("sm_super_kick 1");
            LogMessage("Started super kick");//TODO
        }

        case(GIMMICK_TINY):
        {
            PrintCenterTextAll("TINY MODE");
            ServerCommand("sm_resize_enabled 1");
            ServerCommand("sm_resize_joinstatus 1");
            ServerCommand("sm_resize @all");
            pitch = 175;
            LogMessage("Started tiny mode");//TODO
        }
    }
    

    for (new client=1; client <= MaxClients; client++)
    {
        if(!IsClientInGame(client)) continue;

        CreateTimer(GetRandomFloat( 0.0, 2.0 ), Timer_PlayerTaunt, GetClientUserId(client));
        EmitSoundToClient(client, "vehicles/train/whistle.wav", .flags = SND_CHANGEPITCH, .pitch = pitch );
    }
}

public Action:Timer_PlayerTaunt( Handle:timer, any:player )
{
    new client = GetClientOfUserId(player);

    if(client <= 0) return Plugin_Stop;
    if(!IsClientInGame(client)) return Plugin_Stop;
    if(!IsPlayerAlive(client)) return Plugin_Stop;

    ForceTaunt(client);

    return Plugin_Stop;
}

public ForceTaunt(client)
{
    FakeClientCommand(client, "vc 8 3");
}
