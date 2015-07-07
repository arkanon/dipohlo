#!/bin/bash

# DiPoHLo - Distribuição Portável do HotLogo
#
# Build Script
#
# Arkanon <arkanon@lsd.org.br>
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



  NAME="DiPoHLo - Distribuição Portável do HotLogo"
   MAJ="0.11.0"

   rpm="ftp://rpmfind.net/linux/fedora/linux/development/rawhide"
    sf="http://downloads.sourceforge.net/openmsx"
  pref="openmsx-$MAJ"

  # arquiteturas do emulador
  arq[0]="x86"    ; bin[0]="$rpm/i386/os/Packages/o/$pref-4.fc23.i686.rpm"
  arq[1]="x64"    ; bin[1]="$rpm/x86_64/os/Packages/o/$pref-4.fc23.x86_64.rpm"
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

  export TIMEFORMAT='  ELAPSED TIME: %lR'



  BLD=$(($(tail -n1 build-history 2> /dev/null | cut -f1)+1)) # update build number
  VER="$MAJ-$BLD"

  echo -e "$BLD\t$(LC_TIME=C date +'%Y/%m/%d (%a) %H:%M:%S %Z')" >> build-history

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

        echo ${url##*/}

        time wget -qc $url

        mkdir tmp
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

          echo ${url##*/}

          time wget -qc $url

          mkdir tmp
          (
            cd tmp

            7z e -so ../${url##*/} 2> /dev/null | cpio -idm --quiet
            mv   usr/lib*/* ../../lib-$class

          ) # tmp
          rm -r tmp

        done

      done

    ) # .lib

    ARCH=$(uname -m | grep -q x86_64 && echo x64 || echo x86)

    ln -nfs lib-$ARCH lib

    bpath=$PWD/build/$MAJ/bin
    lpath=$PWD/build/$MAJ/lib

    export            PATH=$PATH:$bpath
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$lpath

    echo "export            PATH=\$PATH:$bpath"
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$lpath"

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

      rm -r icons nettou_yakyuu playball extensions
      rm -r unicodemaps/unicodemap.{??,j*,br_hotbit*,proto_fr}
      rm -r skins/handheld
      rm -r skins/none
      rm -r skins/set?
      rm -r skins/*.png

      # scripts/ - carga de skin e do console
      # Vera     - teclado virtual
      # VeraMono - console

      mv    machines machines-
      mkdir machines
      mv    machines-/{README,Gradiente_Expert_DD_Plus.xml} machines
      rm -r machines-



      (
        cd systemroms
        prefix="http://www.msxarchive.nl/pub/msx/emulator/openMSX/systemroms/machines/gradiente"
        time wget -qc $prefix/expert_ddplus_basic-bios1.rom
        time wget -qc $prefix/expert_ddplus_disk.rom
        sha1sum *.rom
        # d6720845928ee848cfa88a86accb067397685f02  expert_ddplus_basic-bios1.rom
        # f1525de4e0b60a6687156c2a96f8a8b2044b6c56  expert_ddplus_disk.rom
      ) # systemroms



      # roms a serem integradas por default na distribuição
      (
        cd software

        ldir=../../lists
        mkdir -p $ldir



        # <http://www.planetemu.net>
        list="$ldir/planetemu"
# TODO: testar se já há cache e usar ao invés de baixar novamente
        time (
               >| $list.html
               for i in 0 {A..Z}
               do
                 echo -n "$i "
                 curl -s http://www.planetemu.net/roms/msx-various-rom?page=$i >> $list.html
               done
               echo
             ) # 00:05:09.914

        # http://www.planetemu.net/rom/msx-various-rom/zoom-909-1985-sega-1
        # http://www.planetemu.net/php/roms/download.php?id=625735
        # http://www.planetemu.net/php/roms/download.php?token=64969c69469c9202739a94f29dabab30
        cat $list.html | tr -d '\n' \
         | grep -Eo '<a href="/rom/msx-various-rom/[^"]+">[^>]+</a>' \
         | sed -r 's/>[ \t]+/>/g;s/[ \t]+</</g' \
         | cut -d/ -f4- \
         | sed -r 's/">/\t/g;s:</a>::g' \
         | column -s $'\t' -t \
        >| $list.txt

        cat $list.txt | grep -if <(cat << EOT
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
)

        getrom()
        {
          export TIMEFORMAT=' - %lR'
          time \
          (
            local dir=$1
            local rom=$(cat $list.txt | grep -w "$dir"| sed -r 's/ +/\t/' | cut -f2).rom
            echo -n "$rom "
            local  id=$(curl -s http://www.planetemu.net/rom/msx-various-rom/$dir | grep -B1 Télécharger | grep -Eo '[0-9]+')
            echo -n "($id)"
            curl -Ls http://www.planetemu.net/php/roms/download.php -d id=$id | funzip > "$rom"
          )
        }

        while read i; do getrom $i; done << EOT
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

        #   00                                                                                            http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/
        #   01                                                                                            http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/
        #   02                                                                                            http://www.generation-msx.nl/software/gradiente/ligue-se-ao-expert/3409/

        #   03   Antarctic Adventure - European Version (1984)(Konami)[a][RC-701].rom   624520   08.327   http://www.generation-msx.nl/software/konami/antarctic-adventure/25/
        #   04   Arkanoid (1986)(Taito)[a].rom                                          624533   14.470   http://www.generation-msx.nl/software/taito/arkanoid/887/
        #   05   Designer\'s Pencil, The (1984)(Pony Canyon).rom                        624776   06.601   http://www.generation-msx.nl/software/activision/the-designers-pencil/3849/
        #   06   Frogger (1983)(Konami)[a][RC-704].rom                                  624888   08.906   http://www.generation-msx.nl/software/konami/frogger/70/
        #   07   H.E.R.O. (1984)(Pony Canyon)[o].rom                                    624976   22.377   http://www.generation-msx.nl/software/activision/hero/282/
        #   08   Hyper Rally (1985)(Konami)[a][RC-718].rom                              625028   09.905   http://www.generation-msx.nl/software/konami/hyper-rally/580/
        #   09   Iligks Episode I - Theseus (1984)(Ascii)[a].rom                        625043   06.471   http://www.generation-msx.nl/software/ascii/iligks-episode-one---theseus/225/
        #   10   Iligks Episode IV - The Maze of Illegus (1984)(Ascii)[a].rom           625046   06.670   http://www.generation-msx.nl/software/ascii/iligks-episode-iv/99/
        #   11   Lode Runner (1984)(Sony)[a].rom                                        625185   14.687   http://www.generation-msx.nl/software/doug-smith/lode-runner/359/
        #   12   Lode Runner II (1985)(Sony).rom                                        625186   07.627   http://www.generation-msx.nl/software/compile-doug-smith/lode-runner-ii/685/
        #   13   Magical Tree (1984)(Konami)[a][RC-713].rom                             625220   13.768   http://www.generation-msx.nl/software/konami/magical-tree/655/
        #   14   MUE - Music Editor (1984)(Hal).rom                                     625209   06.740   http://www.generation-msx.nl/software/hal-laboratory/music-editor-mue/342/
        #   15   Payload (1985)(Sony)[a].rom                                            625362   07.391   http://www.generation-msx.nl/software/zap/payload/432/
        #   16   River Raid (1984)(Pony Canyon)[a].rom                                  625436   10.836   http://www.generation-msx.nl/software/activision/river-raid/356/
        #   17   Road Fighter (1985)(Konami)[a][RC-730].rom                             625439   21.786   http://www.generation-msx.nl/software/konami/road-fighter/684/
        #   18   Snake It (1986)(Al Alamiah).rom                                        625507   23.795   http://www.generation-msx.nl/software/the-bytebusters/snake-it/960/
        #   19   Super Billiards (1983)(Hal).rom                                        625560   17.765   http://www.generation-msx.nl/software/hal-laboratory/super-billiards/39/

        #   20   MSX-Logo (1985)(Logo Computer Systems)(nl).rom                         625207   07.183   http://www.generation-msx.nl/software/philips/msx-logo/2568/
        #   21   hotlogo-1.2
        #   22   hotlogo



###         # <http://www.doperoms.com>
###         list="$ldir/doperoms"
###         time (
###                >| $list.html
###                for i in $(seq 0 50 650)
###                do
###                  echo -n "$i "
###                  curl -s http://www.doperoms.com/roms/Msx_1/ALL/$i.html >> $list.html
###                done
###                echo
###              ) # 00:01:41.882
###
###         cat $list.html \
###          | grep -Eo 'href="[^"]+.zip.html"' \
###          | cut -d\" -f2 \
###          | cut -d/ -f5,6 \
###          | sed -r 's:/:\t:g;s:.zip.html::g' \
###          | sort -k2 \
###          | uniq \
###         >| $list.txt
###
###         cat $list.txt | grep -if <(cat << EOT
### antarctic adventure
### arkanoid
### frogger
### hero
### hyper rally
### thseus
### illegus
### iligks
### expert
### lode runner
### magical tree
### logo
### music editior
### payload
### river
### road fighter
### snake-it
### super billiards
### pencil
### EOT
### )
###
###         # illegus
###         # expert
###         # logo
###         # pencil
###
###         # 618564  Antarctic Adventure (1984) (Konami) (J)
###         # 618421  Arkanoid 1 (1986) (Taito) (J)
###         # 618651  Frogger (1983) (Konami) (J)
###         # 618388  Hero (1984) (Pony Cannon) (J)
###         # 618398  Hyper Rally (1985) (Konami) (J)
###         # 618526  Lode Runner 1 (1984) (Sony) (J)
###         # 618765  Lode Runner 2 (1984) (Sony) (J)
###         # 618496  Magical Tree (1984) (Konami) (J)
###         # 618211  Music Editior (1984) (Hal) (J)
###         # 618331  Payload (1985) (Sony) (J)
###         # 618322  River Raid (1984) (Pony Cannon) (J)
###         # 618445  Road Fighter (1985) (Konami) (J)
###         # 618679  Snake-It (1986) (Hal) (J)
###         # 618425  Super Billiards (1984) (Hal) (J)
###         # 618217  Thseus (1984) (Ascii) (J)
###
###         # http://www.doperoms.com/files/roms/msx_1/Beam+Rider+%281984%29+%28Pony+Cannon%29+%28J%29.zip/618341/Beam+Rider+.zip



###         # <http://www.msxarchive.nl>
###         repo[ 0]="http://www.msxarchive.nl/pub/msx/emulator/openMSX/systemroms/machines/gradiente"
###         repo[ 1]="http://www.msxarchive.nl/pub/msx/games/msx1"
###         repo[ 2]="http://www.msxarchive.nl/pub/msx/games/roms/msx1"
###         repo[ 3]="http://www.msxarchive.nl/pub/msx/mep-mirror/Games"
###         repo[ 4]="http://www.msxarchive.nl/pub/msx/mep-mirror/BIOS%20ROMs"
###         repo[ 5]="http://www.msxarchive.nl/pub/msx/misc"
###         repo[ 6]="http://www.msxpro.com/download"
###
###         file[ 0]="-                        0 expert_ddplus_basic-bios1 rom" # http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/
###         file[ 1]="-                        0 expert_ddplus_disk        rom" # http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/
###         file[ 2]="-                        0 expert_plus_demo          rom" #
###         file[ 2]="ligue_se_ao_expert       4 liguese                   zip" # http://www.generation-msx.nl/software/gradiente/ligue-se-ao-expert/3409/
###
###         file[ 3]="antartic_adventure       2 antartic                  lzh" # http://www.generation-msx.nl/software/konami/antarctic-adventure/25/
###         file[ 4]="arkanoid                 2 arkanoid                  zip" # http://www.generation-msx.nl/software/taito/arkanoid/887/
###         file[ 5]="frogger                  2 frogger                   zip" # http://www.generation-msx.nl/software/konami/frogger/70/
###         file[ 6]="hero                     1 hero                      lzh" # http://www.generation-msx.nl/software/activision/hero/282/
###         file[ 7]="hyper_rally              2 hrally                    zip" # http://www.generation-msx.nl/software/konami/hyper-rally/580/
###         file[ 8]="iligks_episode_1_theseus 3 theseus                   zip" # http://www.generation-msx.nl/software/ascii/iligks-episode-one---theseus/225/
###         file[ 9]="iligks_episode_4_illegus 3 ILLEGUS                   ZIP" # http://www.generation-msx.nl/software/ascii/iligks-episode-iv/99/
###         file[10]="lode_runner              2 loderun                   lzh" # http://www.generation-msx.nl/software/doug-smith/lode-runner/359/
###         file[11]="lode_runner_ii           1 loderun2                  lzh" # http://www.generation-msx.nl/software/compile-doug-smith/lode-runner-ii/685/
###         file[12]="magical_tree             2 mtree                     lzh" # http://www.generation-msx.nl/software/konami/magical-tree/655/
###         file[13]="mue_music_editor         3 MUE                       ZIP" # http://www.generation-msx.nl/software/hal-laboratory/music-editor-mue/342/
###         file[14]="pay_load                 2 payload                   lzh" # http://www.generation-msx.nl/software/zap/payload/432/
###         file[15]="river_raid               1 rivraid                   lzh" # http://www.generation-msx.nl/software/activision/river-raid/356/
###         file[16]="road_fighter             2 road                      lzh" # http://www.generation-msx.nl/software/konami/road-fighter/684/
###         file[17]="snake_it                 2 snakeit                   lzh" # http://www.generation-msx.nl/software/the-bytebusters/snake-it/960/
###         file[18]="super_billiards          2 billiard                  lzh" # http://www.generation-msx.nl/software/hal-laboratory/super-billiards/39/
###         file[19]="the_designers_pencil     3 pencil                    zip" # http://www.generation-msx.nl/software/activision/the-designers-pencil/3849/
###
###         file[20]="msx_logo                 5 msx-logo                  rom" # http://www.generation-msx.nl/software/philips/msx-logo/2568/
###         file[21]="hotlogo-1.2              6 rumsx                     zip"
###         file[22]="hotlogo"
###
###         time wget -qc $repo/$file
###         sha1sum *.rom
###         # d6720845928ee848cfa88a86accb067397685f02  expert_ddplus_basic-bios1.rom
###         # f1525de4e0b60a6687156c2a96f8a8b2044b6c56  expert_ddplus_disk.rom



      ) # software

    ) # share

  ) # MAJ

exit #-- AQUI --#

  mv    share/skins/fancy  share/skins/set1
  cp -a ../data/*.xml      share
  cp -a ../data/software/* share/software
  cp -a ../data/frame.png  share/skins/set1
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

  # diff -u ../../.share/scripts/load_icons.tcl load_icons.tcl >| ../../../data/load_icons.tcl.patch
  patch -p1 share/scripts/load_icons.tcl < ../data/load_icons.tcl.patch

# PARAMETROS="-script openmsx.tcl -machine Gradiente_Expert_DDPlus -cart share/software/hotlogo.rom -diska disk"
#
# OPENMSX_SYSTEM_DATA=share
# LD_LIBRARY_PATH=lib OPENMSX_USER_DATA=share ./openmsx-bin $PARAMETROS
#
# wine openmsx-bin.exe $PARAMETROS

# EOF
