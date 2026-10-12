Changelog.currentVersion = '1.13.0.3'
Changelog.ChangelogText = {
    {
        version = '1.13.1',
        Text = {
            [[ SETTINGS:]],
            [[    CharacterLight is Off by default. Don't forget that you can make it On by default in the Settings]],
        }
    },
    {
        version = '1.13.0',
        Text = {
            [[ BONE ZONE:]],
            [[    Added Undo/Redo for symmetry]],
            [[    Poses load kind a bit faster (no difference)]],
            [[    Some unslopies]],
            [[    Small clarification for Bone Zone category export as a mod (in the info)]],

            [[ SETTINGS:]],
            [[    Added Auto open Gizmo Toolbar when entering photo mode]],
            [[    Added Remove distance (radius around the character where fadeables get removed),
                  Batch size (amount of objects removed per tick (basically "time")),
                  Tick interval (interval between removing each batch) for Remove fadeables.
                  All this increase processing speed.
                  In the city, 200 batch size and 3 tick interval works good for me]],

            [[ USEFUL:]],
            [[    Added Disable combat for all characters; prevents all characters to join combat. Savefile persistant!]],
            [[    Added Disable crowd; you need to save-load or load a savefile after toggling it]],

            [[ ANL:]],
            [[    Fixed Favorites]],
        }
    },
    {
        version = '1.12.1',
        Text = {
            [[ FIXED:]],
            [[    Save/Load camera position]],
            [[    Load dummy positions when entering photo mode]],
        }
    },
    {
        version = '1.12.0',
        Text = {
            [[ ANAL:]],
            [[    Removed some Parameters from random affection.
    Some parameters need to be Enabled in order to be randomed: Fog]],
            [[    When you switch to an atmosphere with enabled dof, dof will be disabled,
    so it doesn't break photo mode dof controls. It enables back when you switch to another atmosphere]],
            [[ UI:]],
            [[    Mod's window hides when hiding UI with default F10 keybind. Can be disabled]],
            [[    Dummy Save/Load postion window area thingy has a static size now]],
            [[ BONE ZONE:]],
            [[    Added Quick Save; creates Quick Save category and quickly saved pose with character's name
    that you can use as temporary "buffer". Later you can save it properly]],
            [[    Added keybind for Quick Save; Shift+S by default]],
            [[ BS:]],
            [[    Dummy Save/Load postion unslopies]],
            [[    Removed a thing that would update DoF in PM tab when you control DoF in vanilla UI]],
            [[ FIXED:]],
            [[    Renaming thing (fixed like 2 versions ago)]],
        }
    },
    {
        version = '1.11.0',
        Text = {
            [[ ANL:]],
            [[    Added Select current atmosphere and lighting; selects current level's atmosphere and lighting]],
            [[    Added right click to reset parameter for atmosphere and lighitng Parameters; to reset Parameters individually]],
            [[    Adjusted a lot of minimal and maximal values for Parameters]],
            [[    Removed some Parameters from random affection.
    Some parameters need to be Enabled in order to be randomed: Sun, Moon, Volumetric Clouds]],
            [[ BPNE ZONE:]],
            [[    Added bones search also searches whole tree.
    For example you can search for Arms, and it will show whole Arms tree]],
            [[ UI:]],
            [[    Added floating tabs; tabs that are always at the top of the window. Enable in Settings (garbage)]],
            [[ SETTINGS:]],
            [[    Added Camera offset; a setting to increas a janky thing that allows to switch atmosphere and lighting.
    Less fps you have - higher the value you need to set. 0.002 is a default value and works good with 30fps]],
            [[ UPDATED:]],
            [[    Mazzle beam. Now in cone shape. Looks awful. I like it.]],
            [[ FIXED:]],
            [[    Nzx fix]],
            [[    Mazzle beam]],
            [[    Atmosphere parameters not applying automatically]],
            [[ SMALL:]],
            [[    Bumbped version of atmosphere and lighting cache; some atmospheres and lightings will reset correctly now]],
            [[    Renamed Add buttons to Add to favorites]],
            [[    Renamed Mazzle beam to Mazzle beams]],
        }
    },
    {
        version = '1.10.3',
        Text = {
            [[ FIXED:]],
            [[    Fixed and issue with syncing dummies and qsat characters lists]],
        }
    },
    {
        version = '1.10.2',
        Text = {
            [[ FIXED:]],
            [[    Fixed and issue with Bone Zone gradients]],
        }
    },
    {
        version = '1.10.0',
        Text = {
            [[ ADDED:]],
            [[    Added Remove blood puddles in Useful]],
            [[ FIKSED:]],
            [[    Fixed THAT postion error when moving or creating lights]],
            [[    Fixed a flaw with Settings. Now they should save fine. Your settings will reset probably]],
            [[    Unclanked reset buttons for dummies position, rotation, scale]],
        }
    },
    {
        version = '1.9.9',
        Text = {
            [[ ADDED:]],
            [[    Added anti spam delay for creating lights. Perhaps for some time]],
            [[    Read 1.9.6 changelog below if you haven't read it yet]],
        }
    },
    {
        version = '1.9.8',
        Text = {
            [[ FIKSED:]],
            [[    Fixed an issue with selectin lights in Created lights list (fr)]],
            [[    Fixed an issue with creating and duplicating lights, when light type wasn't correct]],
            [[    Read 1.9.6 changelog below if you haven't read it yet]],
        }
    },
    {
        version = '1.9.7',
        Text = {
            [[ FIKSED:]],
            [[    Fixed an issue with selectin lights in Created lights list]],
            [[    Read 1.9.6 changelog below if you haven't read it yet]],
        }
    },
    {
        version = '1.9.6',
        Text = {
            [[ ORIGIN POINT:]],
            [[   Red crystal for Origin point]],
            [[ ANAL:]],
            [[   You can select lighting without harsh shadows and use it as parent for a lighting that has harsh shadows
    Select a lighting that doesn't have hars shadows
    Click on I'dont see harsh shadows with this lighting
    Choose a lighting with harsh shadows
    Click on Fix harsh shadows using:

    This is just a workaround and authors still need to render light probes]],
            [[   Additionally you can scroll through available for current level light probes to fix harsh shadows with < >]],
            [[   Parameters apply instantly but if selected lighting has light probes, it will flicker while changing parameters]],
            [[   Changed all sliders to drag sliders. Hold alt to change value precisely, hold shif to change it unprecisely]],
            [[   Now works on Act 1 level and all modded levels that did't have the support.
    Authors still need to add all lightings to the triggers to render lightprobes]],
            [[   Added Random for lighting and atmosphere]],
            [[   Added Random for the parameters (kinda WIP)]],
            [[   Added blocked levels: Stash_PhinaCamp]],
            [[ BONE ZONE:]],
            [[   Added support for Alternative Tiefling Tails]],
            [[   Added Disable dick physics]],
            [[   Added support for dicks that use 'Genitals' slot for dicks (Vanilla and Knot Your Average Dick)]],
            [[   Fixed tentacle bones (springs are still bugged, don't want to fix rn)]],
            [[ UIIES:]],
            [[   Added tooltips for a lot of buttons and sliders]],
            [[   Selected character automatically selects in Dummies list]],
            [[   Hid bone zone info under a collapsing thingy]],
            [[   Added tips on the main tab]],
            [[   Added Patriot Blue]],
            [[   Added back spaces in tab names]],
            [[   Added ImGui Light]],
            [[   Added ImGui Norbyte]],
            [[   Renamed ImGui Blue to ImGui Dark]],
            [[   Updated ImGui Dark]],
            [[   Fixed conflict with Megan Orange]],
            [[ MAIN:]],
            [[   Removed Grouped controls]],
            [[ SETTINGS:]],
            [[   Added light creation delay. I don't know, I don't like this game. Increase it if have problems with creating lights]],
            [[ FIXIES:]],
            [[   Fixed Toggle all markers not toggling all markers]],
            [[   Fixed saved poses in bone zone not applying correctly]],
            [[   Fixed bone zone pose Overwrite thingy]],
            [[   Fixed stuck Create button]],
            [[   Kinda "better" "error handling" when creating new lights]],
            [[   Temporarily fixed body collisions in Photo mode]],
            [[   Removed stuff I forgor to remove in the version before previous version]],
            [[ OTHER:]],
            [[   A blueprint that you don't need to care about was seprated into a separate pak]],
            [[   Gobos and some other trash garbage were separeted into a separate pak]],
            [[   Load order: Gobos, LightProbes, Blueprint, Lighty Lights]],
            [[   Removed LevelTriggers from LevelTriggers and LightProbes. Now there are only LightPobes due to new AnL changes.
    Might be faster loading time. Not sure.]],
            [[   New password for extra features: JIl9BNlIM]],
        }
    },
    {
        version = '1.9.2',
        Text = {
            [[Rest in peace 1.9.2]],
        }
    },
    {
        version = '1.9.1',
        Text = {
            [[Please read 1.9.0 below]],
            [[Hotifx for bone zone]],
        }
    },
    {
        version = '1.9.0',
        Text = {
            [[DANI:]],
            [[   LOVE YOU MY BB]],
            [[   LOVE YOU MY PAJARINTA]],
            [[   LOVE YOU MY LOVE]],
            [[   LOVE YOU MY LUNA]],
            [[   LOVE YOU MY DANIELA]],
            [[   LOVE YOU MY DANIELA]],
            [[   LOVE YOU MY DANIELA]],
            [[ INFO:]],
            [[   I understand that I don't document a lot, my bad, too lazy x) Most info can be found in the changelogs]],
            [[ BONE ZONE:]],
            [[   Applied bone zone thingy to all available photo mode creatures.
        It means cats, bears, dragons, dogs, etc are now available to be boned
        Might broke something. Let me know.]],
            [[   Added dragonborn facial bones]],
            [[   Added bones for bears (and creatures that have similar skeleton)]],
            [[ PHOTO MODE:]],
            [[   Changed attachments controls]],
            [[   Added new attachments to attachments controls]],
            [[   Added ability to disable dark vision in photo mode (the light from characters' face)]],
            [[   Added new gobo by Aini]],
            [[   "Remove fadeable objects" is now available for SE Release (been available for a month already xd)]],
            [[ UI:]],
            [[   Added changelog]],
            [[   Organizies in settings tabs]],
            [[ FIXES:]],
            [[   Fixed tails]],
            [[   Fixed "Not in photo mode" due to no agreement in BoneZone tab]],
            [[   Fixed an error in the first cinematic cutscene]],
            [[   Fixed some buugs]],
            [[   Fixed typo]],
        }
    },
    {
        version = '1.8.2',
        Text = {
            [[   Fixed an issue with source position]],
        }
    },
    {
        version = '1.8.1',
        Text = {
            [[   Removed hair bones]],
        }
    },
    {
        version = '1.8.0',
        Text = {
            [[   !IMPORTANT!
OLD BONE ZONE POSES WON'T WORK
    To make them work again go to "LocalLarian StudiosBaldur's Gate 3Script ExtenderLightyLightsPoses"
    (you can acces local folder via BG3MM) and sort your poses according to categories in "_POSE_LIST.json".
    For example. In "_POSE_LIST.json" under Lumi category
    I have poses e2 and olive (https://i.ibb.co/7xJccQ6G/Screenshot-3080b660.png).
    I need to create new folder named Lumi where "_POSE_LIST.json" is located (https://i.ibb.co/V0HshQh7/Screenshot-3081b677.png)
    and move "e2.json" and "olive.json" poses in that folder (https://i.ibb.co/BmYQ1j7/Screenshot-3082b9y3.png),
    so the path would be "LocalLarian StudiosBaldur's Gate 3ScriptExtenderLightyLightsPosesLumie2.json" or olive.json]],

            [[   Added export/import pose packs;
    you can export and install paks with poses by double clikcing "e" button. Example pose attached to optional files.
    When you install it below the main mod, you will see new "sdgdfhfghjfgh" category with "fbdbfgbfgb" pose inside]],

            [[   Added ability to save poses as masks;
    same thing, you start with tpose, edit only a certain part or parts (for example you make a fist), then you save it,
    play any pose, and you can apply fist pose as mask to the current pose by double clicking "m" near the fist pose.
    Don't forget that you also should start tails and wings with a tpose (play it with qsat)]],

            [[   Updated attachables;
    you can now select items with keybinds (set them manually in MCM)]],

            [[   Added Unpause/puase for photomode;
    for wind and for playing vfx (means that you can spawn vfx with realm builder and they will play without exiting photomode)]],

            [[   Added Disable SeeThrough;
    disables the circle looking ahh thingy when character behind walls (you need to disable it frequently)]],

            [[   Added Remove fade objects for SE DEVEL ONLY;
    removes roof, floor, and other types of fadeable objects. Heavy thing. Kinda. You can press the button and do your stuff,
    it will finish at some point. To revert back just reload save]],

            [[   Added Export/Import dummy positions;
    only has one slot]],

            [[   Forgot to mention in previous update.
    Dummies auto re-apply their saved positions when you re-enter photomode. Now you can freely leave photomode and comeback]],

            [[   Added toggler for auto re-apply saved dummy positions on photomode re-enter; in Save/Load tree]],

            [[   Added auto disable tail physics;
    in the settings]],

            [[   Removed PhotoMode position source checkbox, it works automatically]],

            [[   Added Megan Orange]],

            [[   Possibly fixed EZ-Manipulator not loading correctly]],

            [[   Possibly fixed bug with Bone Zone gradients]],

            [[   Fixed Not in photomode]],

            [[   Fixed tails not working or something]],

            [[   Fixed directional light size bug]],

            [[   Small performance improvements WOW WTF?!]],

            [[   Hopefully haven't forgor anything else]],
        }
    }
}