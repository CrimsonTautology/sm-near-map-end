#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION		"1.0.0"
#define PLUGIN_NAME         "[FoF] Near Map End Gimmicks"

new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_NearMapEndTime = INVALID_HANDLE;
new bool:g_InNearMapEnd = false;

#define MAX_GIMMICKS		21
enum gimmicks
{
    GIMMICK_AXE = 0,
    GIMMICK_MACHETE,
    //GIMMICK_JETPACK,
    GIMMICK_SUPER_KICK,
    GIMMICK_TINY,
    GIMMICK_SNIPER,
    GIMMICK_SHOTGUN,
    GIMMICK_WALKER,
    GIMMICK_BOW,
    //GIMMICK_DYNAMITE,
    GIMMICK_DERINGER,
    GIMMICK_VOLCANIC,
    GIMMICK_PEACEMAKER,
    GIMMICK_GHOSTS,
    GIMMICK_HORSES,
    GIMMICK_KABOOM,

    GIMMICK_MARESLEG,
    GIMMICK_SAWEDOFF,
    GIMMICK_COACHGUN,
    GIMMICK_SMITH,
    GIMMICK_HENRY,
}

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Choose a random gimmick near map end",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm_near_map_end"
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

public Action:Timer_Repeat(Handle:timer)
{
    if(!IsNearMapEndEnabled()) return Plugin_Handled;
    if(InNearMapEnd()) return Plugin_Handled;

    new time_left, near_map_end_time;
    GetMapTimeLeft(time_left);
    near_map_end_time = GetConVarInt(g_Cvar_NearMapEndTime);

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

    //Get random gimmick
    switch(GetRandomInt(0, MAX_GIMMICKS - 1))
    {
        /*
        case(GIMMICK_JETPACK):
        {
            PrintCenterTextAll("STEAM POWERED JETPACKS ENABLED (hold jump)");
            ServerCommand("sm_jetpack 1");
            LogMessage("Started jetpacks");
        }
        */

        case(GIMMICK_SUPER_KICK):
        {
            PrintCenterTextAll("SUPER KICKS ENABLED (kick people)");
            ServerCommand("sm_super_kick 1");
            LogMessage("Started super kick");
        }

        case(GIMMICK_TINY):
        {
            PrintCenterTextAll("TINY MODE");
            ServerCommand("sm_resize_enabled 1");
            ServerCommand("sm_resize_joinstatus 1");
            ServerCommand("sm_resize @all");
            pitch = 175;
            LogMessage("Started tiny mode");
        }

        case(GIMMICK_AXE):
        {
            PrintCenterTextAll("HERE'S JOHNNY");
            ServerCommand("sm_weapon_only_weapon weapon_axe");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started axe only mode");
        }

        case(GIMMICK_MACHETE):
        {
            PrintCenterTextAll("HERE'S JASON");
            ServerCommand("sm_weapon_only_weapon weapon_machete");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started machete only mode");
        }

        case(GIMMICK_SNIPER):
        {
            PrintCenterTextAll("SNIPER MODE");
            ServerCommand("sm_weapon_only_weapon weapon_sharps");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started sniper mode");
        }

        case(GIMMICK_WALKER):
        {
            PrintCenterTextAll("Is the Walker OP?");
            ServerCommand("sm_weapon_only_weapon weapon_walker");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started walker mode");
        }

        /*
        case(GIMMICK_DYNAMITE):
        {
            PrintCenterTextAll("DYNAMITE ONLY");
            ServerCommand("sm_weapon_only_weapon weapon_dynamite_black");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started dynamite mode");
        }
        */

        case(GIMMICK_BOW):
        {
            PrintCenterTextAll("Here come the Indians");
            ServerCommand("sm_weapon_only_weapon weapon_bow");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started bow and arrow mode");
        }

        case(GIMMICK_SHOTGUN):
        {
            PrintCenterTextAll("RUN AND GUN");
            ServerCommand("sm_weapon_only_weapon weapon_shotgun");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started shotgun mode");
        }

        case(GIMMICK_DERINGER):
        {
            PrintCenterTextAll("DERINGERS");
            ServerCommand("sm_weapon_only_weapon weapon_deringer");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started deringer mode");
        }

        case(GIMMICK_VOLCANIC):
        {
            PrintCenterTextAll("VOLCANO");
            ServerCommand("sm_weapon_only_weapon weapon_volcanic");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started volcanic mode");
        }

        case(GIMMICK_PEACEMAKER):
        {
            PrintCenterTextAll("This is the greatest handgun ever made");
            ServerCommand("sm_weapon_only_weapon weapon_peacemaker");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started peacemaker mode");
        }

        case(GIMMICK_GHOSTS):
        {
            PrintCenterTextAll("G-G-Ghosts!");
            ServerCommand("sm_death_chance_class fof_ghost");
            ServerCommand("sm_death_chance_percentage 0.25");
            ServerCommand("sm_death_chance_ammount 1");
            ServerCommand("sm_death_chance 1");
            LogMessage("Started ghosts mode");
        }

        case(GIMMICK_HORSES):
        {
            PrintCenterTextAll("HORSE MODE: ACTIVE");
            ServerCommand("sm_death_chance_class npc_horse");
            ServerCommand("sm_death_chance_percentage 0.25");
            ServerCommand("sm_death_chance_ammount 1");
            ServerCommand("sm_death_chance 1");
            LogMessage("Started horses mode");
        }

        case(GIMMICK_KABOOM):
        {
            PrintCenterTextAll("KABOOM");
            ServerCommand("sm_death_chance_class npc_handgrenade");
            ServerCommand("sm_death_chance_percentage 1.0");
            ServerCommand("sm_death_chance_ammount 1");
            ServerCommand("sm_death_chance 1");
            LogMessage("Started kaboom mode");
        }

        case(GIMMICK_MARESLEG):
        {
            PrintCenterTextAll("Everybody's favorite gun!");
            ServerCommand("sm_weapon_only_weapon weapon_maresleg");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started mare's leg mode");
        }

        case(GIMMICK_SAWEDOFF):
        {
            PrintCenterTextAll("Sawed Off Mode");
            ServerCommand("sm_weapon_only_weapon weapon_sawedoff_shotgun");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started sawedoff mode");
        }

        case(GIMMICK_COACHGUN):
        {
            PrintCenterTextAll("COACH");
            ServerCommand("sm_weapon_only_weapon weapon_coachgun");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started coachgun mode");
        }

        case(GIMMICK_SMITH):
        {
            PrintCenterTextAll("SMITH");
            ServerCommand("sm_weapon_only_weapon weapon_carbine");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started smith carbine mode");
        }

        case(GIMMICK_HENRY):
        {
            PrintCenterTextAll("HENRY");
            ServerCommand("sm_weapon_only_weapon weapon_henryrifle");
            ServerCommand("sm_weapon_only 1");
            LogMessage("Started henry rifle mode");
        }

        //ideas

        //Land of chocolate
        //sv_cheats 1; mat_fullbright 2; sv_cheats 0

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
