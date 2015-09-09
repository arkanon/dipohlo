# osd.tcl

# Arkanon <arkanon@lsd.org.br>
# 2015/09/09 (Qua) 02:21:32 BRT
# 2015/08/23 (Dom) 21:46:48 BRS
# 2015/08/22 (Sáb) 19:13:39 BRS
# 2015/08/20 (Qui) 20:26:07 BRT
# 2015/08/19 (Qua) 22:32:46 BRS
# 2015/08/19 (Qua) 01:12:31 BRS



  proc area {widget x y c s f t} \
  {
    if { ! [ osd exists $widget ] } { osd create text $widget }
    osd configure $widget -x $x -y $y -rgba $c -size $s -text $t -font $f -clip 0
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
    if { [ is_cursor_in "keyboard"   ] } { toggle_osd_keyboard; if { [ osd exists kb    ] } { cor "keyboard" $on } { cor "keyboard" $off } }
    if { [ is_cursor_in "menu"       ] } { main_menu_toggle   ; if { [ osd exists menu1 ] } { cor "menu"     $on } { cor "menu"     $off } }
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

    global scale_factor osd_leds_set consolecolumns consolerows consolefontsize consolebackground consolefont on off
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

    set esq [expr {16*$f/3}]
    set top [expr {99*$f/3}]
    set inc [expr {24*$f/3}]
    set tam [expr {22*$f/3}]
    set fnt "skins/data_seventy_std_regular.otf"

    set co1 $off
    set co2 0x00000060

    area "fullscreen" $esq [expr {$top- 1*$inc}] $co1 $tam $fnt "Tela Cheia" ; # F12

    area "power"      $esq [expr {$top+ 0*$inc}] $co1 $tam $fnt "Power"      ; #
    area "caps"       $esq [expr {$top+ 1*$inc}] $co2 $tam $fnt "Caps"       ; # CAPS
    area "code"       $esq [expr {$top+ 2*$inc}] $co2 $tam $fnt "Code"       ; # rALT
    area "led_pause"  $esq [expr {$top+ 3*$inc}] $co2 $tam $fnt "Paused"     ; #
    area "turbo"      $esq [expr {$top+ 4*$inc}] $co2 $tam $fnt "Turbo"      ; #
    area "floppy"     $esq [expr {$top+ 5*$inc}] $co2 $tam $fnt "Disquete"   ; #
    area "pause"      $esq [expr {$top+ 6*$inc}] $co1 $tam $fnt "Pausa"      ; # PAUSE
    area "throttle"   $esq [expr {$top+ 7*$inc}] $co1 $tam $fnt "Trote"      ; # F9
    area "mute"       $esq [expr {$top+ 8*$inc}] $co1 $tam $fnt "Mudo"       ; # F11
    area "breaked"    $esq [expr {$top+ 9*$inc}] $co2 $tam $fnt "Breaked"    ; #

    area "polf"       $esq [expr {$top+10*$inc}] $co1 $tam $fnt "Autopausa"  ; #
    area "console"    $esq [expr {$top+11*$inc}] $co1 $tam $fnt "Console"    ; # F10
    area "keyboard"   $esq [expr {$top+12*$inc}] $co1 $tam $fnt "Teclado"    ; # F6
    area "menu"       $esq [expr {$top+13*$inc}] $co1 $tam $fnt "Menu"       ; # MENU
    area "reset"      $esq [expr {$top+14*$inc}] $co1 $tam $fnt "Reset"      ; #
    area "quit"       $esq [expr {$top+15*$inc}] $co1 $tam $fnt "Sair"       ; # A-F4
    area "x1"         $esq [expr {$top+16*$inc}] $co1 $tam $fnt "x1"         ; #
    area "x2"         $esq [expr {$top+17*$inc}] $co1 $tam $fnt "x2"         ; #
    area "x3"         $esq [expr {$top+18*$inc}] $co1 $tam $fnt "x3"         ; #
    area "ssraw"      $esq [expr {$top+19*$inc}] $co1 $tam $fnt "Tela"       ; # S-PrtScr
    area "ssosd"      $esq [expr {$top+20*$inc}] $co1 $tam $fnt "Tela+OSD"   ; # C-PrtScr
    area "save"       $esq [expr {$top+21*$inc}] $co1 $tam $fnt "Salvar"     ; # A-F8
    area "load"       $esq [expr {$top+22*$inc}] $co1 $tam $fnt "Carregar"   ; # A-F7
    area "record"     $esq [expr {$top+23*$inc}] $co1 $tam $fnt "Gravando"   ; # F4
    # PgUp bwd 1s
    # PgDn fwd 1s

    cor "x1" $off
    cor "x2" $off
    cor "x3" $off

    cor "x$f" $on

  }



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
