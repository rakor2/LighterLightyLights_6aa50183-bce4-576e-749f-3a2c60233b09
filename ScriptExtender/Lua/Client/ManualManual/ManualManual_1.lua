


local CONTENT_SIZE = 'Large'
local CALLOUT_SIZE = 'Large'
local INDENT = 200

Starter_Doc_Contents = {}
Starter_Doc_Contents[1] =
{
    {
        Topic = "xd",
		SubTopic = "Introduction",
        content = {
            { type = "Heading", text = [[Overview]] },
			{ type = "Content",  text_block_indent = INDENT, text = [[Lighty Lights is a mod that allows to manipulate light however you want. It allows you to create light sources, switch between different Lighting and Atmosphere preset - change their different parameters. The mod also offers different controls over Photo Mode options: character position, rotation, scale; some camera parameters. 
]] },
		},
	},
    {
        Topic = "The tabs",
		SubTopic = "Main tab",
        content = {
            { type = "Heading", text = [[Management]] },
			{ type = "Content", size = CONTENT_SIZE, text = [[Sadwkdnmln]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE, size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Light types", 		text = [[There are three light types to create: Point, Spotlight, Directional

Point: emits light in all directions
Spotlight: cone shaped directional light
Directional: a rectangular shaped directional light ]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Create", 			text = [[creates a new light of the selected type]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Created lights", 	text = [[list of all created lights]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Rename", 			text = [[renames selected light]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Delete", 			text = [[deletes selected light ]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Delete all", 		text = [[deletes all lights in the scene and also deletes 'stuck' lights and markers]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Duplicate", 		text = [[duplicates selected light and its parameters]] },
        },
    },
    {
        Topic = "The tabs",
		SubTopic = "Main tab",
        content = {
            { type = "Heading", text = [[Parameters]]},
			{ type = "Content", size = CONTENT_SIZE, text = [[General]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Type", 				text = [[selects the light type to create: point, spotlight, directional]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Color", 			text = [[light's color]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Power", 			text = [[light's intensity]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Distance", 			text = [[how far light emits light]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Light channel", 	text = [[lets you choose whether the light affects the world, characters, or both]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Scattering",		text = [[changes light's scattering for volumetric fog]] },

			{ type = "Content", size = CONTENT_SIZE, text = [[Point]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Sharpening",		text = [[changes light's edge sharpening]] },

			{ type = "Content", size = CONTENT_SIZE, text = [[Spotlight]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Inner angle",		text = [[changes light's inner angle]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[changes light's outer angle]] },

			{ type = "Content", size = CONTENT_SIZE, text = [[Directional]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Falloff",			text = [[changes light's falloff from different sides]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Attenuation",		text = [[changes light's attenuation: Inverse square, Smooth step, Smoother step]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[changes light's outer angle]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[changes light's outer angle]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[changes light's outer angle]] },
			{ type = "CallOut",  prefix_size = CALLOUT_SIZE ,size = CONTENT_SIZE, text_block_indent = INDENT, prefix = "Outer angle",		text = [[changes light's outer angle]] },
		},	                                                              
	},
    {
        Topic = "The tabs",
		SubTopic = "Main tab",
        content = {
            { type = "Heading", text = [[Character's position source]], },
			{ type = "Content", text = [[Defines where a light will be created. By default lights are created at server-sided characters position. You can interpret this as the character's "true" position]], },
			{ type = "CallOut", prefix = "Origin Point ", text = [[uses Origin point, that you can create in Origin tab. You can imagine it as a ]] },
			{ type = "CallOut", prefix = "Cutscene ", text = [[uses main character's position in the current cutscene (may have a small offset)]] },
			{ type = "CallOut", prefix = "Client-side ", text = [[uses client-sided character's position. For example: some animations move characters only visually, while their actual "true" server position stays where the animation started. In such cases you can use this option]] },
		},
	},
    {
		Topic = "Welcome",
		SubTopic = "Widget Types",
		content = {
			{ type = "Heading", text = "Widget Types" },
			{ type = "Content", text = "The following 12 widget types are available for use in documentation slides:" },
			{ type = "Heading", text = "1. Heading - Large, prominent title text" },
			{ type = "SubHeading", text = "2. SubHeading - Medium-sized subtitle text" },
			{ type = "Section", text = "3. Section - Small section header text" },
			{ type = "Content", text = "4. Content - Standard paragraph text" },
			{ type = "Note", text = "5. Note - Highlighted note or tip text" },
			{ type = "Bullet", text = "6. Bullet point" },
			{ type = "CallOut", prefix = "7. CallOut", text = "Indented block of text with a colored prefix label" },
			{ type = "Code", text = "8. Code - Monospaced code snippet text" },
			{ type = "CallOut", prefix = "9. Separator", text_block_indent = 200, prefix_color = "TextMain", text = "Horizontal line separator" },
			{ type = "CallOut", prefix = "10. DynamicButton",  text_block_indent = 200, prefix_color = "TextMain", text = "Interactive button (e.g., open MCM)" },
			{ type = "CallOut", prefix = "11. Image", text_block_indent = 200, prefix_color = "TextMain", text = "Display an image" },
			{ type = "Separator" },
			{ type = "Content", text = {
				"Remember that most of these widgets can also take an array of text, like this!",
				"This is a really useful feature that you should use liberally.",
			}},
			{ type = "CallOut", prefix = "Note:", text = {
				"See the MazzleDocs documentation for more information about creating these widgets.",
				"Ctrl-D will open MazzleDoc's documentation browser.",
			}},
		}
	},
}

