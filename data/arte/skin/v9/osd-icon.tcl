# osd.tcl

# Arkanon <arkanon@lsd.org.br>
# 2015/09/09 (Qua) 23:05:49 BRS
# 2015/09/09 (Qua) 02:21:32 BRT
# 2015/08/23 (Dom) 21:46:48 BRS
# 2015/08/22 (Sáb) 19:13:39 BRS
# 2015/08/20 (Qui) 20:26:07 BRT
# 2015/08/19 (Qua) 22:32:46 BRS
# 2015/08/19 (Qua) 01:12:31 BRS



  proc area {widget row col ion ioff l} \
  {

    global esq top inc skin_set_dir

    if { ! [ osd exists $widget ] } \
    {
      osd create rectangle $widget
      if { $ion  != "" } { osd create rectangle $widget.on  }
      if { $ioff != "" } { osd create rectangle $widget.off }
    }

    if { [ osd exists $widget.on  ] } { osd configure $widget.on  -x [expr {$esq+0.5+$col*$inc}] -y [expr {$top+0.5+$row*$inc}] -scale 1 -image [try_dirs $skin_set_dir $ion  ""] }
    if { [ osd exists $widget.off ] } { osd configure $widget.off -x [expr {$esq+0.0+$col*$inc}] -y [expr {$top+0.0+$row*$inc}] -scale 1 -image [try_dirs $skin_set_dir $ioff ""] }

  }

  proc cor {widget c} \
  {
    osd configure $widget -rgba $c
  }

  proc is_cursor_in {widget} \
  {
    set x 2
    set y 2
    catch {lassign [osd info $widget -mousecoord] x y}
    expr {0 <= $x && $x <= 1 && 0 <= $y && $y <= 1}
  }

  proc try_dirs {skin_set_dir file fallback} \
  {

    set file "$file.png"
    if {[file normalize $file] eq $file} {return $file}        ; # don't touch already resolved pathnames

    set f [file normalize $skin_set_dir/$file                ] ; # first look in specified skin-set directory
    if {[file isfile $f]} {return $f}

    set f [file normalize $skin_set_dir/icons/$file          ] ; #
    if {[file isfile $f]} {return $f}

    set f [file normalize $skin_set_dir/$fallback            ] ; # look for the falback image in the skin directory
    if {[file isfile $f]} {return $f}

    set f [file normalize $skin_set_dir/icons/$fallback      ] ; #
    if {[file isfile $f]} {return $f}

    set f [file normalize [data_file "skins/$file"          ]] ; # if it's not there look in the root skin directory (system or user directory)
    if {[file isfile $f]} {return $f}

    set f [file normalize [data_file "skins/icons/$file"    ]] ; #
    if {[file isfile $f]} {return $f}

    set f [file normalize [data_file "skins/$fallback"      ]] ; # still not found, look for the fallback image in system and user root skin dir
    if {[file isfile $f]} {return $f}

    set f [file normalize [data_file "skins/icons/$fallback"]] ; #
    if {[file isfile $f]} {return $f}

    return ""

  }

  proc sz {fs c r} \
  {
    global consolefontsize
    global consolecolumns
    global consolerows
    set consolefontsize $fs
    set consolecolumns  $c
    set consolerows     $r
  }

  proc check_mouse {} \
  {

    global power pause throttle mute fullscreen console pause_on_lost_focus on off recording

    if { [ is_cursor_in "fullscreen" ] } { if { $fullscreen          } { set fullscreen          false ; cor "fullscreen" $off } { set fullscreen          true ; cor "fullscreen" $on ; escala 3 } }

    if { [ is_cursor_in "power"      ] } { if { $power               } { set power               false ; cor "power"      $off } { set power               true ; cor "power"      $on  } }
    if { [ is_cursor_in "pause"      ] } { if { $pause               } { set pause               false ; cor "pause"      $off } { set pause               true ; cor "pause"      $on  } }
    if { [ is_cursor_in "throttle"   ] } { if { $throttle            } { set throttle            false ; cor "throttle"   $on  } { set throttle            true ; cor "throttle"   $off } }
    if { [ is_cursor_in "mute"       ] } { if { $mute                } { set mute                false ; cor "mute"       $off } { set mute                true ; cor "mute"       $on  } }

    if { [ is_cursor_in "polf"       ] } { if { $pause_on_lost_focus } { set pause_on_lost_focus false ; cor "polf"       $off } { set pause_on_lost_focus true ; cor "polf"       $on  } }
    if { [ is_cursor_in "console"    ] } { if { $console             } { set console             false ; cor "console"    $off } { set console             true ; cor "console"    $on  } }
    if { [ is_cursor_in "keyboard"   ] } { toggle_osd_keyboard ; if { [ osd exists kb    ] } { cor "keyboard" $on } { cor "keyboard" $off } }
    if { [ is_cursor_in "menu"       ] } { main_menu_toggle    ; if { [ osd exists menu1 ] } { cor "menu"     $on } { cor "menu"     $off } }
    if { [ is_cursor_in "reset"      ] } { reset }
    if { [ is_cursor_in "quit"       ] } { quit  }
    if { [ is_cursor_in "x1"         ] } { escala 1 }
    if { [ is_cursor_in "x2"         ] } { escala 2 }
    if { [ is_cursor_in "x3"         ] } { escala 3 }
    if { [ is_cursor_in "ssraw"      ] } { screenshot -raw -doublesize }
    if { [ is_cursor_in "ssosd"      ] } { screenshot -with-osd }
    if { [ is_cursor_in "save"       ] } { savestate }
    if { [ is_cursor_in "load"       ] } { loadstate }
    if { [ is_cursor_in "record"     ] } { if { $recording } { set recording false ; cor "record" $off ; record stop } { set recording true ; cor "record" $on ; record start -doublesize -stereo } }

    after "mouse button1 down" { check_mouse }

  }

  proc escala {f} \
  {

    global esq top inc skin_set_dir scale_factor osd_leds_set consolecolumns consolerows consolefontsize consolebackground consolefont on off
    set scale_factor      $f
    set fw                [ expr { (320*$f)+1 } ]
    set fh                [ expr { (240*$f)+1 } ]
  # set cw                [ expr { round(893*$f/3)+1 } ]
  # set ch                [ expr { round(280*$f/3)+1 } ]
    set frame             "$::env(OPENMSX_SYSTEM_DATA)/skins/$osd_leds_set/frame-${f}x-${fw}x${fh}.png"

    osd configure osd_frame -z 0 -x 0 -y 0 -w [expr {$fw-1}] -h [expr {$fh-1}] -scaled false -image $frame

    set cbgs [ list { list "300x89" 59  8  9 } { list "593x183" 84 13 12 } { list "894x281" 127 20 12 } ]
    set sizes             [ lindex $cbgs [expr {$f-1}] ]
    set cbgsize           [ lindex $sizes 1 ]
    set consolecolumns    [ lindex $sizes 2 ]
    set consolerows       [ lindex $sizes 3 ]
    set consolefontsize   [ lindex $sizes 4 ]
    set consolebackground "skins/$osd_leds_set/console-${f}x-${cbgsize}.png"
  # set consolefont       "skins/powerline_consolas.ttf"

    set esq [expr {10*$f/3}]
    set top [expr {70*$f/3}]
    set inc [expr {30*$f/3}]

    area "power"      0 0 "powered_on"    "powered_off"    "Power"      ; #
    area "reset"      0 1 "reset"         ""               "Reset"      ; #
    area "quit"       0 2 "quit"          ""               "Sair"       ; # A-F4

  # area "polf"       0 0 "autopaused_on" "autopaused_off" "Autopausa"  ; #
    area "pause"      1 0 "paused_on"     "paused_off"     "Pausa"      ; # PAUSE
    area "throttle"   1 1 "throttle_on"   "throttle_off"   "Trote"      ; # F9
    area "mute"       1 2 "volume_mute"   ""               "Mudo"       ; # F11

  # area "save"       0 0 "powered_on"    "Salvar"     ; # A-F8
  # area "load"       0 0 "powered_on"    "Carregar"   ; # A-F7
  # area "ssraw"      0 0 "powered_on"    "Tela"       ; # S-PrtScr
  # area "ssosd"      0 0 "powered_on"    "Tela+OSD"   ; # C-PrtScr
  # area "record"     0 0 "powered_on"    "Gravando"   ; # F4

  # area "x1"         0 0 "powered_on"    "x1"         ; #
  # area "x2"         0 0 "powered_on"    "x2"         ; #
  # area "x3"         0 0 "powered_on"    "x3"         ; #
  # area "fullscreen" 0 0 "powered-on"    "Tela Cheia" ; # F12

  # area "caps"       0 0 "powered_on"    "Caps"       ; # CAPS
  # area "code"       0 0 "powered_on"    "Code"       ; # rALT
  # area "led_pause"  0 0 "powered_on"    "Paused"     ; #
  # area "turbo"      0 0 "powered_on"    "Turbo"      ; #
  # area "floppy"     0 0 "powered_on"    "Disquete"   ; #
  # area "breaked"    0 0 "powered_on"    "Breaked"    ; #

  # area "console"    0 0 "powered_on"    "Console"    ; # F10
  # area "keyboard"   0 0 "powered_on"    "Teclado"    ; # F6
  # area "menu"       0 0 "powered_on"    "Menu"       ; # MENU

    # PgUp bwd 1s
    # PgDn fwd 1s

  }


  set esq 0
  set top 0
  set inc 0

  set skin_set_dir [data_file "skins/dipohlo"]

  set on  0x7090aae8
  set off 0x7090aa40
  set recording false

  after time 0 { set power false }

  escala 3
  check_mouse

# F7       select
# F8       stop
# lCTRL    control
# rCTRL    deadkey
# lALT     graph
# rALT     code
#
# INS      insert
# CAPS     caps
# SHIFT    shift
# TAB      tab
# ESC      esc

# EOF
