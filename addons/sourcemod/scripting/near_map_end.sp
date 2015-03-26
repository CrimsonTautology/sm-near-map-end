#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION		"1.0.0"
#define PLUGIN_NAME         "[FoF] Near Map End Gimmicks"

new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_NearMapEndTime = INVALID_HANDLE;
new Handle:mp_teamplay = INVALID_HANDLE;
new Handle:fof_sv_maxteams = INVALID_HANDLE;
new g_NearMapEndTime = 0;
new bool:g_InNearMapEndTime = false;
new bool:bAutoFF = false;
new bool:bTeamPlay = false;
new nMaxTeams = 2;

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
    HookConVarChange(g_Cvar_Enabled, OnEnabledChange);

    g_Cvar_NearMapEndTime = CreateConVar(
            "sm_near_map_end_time",
            "60",
            "Enable near map end at this time from end (in seconds)",
            FCVAR_PLUGIN,
            true,
            0.0);

    AutoExecConfig();

    mp_teamplay = FindConVar( "mp_teamplay" );
    fof_sv_maxteams = FindConVar( "fof_sv_maxteams" );

    HookEvent( "player_activate", Event_PlayerActivate );
    HookEvent( "player_spawn", Event_PlayerSpawn );

    for( new iClient = 1; iClient <= MaxClients; iClient++ )
        if( IsClientConnected( iClient ) )
            SDKHook( iClient, SDKHook_OnTakeDamage, OnPlayerTakeDamage );
}

public OnMapStart()
{
    g_InNearMapEndTime = false;
    CreateTimer( 1.0, Timer_Repeat, .flags = TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
    PrecacheSound( "vehicles/train/whistle.wav", true );
}

public OnConfigsExecuted()
{
    g_NearMapEndTime = GetConVarInt(g_Cvar_NearMapEndTime);
}

public OnEnabledChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_Enabled) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
    }

    //When changing from off to on
    if(!was_on && now_on)
    {
    }
}

bool:IsNearMapEndEnabled()
{
    return GetConVarBool(g_Cvar_Enabled);
}

public Action:Timer_Repeat( Handle:hTimer, any:iUserID )
{
    new time_left, bool:bAutoFF_new;
    GetMapTimeLeft(time_left);
    bAutoFF_new = g_NearMapEndTime > 0 && time_left > 0 && time_left <= g_NearMapEndTime;
    if( bAutoFF != bAutoFF_new && bAutoFF_new)
    {
        StartNearMapEnd();
    }
    bAutoFF = bAutoFF_new;
    return Plugin_Handled;
}

public StartNearMapEnd()
{
    PrintCenterTextAll("IT'S A FISTFIGHT TIME!");

    new pitch = GetRandomInt(85, 110);
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
