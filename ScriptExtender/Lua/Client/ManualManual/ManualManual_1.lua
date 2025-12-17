local CONTENT_SIZE = 'Large'
local CALLOUT_SIZE = 'Large'
local INDENT = 250

Starter_Doc_Contents = {}
Starter_Doc_Contents[1] =
{
    {
        Topic = "The tabs",
		SubTopic = "Main",
        content = {
            { type = "Heading", text = [[Management]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE,  size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Light types", 		text = [[There are three light types to create: Point, Spotlight, Directional.

Point: emits light in all directions.
Spotlight: cone shaped directional light.
Directional: a rectangular shaped directional light.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Create", 			text = [[Creates a new light of the selected type.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Created lights", 	text = [[List of all created lights.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Rename", 			text = [[Renames selected light.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Delete", 			text = [[Deletes selected light.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Delete all", 		text = [[Deletes all lights in the scene and also deletes 'stuck' lights and markers.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Duplicate", 			text = [[Duplicates selected light and its parameters - Alt + C.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "The popup", 			text = [[Shows selected light; useful when the window isn't fully visible - Alt + S.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Toggle light", 		text = [[Toggles selected light - Alt + X.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Toggle all lights", 	text = [[Toggles all lights.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Toggle marker", 		text = [[Toggles marker for selected light.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Toggle all markers", text = [[Toggles markers for all lights.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "MazzleBeam", 		text = [[Kinda shows you light's direction - Alt + A.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Other keybinds", 	text = [[Open/close window - Alt + 4.
Next light - Alt + E.
Previous light - Alt + Q.]] },
        },
    },
    {
        Topic = "The tabs",
		SubTopic = "Main",
        content = {
            { type = "Heading", text = [[Parameters]]},
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Type", 				text = [[Selects the light type to create: point, spotlight, directional.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Color", 				text = [[Light's color.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Power", 				text = [[Light's intensity.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Distance", 			text = [[How far light emits light.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Light channel",	 	text = [[Lets you choose whether the light affects the world, characters, or both.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Scattering",			text = [[Changes light's scattering for volumetric fog.]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[Point]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Sharpening",			text = [[Changes light's edge sharpening.]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[Spotlight]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Inner angle",		text = [[Changes light's inner angle.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[Changes light's outer angle.]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[Directional]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Falloff",			text = [[Changes light's falloff from different sides.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Attenuation",		text = [[Changes light's attenuation: Inverse square, Smooth step, Smoother step.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Width",				text = [[Changes light's width.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Height",				text = [[Changes light's height.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Lenght",				text = [[Changes light's lenght.]] },
		},
	},
    {
        Topic = "The tabs",
		SubTopic = "Main",
        content = {
            { type = "Heading", text = [[Controls]]},
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Save/Load", 			text = [[Saves/loads selected light's position.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Resets", 			text = [[Do reset thing.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Stick to camera", 	text = [[Sticks selected light to camera - Alt + R.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "World relative", 	text = [[Moves light along world axis: North, South, East, West.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Character relative",	text = [[Move light relative to a character or another type of source, in a orbit like way.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Rotation",			text = [[Just rotation, idk. Keep in mind, that you don't ever use Roll for Point and Spotlight, you use it only for Directional. Because rn the mod uses dogshit way of calculating rotation, which causes the gimbal lock.]] },
		},
	},
    {
        Topic = "The tabs",
		SubTopic = "Main",
        content = {
            { type = "Heading", text = [[Position source]] },
			{ type = "Content",  size = CONTENT_SIZE, 		text = [[Defines where a light will be created or moved when using Character relative controls. By default, lights are created at server-sided characters position. You can interpret this as the character's "true" position. But in some cases, it doesn't represent visual character positions, so you have to utilize different types of position sources.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Origin point ", 	text = [[It's a moveable point, that you can create in Origin point tab.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Cutscene ", 		text = [[Uses main character's position in the current cutscene (may have a small offset).]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Client-side ", 	text = [[Uses client-sided character's position.
For example: some animations move characters only visually, while their actual "true" server position stays where the animation started. In such cases, you can use this position source.]] },
		},
	},
	{
        Topic = "The tabs",
		SubTopic = "Main",
        content = {
            { type = "Heading", text = [[Tips]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Origin point", 		text = [[Origin point is goated. Use origin point.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Keybinds", 			text = [[Keybinds are goated. Use keybinds.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Soft hair shadows", 	text = [[The game's lighting system works almost similarly to real life: the larger the light's emission area, the softer the shadows become. You can use this principle to make hair shadows appear softer. However, since this is a game, there are certain quirks we can take advantage of. Increasing the outer angle or moving the light farther away can cause it to illuminate unwanted parts of the character. To avoid this, you can increase the inner angle. This sharpens the edge of the light cone, allowing you to illuminate only the hair, while keeping the rest of the character unaffected.]] },
		},
	},
	{
		Topic = "The tabs",
		SubTopic = "Atmosphere and Lighting",
		content = {
			{ type = "Heading", text = [[Atmosphere and Lighting]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[You can control the entire level's lighting and atmosphere by switching between default Lighting and Atmosphere presets.
These presets affect sun and moon position, atmosphere color, fog parameters, and other related settings.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Reset presets ", text = [[You can always reset level's lighting or atmosphere preset to default by clicking corresponding reset button.]] },
			{ type = "Heading", text = [[Manual parameters control]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[If you want to tune lighting and atmosphere parameters manually, you can do so in the Parameters section.

1. Select any preset as a base.
2. Modify the parameters and apply them.
It is recommended to assign a keybind for applying parameters for faster workflow.
]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Reset parameters ", text = [[Left click resets parameters for the currently selected preset.
Right click resets parameters for all presets.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Preset search issue ", text = [[Sometimes, when searching for a preset, it may appear as the first item in the list but cannot be clicked.
Due to UI limitations, in this case you need to right click on the list to select the first entry.]] },
			{ type = "Heading", text = [[Preset manager]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[You can save your tuned presets using the Preset Manager. Later, you can apply then to any of the vanilla presets.]] },
		},
	},
	{
        Topic = "The tabs",
		SubTopic = "Atmosphere and Lighting",
        content = {
            { type = "Heading", text = [[Tips]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Env effects", 			text = [[You can apply different environmental effects, such as rain, blood rain, ashes, snow blizzard, using EnvironmentalEffect in Atmosphere parameters. You can find all the effects in the toolkit by searchinh EffectResources named "VFX_Environment" or 'VFX_ATM"; or you can find some of them in the mod's articles.

1. Find desired VFX.
2. Copy the name.
3. Paste in one of the EnvironmentalEffect slots.
4. Enable that slot in EnvironmentalEffectEnabled.
]] },
		},
	},
	{
		Topic = "The tabs",
		SubTopic = "Photo Mode",
		content = {
			{ type = "Heading", text = [[Photo Mode]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[The mod provides extended controls for Photo Mode, allowing deeper control over camera and character parameters.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Camera parameters ", text = [[Camera speed, more precise depth of field sliders, and control over near and far camera distances; near distance defines how close the camera can get to a character, and these distances affect the depth buffer.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Camera save/load ", 	text = [[You can save and load the camera position.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Dummy controls", 	text = [[Control dummy position, rotation, and scale.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Manual input ", 		text = [[In the Info section, you can manually enter coordinates and apply them.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Look at direction ", text = [[Controls dummy's look at direction; make sure the corresponding checkbox is enabled in the game's Photo Mode UI.]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Dummy save/load ", 	text = [[Saves and loads dummy's position.]] },
		},
	},
	{
        Topic = "The tabs",
		SubTopic = "Photo Mode",
        content = {
            { type = "Heading", text = [[Tips]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "EasyAlignment", 		text = [[Some modded poses created in Blender are able to be paired very quickly using Lighty Lights tools.

1. Enter photo mode.
2. Select the pose you want for the first character dummy (either in the photo mode dropdown menus or via QSAT).
3. Select the corresponding/paired pose for the second character dummy (this can be repeated as needed for poses made for more than two individuals).
4. Position one character in the final position in which you want them to be.
5. Scroll down and save dummy position. This should now create a clickable entry with the name of the character whose position you have just saved, as well as their coordinates.
6. Scroll back to the list and select the next character you want to match in the pose from the dropdown menu.
7. Return to the clickable entry saved in Step 4 and then click it. This should snap the second character, selected in Step 5, into position and align them correctly with the first character dummy.
8. Done.
]] },
			{ type = "CallOut", prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = [[Opposite "Look at"]], 	text = [[The basic foundation of this is the fact that moving dummies in Lighty Lights does not cause the game to recalculate their head angles, and the functionality of Lighty Lights' dummy movement is, in essence, not recognised by the vanilla tools, so it will continue to think that your dummy is where it was last moved in the "true" photo mode tools (or where it started if you did not move them at all). This can be used to photographers' advantage.

1. Enable Look at for both dummies.
2. Enable "Head doesn't follow the camera".
3. Select first dummy in LL and vanilla UI and have that character look at disired direction.
4. After the first dummy's head is correctly in position, use the "Yaw" to rotate them.
5. Select your second dummy and rotate them as well; when you done, select the dummy in vanilla PM UI, rotate them by 1 unit forth and back using any vanilla slider, you will see that the head updated its position.
6. Done.
]] },
		},
	},
	{
		Topic = "The tabs",
		SubTopic = "Origin point",
		content = {
			{ type = "Heading", text = [[Origin point]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[You can create an origin point to choose it as source of coordinates.
Basic controls, nothing fancy here. The feature is goated, though.]] },
		},
	},
	{
		Topic = "The tabs",
		SubTopic = "Gobo",
		content = {
			{ type = "Heading", text = [[Gobo]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[There are light modifiers called gobo masks; with those, you can shape light to a certain pattern.
Basic controls, nothing fancy here either.]] },
		},
	},
	{
		Topic = "The tabs",
		SubTopic = "Settings",
		content = {
			{ type = "Heading", text = [[Settings]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[Some settings.
Open by default means that a tree will be opened by default when you open LL window.]] },
		},
	},
	{
		Topic = "General tips",
		SubTopic = "XD",
		content = {
			{ type = "Heading", text = [[XD]] },
			{ type = "Content", size = CONTENT_SIZE, 				text = [[For general tips, head down to the CMTY Screenarchery / Virtual Photography wiki page :).]] },
			{ type = "InputText", widget_id = "123", width = 500, 	default = "wiki.bg3.community/en/Screenarchery/Screenarchery-ref" },
		},
	},
}