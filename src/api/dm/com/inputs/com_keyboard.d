module api.dm.com.inputs.com_keyboard;

/**
 * Authors: initkfs
 */

struct KeyModifier
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
    unknown,              /**< 0 */
    return_,              /**< '\r' */
    escape,               /**< '\x1B' */
    backspace,            /**< '\b' */
    tab,                  /**< '\t' */
    space,                /**< ' ' */
    exclaim,              /**< '!' */
    dblapostrophe,        /**< '"' */
    hash,                 /**< '#' */
    dollar,               /**< '$' */
    percent,              /**< '%' */
    ampersand,            /**< '&' */
    apostrophe,           /**< '\'' */
    leftparen,            /**< '(' */
    rightparen,           /**< ')' */
    asterisk,             /**< '*' */
    plus,                 /**< '+' */
    comma,                /**< ',' */
    minus,                /**< '-' */
    period,               /**< '.' */
    slash,                /**< '/' */
    num0,                 /**< '0' */
    num1,                 /**< '1' */
    num2,                 /**< '2' */
    num3,                 /**< '3' */
    num4,                 /**< '4' */
    num5,                 /**< '5' */
    num6,                 /**< '6' */
    num7,                 /**< '7' */
    num8,                 /**< '8' */
    num9,                 /**< '9' */
    colon,                /**< ':' */
    semicolon,            /**< ';' */
    less,                 /**< '<' */
    equals,               /**< '=' */
    greater,              /**< '>' */
    question,             /**< '?' */
    at,                   /**< '@' */
    leftbracket,          /**< '[' */
    backslash,            /**< '\\' */
    rightbracket,         /**< ']' */
    caret,                /**< '^' */
    underscore,           /**< '_' */
    grave,                /**< '`' */
    a,                    /**< 'a' */
    b,                    /**< 'b' */
    c,                    /**< 'c' */
    d,                    /**< 'd' */
    e,                    /**< 'e' */
    f,                    /**< 'f' */
    g,                    /**< 'g' */
    h,                    /**< 'h' */
    i,                    /**< 'i' */
    j,                    /**< 'j' */
    k,                    /**< 'k' */
    l,                    /**< 'l' */
    m,                    /**< 'm' */
    n,                    /**< 'n' */
    o,                    /**< 'o' */
    p,                    /**< 'p' */
    q,                    /**< 'q' */
    r,                    /**< 'r' */
    s,                    /**< 's' */
    t,                    /**< 't' */
    u,                    /**< 'u' */
    v,                    /**< 'v' */
    w,                    /**< 'w' */
    x,                    /**< 'x' */
    y,                    /**< 'y' */
    z,                    /**< 'z' */
    leftbrace,            /**< '{' */
    pipe,                 /**< '|' */
    rightbrace,           /**< '}' */
    tilde,                /**< '~' */
    delete_,              /**< '\x7F' */
    plusminus,            /**< '\xB1' */
    capslock,              
    f1,                    
    f2,                    
    f3,                    
    f4,                    
    f5,                    
    f6,                    
    f7,                    
    f8,                    
    f9,                    
    f10,                   
    f11,                   
    f12,                   
    printscreen,           
    scrolllock,            
    pause,                 
    insert,                
    home,                  
    pageup,                
    end,                   
    pagedown,              
    right,                 
    left,                  
    down,                  
    up,                    
    numlockclear,          
    kp_divide,             
    kp_multiply,           
    kp_minus,              
    kp_plus,               
    kp_enter,              
    kp_1,                  
    kp_2,                  
    kp_3,                  
    kp_4,                  
    kp_5,                  
    kp_6,                  
    kp_7,                  
    kp_8,                  
    kp_9,                  
    kp_0,                  
    kp_period,             
    application,           
    power,                 
    kp_equals,             
    f13,                   
    f14,                   
    f15,                   
    f16,                   
    f17,                   
    f18,                   
    f19,                   
    f20,                   
    f21,                   
    f22,                   
    f23,                   
    f24,                   
    execute,               
    help,                  
    menu,                  
    select,                
    stop,                  
    again,                 
    undo,                  
    cut,                   
    copy,                  
    paste,                 
    find,                  
    mute,                  
    volumeup,              
    volumedown,            
    kp_comma,              
    kp_equalsas400,        
    alterase,              
    sysreq,                
    cancel,                
    clear,                 
    prior,                 
    return2,               
    separator,             
    out_,                  
    oper,                  
    clearagain,            
    crsel,                 
    exsel,                 
    kp_00,                 
    kp_000,                
    thousandsseparator,    
    decimalseparator,      
    currencyunit,          
    currencysubunit,       
    kp_leftparen,          
    kp_rightparen,         
    kp_leftbrace,          
    kp_rightbrace,         
    kp_tab,                
    kp_backspace,          
    kp_a,                  
    kp_b,                  
    kp_c,                  
    kp_d,                  
    kp_e,                  
    kp_f,                  
    kp_xor,                
    kp_power,              
    kp_percent,            
    kp_less,               
    kp_greater,            
    kp_ampersand,          
    kp_dblampersand,       
    kp_verticalbar,        
    kp_dblverticalbar,     
    kp_colon,              
    kp_hash,               
    kp_space,              
    kp_at,                 
    kp_exclam,             
    kp_memstore,           
    kp_memrecall,          
    kp_memclear,           
    kp_memadd,             
    kp_memsubtract,        
    kp_memmultiply,        
    kp_memdivide,          
    kp_plusminus,          
    kp_clear,              
    kp_clearentry,         
    kp_binary,             
    kp_octal,              
    kp_decimal,            
    kp_hexadecimal,        
    lctrl,                 
    lshift,                
    lalt,                  
    lgui,                  
    rctrl,                 
    rshift,                
    ralt,                  
    rgui,                  
    mode,                  
    sleep,                 
    wake,                  
    channel_increment,     
    channel_decrement,     
    media_play,            
    media_pause,           
    media_record,          
    media_fast_forward,    
    media_rewind,          
    media_next_track,      
    media_previous_track,  
    media_stop,            
    media_eject,           
    media_play_pause,      
    media_select,          
    ac_new,                
    ac_open,               
    ac_close,              
    ac_exit,               
    ac_save,               
    ac_print,              
    ac_properties,         
    ac_search,             
    ac_home,               
    ac_back,               
    ac_forward,            
    ac_stop,               
    ac_refresh,            
    ac_bookmarks,          
    softleft,              
    softright,             
    call,                  
    endcall,               
    left_tab,             /**< Extended key Left Tab */
    level5_shift,         /**< Extended key Level 5 Shift */
    multi_key_compose,    /**< Extended key Multi-key Compose */
    lmeta,                /**< Extended key Left Meta */
    rmeta,                /**< Extended key Right Meta */
    lhyper,               /**< Extended key Left Hyper */
    rhyper,               /**< Extended key Right Hyper */

}
