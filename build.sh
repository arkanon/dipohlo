#!/bin/bash

# DiPoHLo - Distribuição Portável do HotLogo
#
# Build Script
#
# Arkanon <arkanon@lsd.org.br>
# 2015/09/08 (Ter) 21:49:15 BRS
# 2015/08/23 (Dom) 20:26:24 BRS
# 2015/08/22 (Sáb) 19:28:40 BRS
# 2015/08/20 (Qui) 20:27:37 BRS
# 2015/08/19 (Qua) 21:44:41 BRS
# 2015/08/16 (Dom) 15:45:28 BRT
# 2015/08/14 (Sex) 11:47:16 BRS
# 2015/08/11 (Ter) 03:09:10 BRS
# 2015/08/09 (Dom) 17:45:56 BRS
# 2015/08/08 (Sáb) 21:14:02 BRT
# 2015/08/03 (Seg) 02:18:10 BRS
# 2015/07/28 (Ter) 01:46:00 BRS
# 2015/07/21 (Ter) 14:03:24 BRS
# 2015/07/21 (Ter) 01:58:10 BRS
# 2015/07/19 (Dom) 20:15:11 BRS
# 2015/07/13 (Seg) 01:20:52 BRS
# 2015/07/12 (Dom) 17:12:34 BRS
# 2015/07/07 (Ter) 01:15:30 BRS
# 2015/07/06 (Seg) 10:50:12 BRS
# 2015/07/05 (Dom) 09:57:48 BRS
# 2015/07/05 (Dom) 05:26:19 BRS
# 2015/07/04 (Sáb) 03:41:25 BRS
# 2015/07/03 (Sex) 09:13:11 BRS
# 2015/07/03 (Sex) 02:35:49 BRS
# 2015/07/02 (Qui) 00:12:35 BRS
# 2015/07/01 (Qua) 00:53:04 BRT
# 2014/03/07 (Fri) 00:52:56 BRS
# 2014/03/05 (Wed) 22:21:10 BRS
# 2013/04/15 (Seg) 05:49:49 BRS
#
#
# TODO
#   ok lista de teclas especiais do emulador na borda do frame
#   ok clip de ruído branco de tv (comando power do console)
#   -- led para teclas de pressão (shift, graph, code, control)
#   -- clip de contagem regressiva
#   -- implementar parâmetros do make
#
#
# BUGS
#   -- throttle iniciando com led ligado
#   -- roms identificadas pelo id tornam-se desconhecidas se repositório muda o id
#
#
# Emuladores
#   <http://openmsx.org/>
#   <http://fms.komkon.org/fMSX/>
#   <http://www.bluemsx.com/>
#
#
# Informações
#
#   Generation MSX
#     <http://www.generation-msx.nl/hardware/>
#     <http://www.generation-msx.nl/software/>
#
#
# ROMs
#
#   Planet Emulation
#     <http://www.planetemu.net/machine/msx-1-2>
#     <http://www.planetemu.net/roms/msx-bios>
#     <http://www.planetemu.net/roms/msx-various-rom>
#
#   MSX Archive
#     <http://www.msxarchive.nl/pub/msx/>
#
#   MSX Pro
#     <http://www.msxpro.com/aplicativos.html>
#
#   DopeROMs
#     <http://www.doperoms.com/roms/Msx_1/ALL.html>
#
#
# Fontes TrueType
#
#   <http://www.fontpalace.com/font-download/Data+70+LET/>
#   <http://kldp.net/projects/baekmuk/download>
#
#
# Uso
#
#   ( time ./build.sh ) 2>&1 | tee build-out
#
#   ---
#
### file="git.img" ; mount | grep "$file" ; loop=$(losetup -j "$file" | cut -d: -f1) ; sudo blockdev --setrw $loop ; sudo mount -o remount,rw $loop ; mount | grep "$file"



  REPO="$HOME/git/dipohlo"
  DATA="$REPO/data"
 SKINV="9"

  NAME="DiPoHLo - Distribuição Portável do HotLogo"
   MAJ="0.11.0"

  # <ftp://rpmfind.net/linux/fedora/linux/development/rawhide/x86_64/os/Packages/s/>
   rpm="http://rpmfind.net/linux/fedora/linux/development/rawhide"
    sf="http://downloads.sourceforge.net/openmsx"
  pref="openmsx-$MAJ"

  last() { lynx -dump -nonumbers -listonly "$1/?C=M;O=A" | grep -i $2 | tail -n1; }

  # arquiteturas do emulador
  arq[0]="x86"    ; bin[0]=$(last $rpm/i386/os/Packages/o   openmsx) # $pref-4.fc23.i686.rpm
  arq[1]="x64"    ; bin[1]=$(last $rpm/x86_64/os/Packages/o openmsx) # $pref-4.fc23.x86_64.rpm
  arq[2]="w86"    ; bin[2]="$sf/$pref-windows-vc-x86-bin.zip"
  arq[3]="w64"    ; bin[3]="$sf/$pref-windows-vc-x64-bin.zip"
  arq[4]="m86_64" ; bin[4]="$sf/$pref-mac-x86_64-bin.dmg"

  typeset -A cls # classes de arquitetura
  cls[x86]="i386"
  cls[x64]="x86_64"

  # dependencias
  lib[0]="l/libstdc++-5.1.1-4.fc23"
  lib[1]="l/libao-1.2.0-5.fc23"
  lib[2]="l/libpng-1.6.17-2.fc23"
  lib[3]="l/libGLEW-1.10.0-6.fc23"
  lib[4]="s/SDL_ttf-2.0.11-7.fc23"
# lib[5]="s/SDL-1.2.15-18.fc23"

# rpm -qlp $rpmfile

  export TIMEFORMAT=' - %lR'



  cd $REPO



   BLD=$(($(tail -n1 build-history 2> /dev/null | cut -f1)+1)) # update build number
   VER="$MAJ-$BLD"
  BLDD=$(LC_TIME=C date +'%Y/%m/%d (%a) %H:%M:%S %Z')

  echo -e "$BLD\t$BLDD" >> build-history



  planetemu()
  # rotina finalizada
  # <http://www.planetemu.net>
  {

    local repo ldir list pref i

    repo=$FUNCNAME
    ldir=$1
    list="$ldir/$repo"
    pref="http://www.$repo.net"

    mkdir -p $ldir
    mkdir -p $repo

    [ ! -e $list.html ] && time \
    (

      echo -n "BIOS "
      curl -s "$pref/roms/msx-bios" >| $list.html

      echo -n "EXPERT "
      curl -s "$pref/?section=recherche&recherche=msx+expert&rubrique=roms" >> $list.html

      for i in 0 {A..Z}
      do
        echo -n "$i "
        curl -s "$pref/roms/msx-various-rom?page=$i" >> $list.html
      done

    ) # 00:05:09.914

    # <http://www.planetemu.net/roms/msx-various-rom?page=Z>
    # <http://www.planetemu.net/rom/msx-various-rom/zoom-909-1985-sega-1>
    # <http://www.planetemu.net/php/roms/download.php?id=625735>
    # <http://www.planetemu.net/php/roms/download.php?token=64969c69469c9202739a94f29dabab30>
    cat $list.html | tr -d '\n' \
     | grep -Eo '<a href="/(\?section=roms|rom/msx-(bios|various-rom)/)[^"]+">[^>]+</a>' \
     | sed -r 's/>[ \t]+/>/g;s/[ \t]+</</g' \
     | cut -d/ -f2- \
     | sed -r 's/">/\t/g;s:</a>::g;s/amp;//g' \
    >| $list.txt

    # listagem com os padrões das roms desejadas, para identificação e escolha manual da string correta da url
    cat $list.txt | grep -if <(cat << EOT
expert 1.
expert dd
antarctic adventure
arkanoid
frogger
h.e.r.o
hyper rally
theseus
illegus
lode runner
magical tree
logo
music editor
payload
river raid
road fighter
snake-it
super billiards
pencil
EOT
) | column -s $'\t' -t

    getrom()
    {
      local key=$1
      local dir=$(cat $list.txt | grep -w "$key" | cut -f1)
      local rom=$(cat $list.txt | grep -w "$key" | cut -f2).rom
      echo -n "$rom "
      local  id=$(curl -s "$pref/$dir" | grep -B1 Télécharger | grep -Eo '[0-9]+')
      echo -n "($id)"
      curl -C- -Ls "$pref/php/roms/download.php" -d id=$id | funzip 2> /dev/null >| "$repo/$rom"
    } # getrom

    # utilização da string da url para download da rom correspondente
    while read i; do time getrom $i; done << EOT
2423883
2423888
antarctic-adventure-european-version-1984-konami-a-rc-701
arkanoid-1986-taito-a
designer-s-pencil-the-1984-pony-canyon
frogger-1983-konami-a-rc-704
h-e-r-o-1984-pony-canyon-o
hyper-rally-1985-konami-a-rc-718
iligks-episode-i-theseus-1984-ascii-a
iligks-episode-iv-the-maze-of-illegus-1984-ascii-a
lode-runner-1984-sony-a
lode-runner-ii-1985-sony
magical-tree-1984-konami-a-rc-713
msx-logo-1985-logo-computer-systems-nl
mue-music-editor-1984-hal
payload-1985-sony-a
river-raid-1984-pony-canyon-a
road-fighter-1985-konami-a-rc-730
snake-it-1986-al-alamiah
super-billiards-1983-hal
EOT

    #   00   Expert 1.3 (Brazil) (MSX1).rom                                        2258920            <http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/>
    #   01   Expert DDPlus (Brazil) (MSX1).rom                                     2258925            <http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/>

    #   02   Antarctic Adventure - European Version (1984)(Konami)[a][RC-701].rom   624520   08.327   <http://www.generation-msx.nl/software/konami/antarctic-adventure/25/>
    #   03   Arkanoid (1986)(Taito)[a].rom                                          624533   14.470   <http://www.generation-msx.nl/software/taito/arkanoid/887/>
    #   04   Designer\'s Pencil, The (1984)(Pony Canyon).rom                        624776   06.601   <http://www.generation-msx.nl/software/activision/the-designers-pencil/3849/>
    #   05   Frogger (1983)(Konami)[a][RC-704].rom                                  624888   08.906   <http://www.generation-msx.nl/software/konami/frogger/70/>
    #   06   H.E.R.O. (1984)(Pony Canyon)[o].rom                                    624976   22.377   <http://www.generation-msx.nl/software/activision/hero/282/>
    #   07   Hyper Rally (1985)(Konami)[a][RC-718].rom                              625028   09.905   <http://www.generation-msx.nl/software/konami/hyper-rally/580/>
    #   08   Iligks Episode I - Theseus (1984)(Ascii)[a].rom                        625043   06.471   <http://www.generation-msx.nl/software/ascii/iligks-episode-one---theseus/225/>
    #   09   Iligks Episode IV - The Maze of Illegus (1984)(Ascii)[a].rom           625046   06.670   <http://www.generation-msx.nl/software/ascii/iligks-episode-iv/99/>
    #   10   Lode Runner (1984)(Sony)[a].rom                                        625185   14.687   <http://www.generation-msx.nl/software/doug-smith/lode-runner/359/>
    #   11   Lode Runner II (1985)(Sony).rom                                        625186   07.627   <http://www.generation-msx.nl/software/compile-doug-smith/lode-runner-ii/685/>
    #   12   Magical Tree (1984)(Konami)[a][RC-713].rom                             625220   13.768   <http://www.generation-msx.nl/software/konami/magical-tree/655/>
    #   13   MUE - Music Editor (1984)(Hal).rom                                     625209   06.740   <http://www.generation-msx.nl/software/hal-laboratory/music-editor-mue/342/>
    #   14   Payload (1985)(Sony)[a].rom                                            625362   07.391   <http://www.generation-msx.nl/software/zap/payload/432/>
    #   15   River Raid (1984)(Pony Canyon)[a].rom                                  625436   10.836   <http://www.generation-msx.nl/software/activision/river-raid/356/>
    #   16   Road Fighter (1985)(Konami)[a][RC-730].rom                             625439   21.786   <http://www.generation-msx.nl/software/konami/road-fighter/684/>
    #   17   Snake It (1986)(Al Alamiah).rom                                        625507   23.795   <http://www.generation-msx.nl/software/the-bytebusters/snake-it/960/>
    #   18   Super Billiards (1983)(Hal).rom                                        625560   17.765   <http://www.generation-msx.nl/software/hal-laboratory/super-billiards/39/>
    #   19   MSX-Logo (1985)(Logo Computer Systems)(nl).rom                         625207   07.183   <http://www.generation-msx.nl/software/philips/msx-logo/2568/>

    #   20   hotlogo-1.2                                                                              <http://www.msxpro.com/aplicativos.html>
    #   21   ligue_se_ao_expert                                                                       <http://www.generation-msx.nl/software/gradiente/ligue-se-ao-expert/3409/>

    #   22   hotlogo                                                                                  <http://www.generation-msx.nl/software/philips/msx-logo/2568/>

  } # planetemu



  mkdir -p build/$MAJ
  (
    cd build/$MAJ



    touch v$MAJ

    for i in bin share
    do
      rm    -rf $i
      mkdir -p  $i
    done



    mkdir -p .bin
    (
      cd .bin

      for i in $(seq ${#bin[*]})
      do

           n=$((i-1))
         url=${bin[$n]}
        arch=${arq[$n]}

        echo -n ${url##*/}
        time wget -qc $url

        mkdir -p tmp
        (
          cd tmp

          case $arch in

            x*) 7z e -so ../${url##*/} 2> /dev/null | cpio -idm --quiet
                rm                            usr/share/openmsx/settings.xml
                mv   etc/openmsx/settings.xml usr/share/openmsx
                mv   usr/bin/openmsx          ../../bin/$pref-$arch
                mv   usr/share/openmsx/       ../../share/$arch/
                ;;

            w*) 7z x ../${url##*/} &> /dev/null
                mv   codec/      share/
                mv   openmsx.exe ../../bin/$pref-$arch.exe
                mv   share/      ../../share/$arch/
                ;;

            m*) 7z x ../${url##*/} &> /dev/null
                7z x 4.hfs         &> /dev/null
                mv   openMSX/openMSX.app/ ../../bin/$pref-$arch.app
                ;;

          esac

        ) # tmp
        rm -r tmp

      done

    ) # .bin



    # ldd bin/openmsx-0.11.0-4.fc23.i686 | grep 'not found'
    # # usr/bin/openmsx: /usr/lib/i386-linux-gnu/libstdc++.so.6: version GLIBCXX_3.4.21 not found (required by usr/bin/openmsx)
    #
    # strings /usr/lib/i386-linux-gnu/libstdc++.so.6 | grep GLIBC
    # # GLIBCXX_3.4.20
    #
    # dpkg -S libstdc++.so.6
    # apt-file -l search libstdc++.so.6
    #
    # strings lib-i386/libstdc++.so.6 | grep GLIBC
    # # GLIBCXX_3.4.21



    mkdir -p .lib
    (
      cd .lib

      for class in x86 x64
      do

        arch=${cls[$class]}

        mkdir -p ../lib-$class

        for i in $(seq ${#lib[*]})
        do

            n=$((i-1))
          url="$rpm/$arch/os/Packages/${lib[$n]}.${arch/3/6}.rpm"

          echo -n ${url##*/}
          time wget -qc $url

          mkdir -p tmp
          (
            cd tmp

            7z e -so ../${url##*/} 2> /dev/null | cpio -idm --quiet
            mv   usr/lib*/* ../../lib-$class

          ) # tmp
          rm -r tmp

        done

      done

    ) # .lib



    mkdir -p .rom
    (
      cd .rom

      planetemu  ../.list
    # msxarchive          # código em more.sh
    # doperoms   ../.list # código em more.sh

      mkdir -p msxarchive
      (
        cd msxarchive
        mkdir -p tmp
        (
          cd tmp
          site="http://www.msxarchive.nl/pub/msx/mep-mirror/BIOS%20ROMs"
          file="liguese.zip"
          wget -qc $site/$file
          7z e -y $file *.{ROM,rom} &> /dev/null
          mv LIGUE-SE.ROM ../ligue_se_ao_expert.rom
        ) # tmp
        rm -r tmp
      ) # msxarchive

      mkdir -p msxpro
      (
        cd msxpro
        mkdir -p tmp
        (
          cd tmp
          site="http://www.msxpro.com/download"
          file="rumsx.zip"
          wget -qc $site/$file
          7z e -y $file */*/*.{ROM,rom} &> /dev/null
          mv Msx1BrAb.ROM ../hotbit-1.1-abnt.rom
          mv Logo_Br.rom  ../hotlogo-1.2.rom
        ) # tmp
        rm -r tmp
      ) # msxpro

    ) # .rom



    (
      cd share

      diff -qr x64 x86 && ( rm -r x86; mv x64 x )
      diff -qr w64 w86 && ( rm -r w86; mv w64 w )

      diff -qr w   x
      cp   -a  x/* w
      diff -qr w   x
      rm   -r      x

      diff -qr w                                      ../bin/$pref-m86_64.app/share/
      cp   -a  w/codec/                               ../bin/$pref-m86_64.app/share/
      cp   -a  w/icons/openmsx.ico                    ../bin/$pref-m86_64.app/share/icons/
      cp   -a  w/machines/{msx{1,2,2plus},turbor}.xml ../bin/$pref-m86_64.app/share/machines/
      diff -qr w                                      ../bin/$pref-m86_64.app/share/
      mv       w/* .
      rmdir    w

      rm     icons/openMSX-logo-{1,3,4,6}*
      rm -r  nettou_yakyuu playball extensions
      rm -r  unicodemaps/unicodemap.{??,j*,br_hotbit*,proto_fr}

      # scripts/ - carga de skin e do console

      # [ -e $OPENMSX_SYSTEM_DATA/scripts/load_icons.tcl.orig ] || cp -a $OPENMSX_SYSTEM_DATA/scripts/load_icons.tcl $OPENMSX_SYSTEM_DATA/scripts/load_icons.tcl.orig
      # diff -u $OPENMSX_SYSTEM_DATA/scripts/load_icons.tcl.orig $OPENMSX_SYSTEM_DATA/scripts/load_icons.tcl >| $DATA/load_icons.tcl.patch
      patch -p1 scripts/load_icons.tcl < $DATA/load_icons.tcl.patch

      rm     machines/*.xml

      ln -fs unicodemap.br_gradiente_1_1        unicodemaps/unicodemap.br_gradiente_1_3
      cp -a  $DATA/Gradiente_Expert_DD_Plus.xml machines/
      cp -a  $DATA/settings.xml                 .
      cp -a  $DATA/softwaredb.xml               .

      (
        cd skins

        ls -1d * | grep -v Vera | xargs rm -r
        # ficam as fontes:
        #   Vera     - teclado virtual
        #   VeraMono - console

        mkdir -p                                              dipohlo/
        cp    -a  $DATA/skin.tcl                              dipohlo/
        cp    -a  $DATA/arte/skin/v$SKINV/console-894x281.png dipohlo/console.png
        cp    -a  $DATA/arte/skin/v$SKINV/frame-961x721.png   dipohlo/frame.png
        cp    -a  $DATA/arte/skin/led-blue-off.png            led-off.png
        cp    -a  $DATA/arte/skin/led-blue-on.png             led-on.png
        cp    -a  $DATA/arte/ttf/data_seventy_std_regular.otf .
      # ln    -fs led-on.png                                  mute.png
      # ln    -fs led-on.png                                  pause.png
      # ln    -fs led-on.png                                  breaked.png
      # ln    -fs led-on.png                                  throttle.png

      ) # skins



      (
        cd systemroms

        echo "

              expert_ddplus_basic-bios1 : planetemu : Expert 1.3 (Brazil) (MSX1)
              expert_ddplus_disk        : planetemu : Expert DDPlus (Brazil) (MSX1)

             " \
        | sed -r 's/(^ +| +: +)/\t/g' \
        | while read short repo long
          do
            if [ "$short" ]
            then
              long="../../.rom/$repo/$long.rom"
              covr="$DATA/software/$short.jpg"
              [ -e "$long" ] && cp -a "$long" "$short.rom" || echo "ROM  de $short ignorado"
              [ -e "$covr" ] && cp -a "$covr" .            || echo "Capa de $short ignorado"
            fi
          done
          # Capa de expert_ddplus_basic-bios1 ignorado
          # Capa de expert_ddplus_disk ignorado

      ) # systemroms



      (
        cd software

        echo "

              antarct  : planetemu  : Antarctic Adventure - European Version (1984)(Konami)[a][RC-701]
              arkanoid : planetemu  : Arkanoid (1986)(Taito)[a]
              pencil   : planetemu  : Designer's Pencil, The (1984)(Pony Canyon)
              frogger  : planetemu  : Frogger (1983)(Konami)[a][RC-704]
              hero     : planetemu  : H.E.R.O. (1984)(Pony Canyon)[o]
              hyprally : planetemu  : Hyper Rally (1985)(Konami)[a][RC-718]
              theseus  : planetemu  : Iligks Episode I - Theseus (1984)(Ascii)[a]
              illegus  : planetemu  : Iligks Episode IV - The Maze of Illegus (1984)(Ascii)[a]
              lrunner  : planetemu  : Lode Runner (1984)(Sony)[a]
              lrunner2 : planetemu  : Lode Runner II (1985)(Sony)
              mtree    : planetemu  : Magical Tree (1984)(Konami)[a][RC-713]
              mue      : planetemu  : MUE - Music Editor (1984)(Hal)
              payload  : planetemu  : Payload (1985)(Sony)[a]
              rivraid  : planetemu  : River Raid (1984)(Pony Canyon)[a]
              road     : planetemu  : Road Fighter (1985)(Konami)[a][RC-730]
              snakeit  : planetemu  : Snake It (1986)(Al Alamiah)
              billiard : planetemu  : Super Billiards (1983)(Hal)
              msxlogo  : planetemu  : MSX-Logo (1985)(Logo Computer Systems)(nl)

              hotlogo2 : msxpro     : hotlogo-1.2
              liguese  : msxarchive : ligue_se_ao_expert

             " \
        | sed -r 's/(^ +| +: +)/\t/g' \
        | while read short repo long
          do
            if [ "$short" ]
            then
              long="../../.rom/$repo/$long.rom"
              capa="$DATA/software/$short-capa.jpg"
              tela="$DATA/software/$short-tela.png"
              [ -e "$long" ] && cp -a "$long" "$short.rom" || echo "ROM  de $short ignorada"
              [ -e "$capa" ] && cp -a "$capa" .            || echo "Capa de $short ignorada"
              [ -e "$tela" ] && cp -a "$tela" .            || echo "Tela de $short ignorada"
            fi
          done
          # Capa de pencil ignorado
          # Capa de hotlogo2 ignorado

        dump="$DATA/misc/logodump/original"
        capa="$DATA/software/hotlogo-capa.jpg"
        tela="$DATA/software/hotlogo-tela.png"
        echo -en $(printf '\\x%02x' $(cat "$dump"/* | tr '\r' '\n' | sed '{/^\. /!d;s/^\. //;s/ /\n/g}')) >| hotlogo.rom
        cp -a "$capa" .
        cp -a "$tela" .

      ) # software



    ) # share



    ARCH=$(uname -m | grep -q x86_64 && echo x64 || echo x86)

    ln -fs  $pref-$ARCH bin/openmsx
    ln -nfs   lib-$ARCH lib

    cat << EOT | tee build-runtest
# vim: ft=sh

# $BLDD

  ARCH=\$(uname -m | grep -q x86_64 && echo x64 || echo x86)
   MAJ="$MAJ"
 SKINV="$SKINV"
  pref="openmsx-\$MAJ"

  REPO="\$PWD"
  DATA="\$REPO/data"
   BLD="\$REPO/build/\$MAJ"

  ln -fs  \$pref-\$ARCH \$BLD/bin/openmsx
  ln -nfs   lib-\$ARCH \$BLD/lib

  export                PATH=\$PATH:\$BLD/bin
  export     LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$BLD/lib

  export OPENMSX_SYSTEM_DATA=\$REPO/build/\$MAJ/share
  export   OPENMSX_USER_DATA=\$OPENMSX_SYSTEM_DATA

# openmsx -cart \$OPENMSX_USER_DATA/software/hotlogo.rom -diska \$DATA/disk/ -script \$DATA/arte/skin/v\$SKINV/osd.tcl -script <( echo 'after time 14 { type "arquivos\r"; after time 2 { type "carregue \"" } }' ) &

# EOF
EOT



  ) # MAJ



exit



  cp -a ../data/pixel.png  share/skins
  cp -a ../data/disk       .
  cp -a ../data/misc       .
  cp -a ../data/openmsx*   .

  mod=../data/cygwin
  ori=/export/data/soft/cygwin/cygwin
  dst=/export/home/arkanon/public_html/svl.lsd.org.br/appsweb/svl/.h/msx/emu/distro/$version/cygwin
  mkdir -p $dst
  (
    cd $mod
    find . -type f | while read f
    do
      ( cd $ori ; cp -a --parents $f $dst 2> /dev/null ) || ( cd $ori/fs ; cp -a --parents $f $dst )
    # ( cd $ori ; grep -aq '^!<symlink>' $ori/$f && cp -a $(grep -aEo '[^/].*$' $ori/$f) $dst/$(echo $f | cut -d/ -f2-) )
    done
  )
  cp -a ../data/profile cygwin/etc



# PARAMETROS="-script openmsx.tcl -machine Gradiente_Expert_DDPlus -cart share/software/hotlogo.rom -diska disk"
#
# LD_LIBRARY_PATH=lib OPENMSX_USER_DATA=share ./openmsx-bin $PARAMETROS
#
# wine openmsx-bin.exe $PARAMETROS



# EOF
