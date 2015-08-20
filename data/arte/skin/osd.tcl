# osd.tcl

# Arkanon <arkanon@lsd.org.br>
# 2015/08/19 (Qua) 22:32:46 BRS
# 2015/08/19 (Qua) 01:12:31 BRS



  proc area {widget x y c s f t} \
  {
    osd create text $widget -x $x -y $y -rgba $c -size $s -text $t -font $f -clip 0
  }

  proc is_cursor_in {widget} \
  {
    set x 2
    set y 2
    catch {lassign [osd info $widget -mousecoord] x y}
    expr {0 <= $x && $x <= 1 && 0 <= $y && $y <= 1}
  }

  proc check_mouse {} \
  {
    global power pause throttle mute fullscreen console
    if { [ is_cursor_in "power"      ] } { if { $power      } { set power      false } { set power      true } }
    if { [ is_cursor_in "pause"      ] } { if { $pause      } { set pause      false } { set pause      true } }
    if { [ is_cursor_in "throttle"   ] } { if { $throttle   } { set throttle   false } { set throttle   true } }
    if { [ is_cursor_in "mute"       ] } { if { $mute       } { set mute       false } { set mute       true } }
    if { [ is_cursor_in "fullscreen" ] } { if { $fullscreen } { set fullscreen false } { set fullscreen true } }
    if { [ is_cursor_in "console"    ] } { if { $console    } { set console    false } { set console    true } }
    if { [ is_cursor_in "keyboard"   ] } { toggle_osd_keyboard }
    if { [ is_cursor_in "menu"       ] } { main_menu_toggle    }
    if { [ is_cursor_in "reset"      ] } { reset               }
    if { [ is_cursor_in "quit"       ] } { quit                }
    after "mouse button1 down" { check_mouse }
  }



  after time 0 { set power false }

  set esq 16
  set top 97
  set inc 24
  set cor "0x7090aae8 0xa0c0dde8 0x90b0cce8 0xc0e0ffe8"
  set tam 25
  set fnt "skins/data_70_let.ttf"

  area "power"      $esq [expr {$top+ 0*$inc}] $cor $tam $fnt "Power"
  area "caps"       $esq [expr {$top+ 1*$inc}] $cor $tam $fnt "Caps"
  area "code"       $esq [expr {$top+ 2*$inc}] $cor $tam $fnt "Code"
  area "breaked"    $esq [expr {$top+ 3*$inc}] $cor $tam $fnt "Breaked"
  area "turbo"      $esq [expr {$top+ 4*$inc}] $cor $tam $fnt "Turbo"
  area "floppy"     $esq [expr {$top+ 5*$inc}] $cor $tam $fnt "Disquete"
  area "pause"      $esq [expr {$top+ 6*$inc}] $cor $tam $fnt "Pausa"
  area "throttle"   $esq [expr {$top+ 7*$inc}] $cor $tam $fnt "Trote"
  area "mute"       $esq [expr {$top+ 8*$inc}] $cor $tam $fnt "Mudo"
  area "fullscreen" $esq [expr {$top+ 9*$inc}] $cor $tam $fnt "Tela Cheia"
  area "console"    $esq [expr {$top+10*$inc}] $cor $tam $fnt "Console"
  area "keyboard"   $esq [expr {$top+11*$inc}] $cor $tam $fnt "Teclado"
  area "menu"       $esq [expr {$top+12*$inc}] $cor $tam $fnt "Menu"
  area "reset"      $esq [expr {$top+13*$inc}] $cor $tam $fnt "Reset"
  area "quit"       $esq [expr {$top+14*$inc}] $cor $tam $fnt "Sair"

  check_mouse

# F7       select
# F8       stop
# Ins      insert
# lCtrl    control
# rCtrl    deadkey
# lAlt     graph
# rAlt     code
# A-F7     load state
# A-F8     save state
# S-PrtScr ss 2x raw
# C-PrtScr ss scaled+osd

# EOF
