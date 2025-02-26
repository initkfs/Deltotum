module api.dm.com.inputs.com_keyboard;

/**
 * Authors: initkfs
 */
import api.dm.com.platforms.results.com_result : ComResult;
import api.dm.com.graphics.com_window: ComWindow;

interface ComKeyboard
{
@trusted nothrow:

    ComResult getKeyModifier(out ComKeyModifier mod);
    ComKeyModifier keyModifier() @trusted nothrow;
}

struct ComKeyModifier
{
    bool isLeftShift;
    bool isRightShift;

    bool isLeftCtrl;
    bool isRightCtrl;

    bool isLeftAlt;
    bool isRightAlt;

    bool isLeftGui;
    bool isRightGui;

    bool isNum;
    bool isCaps;
    bool isAltGr;
    bool isScrollLock;

    bool isCtrl()
    {
        return isLeftCtrl || isRightCtrl;
    }

    bool isAlt()
    {
        return isLeftAlt || isRightAlt;
    }

    bool isShift()
    {
        return isLeftShift || isRightShift;
    }
}

// dfmt off
enum ComKeyName : int
{
    key_unknown,              /**< 0 */
    key_return,               /**< '\r' */
    key_escape,               /**< '\x1B' */
    key_backspace,            /**< '\b' */
    key_tab,                  /**< '\t' */
    key_space,                /**< ' ' */
    key_exclaim,              /**< '!' */
    key_dblapostrophe,        /**< '"' */
    key_hash,                 /**< '#' */
    key_dollar,               /**< '$' */
    key_percent,              /**< '%' */
    key_ampersand,            /**< '&' */
    key_apostrophe,           /**< '\'' */
    key_leftparen,            /**< '(' */
    key_rightparen,           /**< ')' */
    key_asterisk,             /**< '*' */
    key_plus,                 /**< '+' */
    key_comma,                /**< ',' */
    key_minus,                /**< '-' */
    key_period,               /**< '.' */
    key_slash,                /**< '/' */
    key_0,                    /**< '0' */
    key_1,                    /**< '1' */
    key_2,                    /**< '2' */
    key_3,                    /**< '3' */
    key_4,                    /**< '4' */
    key_5,                    /**< '5' */
    key_6,                    /**< '6' */
    key_7,                    /**< '7' */
    key_8,                    /**< '8' */
    key_9,                    /**< '9' */
    key_colon,                /**< ':' */
    key_semicolon,            /**< ';' */
    key_less,                 /**< '<' */
    key_equals,               /**< '=' */
    key_greater,              /**< '>' */
    key_question,             /**< '?' */
    key_at,                   /**< '@' */
    key_leftbracket,          /**< '[' */
    key_backslash,            /**< '\\' */
    key_rightbracket,         /**< ']' */
    key_caret,                /**< '^' */
    key_underscore,           /**< '_' */
    key_grave,                /**< '`' */
    key_a,                    /**< 'a' */
    key_b,                    /**< 'b' */
    key_c,                    /**< 'c' */
    key_d,                    /**< 'd' */
    key_e,                    /**< 'e' */
    key_f,                    /**< 'f' */
    key_g,                    /**< 'g' */
    key_h,                    /**< 'h' */
    key_i,                    /**< 'i' */
    key_j,                    /**< 'j' */
    key_k,                    /**< 'k' */
    key_l,                    /**< 'l' */
    key_m,                    /**< 'm' */
    key_n,                    /**< 'n' */
    key_o,                    /**< 'o' */
    key_p,                    /**< 'p' */
    key_q,                    /**< 'q' */
    key_r,                    /**< 'r' */
    key_s,                    /**< 's' */
    key_t,                    /**< 't' */
    key_u,                    /**< 'u' */
    key_v,                    /**< 'v' */
    key_w,                    /**< 'w' */
    key_x,                    /**< 'x' */
    key_y,                    /**< 'y' */
    key_z,                    /**< 'z' */
    key_leftbrace,            /**< '{' */
    key_pipe,                 /**< '|' */
    key_rightbrace,           /**< '}' */
    key_tilde,                /**< '~' */
    key_delete,               /**< '\x7F' */
    key_plusminus,            /**< '\xB1' */
    key_capslock,              
    key_f1,                    
    key_f2,                    
    key_f3,                    
    key_f4,                    
    key_f5,                    
    key_f6,                    
    key_f7,                    
    key_f8,                    
    key_f9,                    
    key_f10,                   
    key_f11,                   
    key_f12,                   
    key_printscreen,           
    key_scrolllock,            
    key_pause,                 
    key_insert,                
    key_home,                  
    key_pageup,                
    key_end,                   
    key_pagedown,              
    key_right,                 
    key_left,                  
    key_down,                  
    key_up,                    
    key_numlockclear,          
    key_kp_divide,             
    key_kp_multiply,           
    key_kp_minus,              
    key_kp_plus,               
    key_kp_enter,              
    key_kp_1,                  
    key_kp_2,                  
    key_kp_3,                  
    key_kp_4,                  
    key_kp_5,                  
    key_kp_6,                  
    key_kp_7,                  
    key_kp_8,                  
    key_kp_9,                  
    key_kp_0,                  
    key_kp_period,             
    key_application,           
    key_power,                 
    key_kp_equals,             
    key_f13,                   
    key_f14,                   
    key_f15,                   
    key_f16,                   
    key_f17,                   
    key_f18,                   
    key_f19,                   
    key_f20,                   
    key_f21,                   
    key_f22,                   
    key_f23,                   
    key_f24,                   
    key_execute,               
    key_help,                  
    key_menu,                  
    key_select,                
    key_stop,                  
    key_again,                 
    key_undo,                  
    key_cut,                   
    key_copy,                  
    key_paste,                 
    key_find,                  
    key_mute,                  
    key_volumeup,              
    key_volumedown,            
    key_kp_comma,              
    key_kp_equalsas400,        
    key_alterase,              
    key_sysreq,                
    key_cancel,                
    key_clear,                 
    key_prior,                 
    key_return2,               
    key_separator,             
    key_out,                   
    key_oper,                  
    key_clearagain,            
    key_crsel,                 
    key_exsel,                 
    key_kp_00,                 
    key_kp_000,                
    key_thousandsseparator,    
    key_decimalseparator,      
    key_currencyunit,          
    key_currencysubunit,       
    key_kp_leftparen,          
    key_kp_rightparen,         
    key_kp_leftbrace,          
    key_kp_rightbrace,         
    key_kp_tab,                
    key_kp_backspace,          
    key_kp_a,                  
    key_kp_b,                  
    key_kp_c,                  
    key_kp_d,                  
    key_kp_e,                  
    key_kp_f,                  
    key_kp_xor,                
    key_kp_power,              
    key_kp_percent,            
    key_kp_less,               
    key_kp_greater,            
    key_kp_ampersand,          
    key_kp_dblampersand,       
    key_kp_verticalbar,        
    key_kp_dblverticalbar,     
    key_kp_colon,              
    key_kp_hash,               
    key_kp_space,              
    key_kp_at,                 
    key_kp_exclam,             
    key_kp_memstore,           
    key_kp_memrecall,          
    key_kp_memclear,           
    key_kp_memadd,             
    key_kp_memsubtract,        
    key_kp_memmultiply,        
    key_kp_memdivide,          
    key_kp_plusminus,          
    key_kp_clear,              
    key_kp_clearentry,         
    key_kp_binary,             
    key_kp_octal,              
    key_kp_decimal,            
    key_kp_hexadecimal,        
    key_lctrl,                 
    key_lshift,                
    key_lalt,                  
    key_lgui,                  
    key_rctrl,                 
    key_rshift,                
    key_ralt,                  
    key_rgui,                  
    key_mode,                  
    key_sleep,                 
    key_wake,                  
    key_channel_increment,     
    key_channel_decrement,     
    key_media_play,            
    key_media_pause,           
    key_media_record,          
    key_media_fast_forward,    
    key_media_rewind,          
    key_media_next_track,      
    key_media_previous_track,  
    key_media_stop,            
    key_media_eject,           
    key_media_play_pause,      
    key_media_select,          
    key_ac_new,                
    key_ac_open,               
    key_ac_close,              
    key_ac_exit,               
    key_ac_save,               
    key_ac_print,              
    key_ac_properties,         
    key_ac_search,             
    key_ac_home,               
    key_ac_back,               
    key_ac_forward,            
    key_ac_stop,               
    key_ac_refresh,            
    key_ac_bookmarks,          
    key_softleft,              
    key_softright,             
    key_call,                  
    key_endcall,               
    key_left_tab,             /**< Extended key Left Tab */
    key_level5_shift,         /**< Extended key Level 5 Shift */
    key_multi_key_compose,    /**< Extended key Multi-key Compose */
    key_lmeta,                /**< Extended key Left Meta */
    key_rmeta,                /**< Extended key Right Meta */
    key_lhyper,               /**< Extended key Left Hyper */
    key_rhyper,               /**< Extended key Right Hyper */





}
