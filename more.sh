#!/bin/bash



  msxarchive()
  # rotina finalizada apenas para arquivos compactados contendo apenas um arquivo (a rom)
  # <http://www.msxarchive.nl>
  {

    local vers ldir list pref repo file url rom

    vers=$FUNCNAME
    vers=msxarchive
  # ldir=$1
  # list="$ldir/$vers"
    pref="http://www.$vers.nl/pub/msx"

  # mkdir -p $ldir
    mkdir -p $vers

    repo[ 0]="$pref/emulator/openMSX/systemroms/machines/gradiente"
    repo[ 1]="$pref/games/msx1"
    repo[ 2]="$pref/games/roms/msx1"
    repo[ 3]="$pref/mep-mirror/Games"
    repo[ 4]="$pref/mep-mirror/BIOS%20ROMs"
    repo[ 5]="$pref/misc"
    repo[ 6]="http://www.msxpro.com/download"

    file[ 0]="expert_ddplus_basic-bios1 0 expert_ddplus_basic-bios1 rom" #     <http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/>
    file[ 1]="expert_ddplus_disk        0 expert_ddplus_disk        rom" #     <http://www.generation-msx.nl/hardware/gradiente/expert-dd-plus/212/>

    file[ 2]="antartic_adventure        2 antartic                  lzh" #     <http://www.generation-msx.nl/software/konami/antarctic-adventure/25/>
    file[ 3]="arkanoid                  2 arkanoid                  zip" #     <http://www.generation-msx.nl/software/taito/arkanoid/887/>
    file[ 4]="frogger                   2 frogger                   zip" #     <http://www.generation-msx.nl/software/konami/frogger/70/>
    file[ 5]="hyper_rally               2 hrally                    zip" #     <http://www.generation-msx.nl/software/konami/hyper-rally/580/>
    file[ 6]="iligks_episode_1_theseus  3 theseus                   zip" #     <http://www.generation-msx.nl/software/ascii/iligks-episode-one---theseus/225/>
    file[ 7]="lode_runner               2 loderun                   lzh" #     <http://www.generation-msx.nl/software/doug-smith/lode-runner/359/>
    file[ 8]="magical_tree              2 mtree                     lzh" #     <http://www.generation-msx.nl/software/konami/magical-tree/655/>
    file[ 9]="pay_load                  2 payload                   lzh" #     <http://www.generation-msx.nl/software/zap/payload/432/>
    file[10]="road_fighter              2 road                      lzh" #     <http://www.generation-msx.nl/software/konami/road-fighter/684/>
    file[11]="snake_it                  2 snakeit                   lzh" #     <http://www.generation-msx.nl/software/the-bytebusters/snake-it/960/>
    file[12]="super_billiards           2 billiard                  lzh" #     <http://www.generation-msx.nl/software/hal-laboratory/super-billiards/39/>
    file[13]="msx_logo                  5 msx-logo                  rom" #     <http://www.generation-msx.nl/software/philips/msx-logo/2568/>

  # file[14]="hero                      1 hero                      lzh" # bin <http://www.generation-msx.nl/software/activision/hero/282/>
  # file[15]="iligks_episode_4_illegus  3 ILLEGUS                   ZIP" # bin <http://www.generation-msx.nl/software/ascii/iligks-episode-iv/99/>
  # file[16]="lode_runner_ii            1 loderun2                  lzh" # bin <http://www.generation-msx.nl/software/compile-doug-smith/lode-runner-ii/685/>
  # file[17]="mue_music_editor          3 MUE                       ZIP" # bin <http://www.generation-msx.nl/software/hal-laboratory/music-editor-mue/342/>
  # file[18]="river_raid                1 rivraid                   lzh" # bin <http://www.generation-msx.nl/software/activision/river-raid/356/>
  # file[19]="the_designers_pencil      3 pencil                    zip" # dsk <http://www.generation-msx.nl/software/activision/the-designers-pencil/3849/>

  # file[20]="hotlogo-1.2               6 rumsx                     zip" # +d1 arquivo
  # file[21]="ligue_se_ao_expert        4 liguese                   zip" # +d1 <http://www.generation-msx.nl/software/gradiente/ligue-se-ao-expert/3409/>

  # file[22]="-                         0 expert_plus_demo          rom" #     <http://www.generation-msx.nl/software/philips/msx-logo/2568/>

    for i in $(seq ${#file[*]})
    do

      set -- ${file[$((i-1))]}
      url=${repo[$2]}/$3.$4
      rom=$vers/$1.${4,,}
      echo -n "$1"
      time wget -qc $url -O $rom
      [ ${4,,} = rom ] || ( 7z -so x $rom 1>| $vers/$1.rom 2> /dev/null && rm $rom )

    # sha1sum *.rom
    # # d6720845928ee848cfa88a86accb067397685f02  expert_ddplus_basic-bios1.rom
    # # f1525de4e0b60a6687156c2a96f8a8b2044b6c56  expert_ddplus_disk.rom

    done

  } # msxarchive



  doperoms()
  # rotina incompleta
  # <http://www.doperoms.com>
  {

    local vers ldir list pref

    vers=$FUNCNAME

    ldir=$1
    list="$ldir/$vers"
    pref="http://www.$vers.com/roms/Msx_1/ALL"

    time (
           >| $list.html
           for i in $(seq 0 50 650)
           do
             echo -n "$i "
             curl -s $pref/$i.html >> $list.html
           done
         ) # 00:01:41.882

    cat $list.html \
     | grep -Eo 'href="[^"]+.zip.html"' \
     | cut -d\" -f2 \
     | cut -d/ -f5,6 \
     | sed -r 's:/:\t:g;s:.zip.html::g' \
     | sort -k2 \
     | uniq \
    >| $list.txt

    cat $list.txt | grep -if <(cat << EOT
antarctic adventure
arkanoid
frogger
hero
hyper rally
thseus
illegus
iligks
expert
lode runner
magical tree
logo
music editior
payload
river
road fighter
snake-it
super billiards
pencil
EOT
)

    # illegus
    # expert
    # logo
    # pencil

    # 618564  Antarctic Adventure (1984) (Konami) (J)
    # 618421  Arkanoid 1 (1986) (Taito) (J)
    # 618651  Frogger (1983) (Konami) (J)
    # 618388  Hero (1984) (Pony Cannon) (J)
    # 618398  Hyper Rally (1985) (Konami) (J)
    # 618526  Lode Runner 1 (1984) (Sony) (J)
    # 618765  Lode Runner 2 (1984) (Sony) (J)
    # 618496  Magical Tree (1984) (Konami) (J)
    # 618211  Music Editior (1984) (Hal) (J)
    # 618331  Payload (1985) (Sony) (J)
    # 618322  River Raid (1984) (Pony Cannon) (J)
    # 618445  Road Fighter (1985) (Konami) (J)
    # 618679  Snake-It (1986) (Hal) (J)
    # 618425  Super Billiards (1984) (Hal) (J)
    # 618217  Thseus (1984) (Ascii) (J)

    # <http://www.doperoms.com/files/roms/msx_1/Beam+Rider+%281984%29+%28Pony+Cannon%29+%28J%29.zip/618341/Beam+Rider+.zip>

  } # doperoms



# EOF
