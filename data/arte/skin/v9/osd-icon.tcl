# osd.tcl

# Arkanon <arkanon@lsd.org.br>
# 2015/09/11 (Sex) 01:56:15 BRS
# 2015/09/09 (Qua) 23:05:49 BRS
# 2015/09/09 (Qua) 02:21:32 BRT
# 2015/08/23 (Dom) 21:46:48 BRS
# 2015/08/22 (Sáb) 19:13:39 BRS
# 2015/08/20 (Qui) 20:26:07 BRT
# 2015/08/19 (Qua) 22:32:46 BRS
# 2015/08/19 (Qua) 01:12:31 BRS



  proc area {widget row col stat tip} \
  {
    global esq top inc skin_set_dir
    if { ! [ osd exists $widget ] } { osd create rectangle $widget }
    if { $stat == "" } { set image $widget } { set image "$widget-$stat" }
    osd configure $widget -scale 1 -image [try_dirs $skin_set_dir $image ""]
    if { $row  != "" } { osd configure $widget -x [expr {$esq+$col*$inc}] -y [expr {$top+$row*$inc}] }
  }

  proc cor {widget c} \
  {
  # osd configure $widget -rgba $c
  }

  proc cursor_in {widget} \
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

    global power pause throttle mute pause_on_lost_focus console ; # fullscreen on off recording

    if { [ cursor_in power      ] } {                       set power               [ expr { ! $power               } ] ; area power     "" "" $power               "" }
    if { [ cursor_in reset      ] } { reset }
    if { [ cursor_in quit       ] } { quit  }

    if { [ cursor_in pause      ] } {                       set pause               [ expr { ! $pause               } ] ; area pause     "" "" $pause               "" }
    if { [ cursor_in throttle   ] } {                       set throttle            [ expr { ! $throttle            } ] ; area throttle  "" "" $throttle            "" }
    if { [ cursor_in mute       ] } {                       set mute                [ expr { ! $mute                } ] ; area mute      "" "" $mute                "" }

    if { [ cursor_in autopause  ] } {                       set pause_on_lost_focus [ expr { ! $pause_on_lost_focus } ] ; area autopause "" "" $pause_on_lost_focus "" }

    if { [ cursor_in console    ] } {                       set console             [ expr { ! $console             } ] ; area console   "" "" $console             "" }
    if { [ cursor_in keyboard   ] } { toggle_osd_keyboard ; set keyboard            [ osd exists kb                   ] ; area keyboard  "" "" $keyboard            "" }
    if { [ cursor_in menu       ] } { main_menu_toggle    ; set menu                [ osd exists menu1                ] ; area menu      "" "" $menu                "" }

  # if { [ cursor_in x1         ] } { escala 1 }
  # if { [ cursor_in x2         ] } { escala 2 }
  # if { [ cursor_in x3         ] } { escala 3 }
  # if { [ cursor_in fullscreen ] } { if { $fullscreen } { set fullscreen false ; cor "fullscreen" $off } { set fullscreen true ; cor "fullscreen" $on ; escala 3 } }

  # if { [ cursor_in ssraw      ] } { screenshot -raw -doublesize }
  # if { [ cursor_in ssosd      ] } { screenshot -with-osd }
  # if { [ cursor_in save       ] } { savestate }
  # if { [ cursor_in load       ] } { loadstate }
  # if { [ cursor_in record     ] } { if { $recording } { set recording false ; cor "record" $off ; record stop } { set recording true ; cor "record" $on ; record start -doublesize -stereo } }

    after "mouse button1 down" { check_mouse }

  }

  proc escala {f} \
  {

    global power pause throttle mute pause_on_lost_focus console
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

    area power      0 0 $power               "Power"     ; #
    area reset      0 1 ""                   "Reset"     ; #
    area quit       0 2 ""                   "Sair"      ; # A-F4

    area pause      1 0 $pause               "Pausa"     ; # PAUSE
    area throttle   1 1 $throttle            "Trote"     ; # F9
    area mute       1 2 $mute                "Mudo"      ; # F11

    area autopause  2 0 $pause_on_lost_focus "Autopausa" ; #

    area console   10 0 false                "Console"   ; # F10
    area keyboard  10 1 0                    "Teclado"   ; # F6
    area menu      10 2 0                    "Menu"      ; # MENU

  # area x1         0 0 "" "x1"         ; #
  # area x2         0 0 "" "x2"         ; #
  # area x3         0 0 "" "x3"         ; #
  # area fullscreen 0 0 "" "Tela Cheia" ; # F12

  # area save       0 0 "" "Salvar"     ; # A-F8
  # area load       0 0 "" "Carregar"   ; # A-F7
  # area ssraw      0 0 "" "Tela"       ; # S-PrtScr
  # area ssosd      0 0 "" "Tela+OSD"   ; # C-PrtScr
  # area record     0 0 "" "Gravando"   ; # F4

  # area caps       0 0 "" "Caps"       ; # CAPS
  # area code       0 0 "" "Code"       ; # rALT
  # area led_pause  0 0 "" "Paused"     ; #
  # area turbo      0 0 "" "Turbo"      ; #
  # area floppy     0 0 "" "Disquete"   ; #
  # area breaked    0 0 "" "Breaked"    ; #

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

  set throttle true ; # valor inicial e nomes dos ícones invertido. BUG na implementação do throttle?

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
