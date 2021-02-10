#!/bin/bash

set -e

main_png="StT_logo.png"

generate_icons() {
  png=$1
  appicon_dir=$2

  echo "generate_icons(): generating icon from file : $png"
  #echo "generate_icons(): generating icon name      : $icon_name"
  #echo "generate_icons(): generating icon in dir    : $appicon_dir"

  ! test -d $appicon_dir && mkdir $appicon_dir

  sips -z 16 16 $png --out ${appicon_dir}/AppIcon_16x16.png
  sips -z 32 32 $png --out ${appicon_dir}/AppIcon_16x16@2x.png
  sips -z 32 32 $png --out ${appicon_dir}/AppIcon_32x32.png
  sips -z 64 64 $png --out ${appicon_dir}/AppIcon_32x32@2x.png
  sips -z 128 128 $png --out ${appicon_dir}/AppIcon_128x128.png
  sips -z 256 256 $png --out ${appicon_dir}/AppIcon_128x128@2x.png
  sips -z 256 256 $png --out ${appicon_dir}/AppIcon_256x256.png
  sips -z 512 512 $png --out ${appicon_dir}/AppIcon_256x256@2x.png
  sips -z 512 512 $png --out ${appicon_dir}/AppIcon_512x512.png
  cp $png ${appicon_dir}/icon_512x512@2x.png

  #if test -f $icon_name ; then rm -f $icon_name ; fi

  #iconutil -c icns ${appicon_dir} --output ./${icon_name}
  echo "generate_icons(): icon folder ready: ${appicon_dir}"
}

generate_icons $main_png ./AppIcon

