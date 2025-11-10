Starter_Doc_Config = Starter_Doc_Config or {}
function initMazzleColors()
    theme_override = {
        background             = Style.Colors.windowBg,
        title_bg               = Style.Colors.titleBg,
        title_bg_active        = Style.Colors.titleBgActive,
        title_bg_collapsed     = Style.Colors.titleBgCollapsed,
        text                   = Style.Colors.textColor,
        border                 = Style.Colors.border,
        border_shadow          = Style.Colors.borderShadow,
        
        nav_button_hovered     = Style.Colors.buttonHovered,
        nav_button_active      = Style.Colors.buttonActive,
        nav_area_bg            = Style.Colors.childBg,
        content_area_bg        = Style.Colors.childBg,
        nav_topic_text         = Style.Colors.textColor,
        nav_subtopic_text      = Style.Colors.textColor,
        nav_slide_text         = Style.Colors.textColor,
        nav_button_text        = Style.Colors.textColor,
        nav_header_text        = Style.Colors.textColor,
        slide_index_text       = Style.Colors.textDisabled,
        
        scrollbar_bg           = Style.Colors.scrollbarBg,
        scrollbar_grab         = Style.Colors.scrollbarGrab,
        scrollbar_grab_hovered = Style.Colors.scrollbarGrabHovered,
        scrollbar_grab_active  = Style.Colors.scrollbarGrabActive,
        
        content_text           = Style.Colors.textColor,
        heading_text           = Style.Colors.textColor,
        subheading_text        = Style.Colors.textColor,
        section_text           = Style.Colors.textColor,
        note_text              = Style.Colors.textDisabled,
        callout_text           = Style.Colors.textColor,
        callout_prefix         = Style.Colors.textColor,
        code_text              = Style.Colors.textColor,
        code_bg                = Style.Colors.childBg,
        bullet_text            = Style.Colors.textColor,
        separator_color        = Style.Colors.separator,
        keyword_text           = Style.Colors.textColor,
        highlight_text         = Style.Colors.textColor,
        warning_text           = {1.00, 0.64, 0.64, 1.00},
        action_color           = {0.60, 0.85, 0.60, 1.00},
        bonus_action_color     = {0.60, 0.60, 0.85, 1.00},
        
        input_text             = Style.Colors.textColor,
        input_bg               = Style.Colors.frameBg,
        input_bg_hover         = Style.Colors.frameBgHovered,
        input_bg_active        = Style.Colors.frameBgActive,
        slider_grab            = Style.Colors.sliderGrab,
        slider_grab_active     = Style.Colors.sliderGrabActive,
        checkbox_bg            = Style.Colors.frameBg,
        checkbox_bg_hover      = Style.Colors.frameBgHovered,
        checkbox_bg_active     = Style.Colors.frameBgActive,
        checkbox_check         = Style.Colors.checkMark,
        
        button_bg              = Style.Colors.button,
        button_text            = Style.Colors.textColor,
        button_hover           = Style.Colors.buttonHovered,
        button_active          = Style.Colors.buttonActive,
        progress_bar           = Style.Colors.resizeGripActive,
        progress_bar_bg        = Style.Colors.frameBg
    }
    Starter_Doc_Config.theme_override = theme_override
    return theme_override
end

Starter_Doc_Config = {
    mod_name = 'LL2',
    documentation_name = 'Lighty Lights Elucidator',
    window_title = 'Lighty Lights Elucidator',
    type = 'documentation',
    window_width = 1400,
    window_height = 980,
    ToC_Starts_Hidden = false,
    theme_override = initMazzleColors()
}

