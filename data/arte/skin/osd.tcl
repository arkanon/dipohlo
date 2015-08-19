# osd.tcl

# Arkanon <arkanon@lsd.org.br>
# 2015/08/19 (Qua) 01:12:31 BRS

after time 0 { set power false }

proc is_cursor_in {widget} \
{
  set x 2
  set y 2
  catch {lassign [osd info $widget -mousecoord] x y}
  expr {0 <= $x && $x <= 1 && 0 <= $y && $y <= 1}
}

proc area {widget x y w h} \
{
  osd create rectangle $widget -x $x -y $y -w $w -h $h -rgba 0x00000050
  osd configure        $widget -x $x -y $y -w $w -h $h
}

activate_input_layer leds -blocking

area "power"    16  98 54 19
area "reset"    16 122 54 19
area "keyboard" 16 146 54 19
area "console"  16 170 54 19
area "pause"    16 242 54 19
area "throttle" 16 266 68 19
area "mute"     16 290 45 19

bind -layer leds "mouse button1 down" \
{
  if { [ is_cursor_in "power"    ] } { if { $power    } { set power    false } { set power    true } }
  if { [ is_cursor_in "reset"    ] } { reset }
  if { [ is_cursor_in "pause"    ] } { if { $pause    } { set pause    false } { set pause    true } }
  if { [ is_cursor_in "keyboard" ] } { toggle_osd_keyboard }
# if { [ is_cursor_in "keyboard" ] } { if { [osd exists kb] } { disable_osd_keyboard } { enable_osd_keyboard } }
  if { [ is_cursor_in "console"  ] } { if { $console  } { set console  false } { set console  true } }
  if { [ is_cursor_in "throttle" ] } { if { $throttle } { set throttle false } { set throttle true } }
  if { [ is_cursor_in "mute"     ] } { if { $mute     } { set mute     false } { set mute     true } }
}

# EOF
