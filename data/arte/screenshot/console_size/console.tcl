
osd configure osd_icons -fadeCurrent 0

proc sz {fs c r} \
{
  global consolefontsize
  global consolecolumns
  global consolerows
  set consolefontsize $fs
  set consolecolumns  $c
  set consolerows     $r
}

