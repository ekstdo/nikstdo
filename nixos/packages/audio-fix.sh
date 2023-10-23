UNAME=${1:-$(uname -r)}
kernel_version=$(echo $UNAME | cut -d '-' -f1)  #ie 5.2.7
major_version=$(echo $kernel_version | cut -d '.' -f1)
minor_version=$(echo $kernel_version | cut -d '.' -f2)
major_minor=${major_version}${minor_version}

revision=$(echo $UNAME | cut -d '.' -f3)
revpart1=$(echo $revision | cut -d '-' -f1)
revpart2=$(echo $revision | cut -d '-' -f2)
revpart3=$(echo $revision | cut -d '-' -f3)

build_dir='build'
update_dir="/lib/modules/${UNAME}/updates"
patch_dir='patch_cirrus'
hda_dir="$build_dir/hda-$kernel_version"

[[ ! -d $build_dir ]] && mkdir $build_dir
[[ -d $hda_dir ]] && rm -rf $hda_dir

mv build/hda $hda_dir

mv $hda_dir/Makefile $hda_dir/Makefile.orig

# define the ubuntu/mainline versions that work at the moment
# for ubuntu allow a range of revisions that work
current_major=5
current_minor=19
current_minor_ubuntu=15
current_rev_ubuntu=47
latest_rev_ubuntu=71
is_current=0
if [ $major_version -gt $current_major ]; then
	iscurrent=2
elif [ $major_version -eq $current_major -a $minor_version -gt $current_minor ]; then
	iscurrent=2
elif [ $major_version -eq $current_major -a $minor_version -eq $current_minor ]; then
	iscurrent=1
else
	iscurrent=-1
fi



set +e

# attempt to download linux-x.x.x.tar.xz kernel
wget -c https://cdn.kernel.org/pub/linux/kernel/v$major_version.x/linux-$kernel_version.tar.xz -P $build_dir

if [[ $? -ne 0 ]]; then
	echo "Failed to download linux-$kernel_version.tar.xz"
	echo "Trying to download base kernel version linux-$major_version.$minor_version.tar.xz"
	echo "This may lead to build failures as too old"
	echo "If this is an Ubuntu-based distribution this almost certainly will fail to build"
	echo ""
	# if first attempt fails, attempt to download linux-x.x.tar.xz kernel
	kernel_version=$major_version.$minor_version
	wget -c https://cdn.kernel.org/pub/linux/kernel/v$major_version.x/linux-$kernel_version.tar.xz -P $build_dir
fi

set -e

[[ $? -ne 0 ]] && echo "kernel could not be downloaded...exiting" && exit

tar --strip-components=3 -xvf $build_dir/linux-$kernel_version.tar.xz --directory=build/ linux-$kernel_version/sound/pci/hda


cd $hda_dir; patch -b -p2 <../../patch_patch_cs8409.c.diff
cd ../..

if [ $iscurrent -ge 0 ]; then
	cd $hda_dir; patch -b -p2 <../../patch_patch_cs8409.h.diff
	cd ../..
else
	cd $hda_dir; patch -b -p2 <../../patches/patch_patch_cs8409.h.main.pre519.diff
	cd ../..
fi

cp $patch_dir/Makefile $patch_dir/patch_cirrus_* $hda_dir/

if [ $iscurrent -ge 0 ]; then
	cd $hda_dir; patch -b -p2 <../../patch_patch_cirrus_apple.h.diff
	cd ../..
fi


cd $hda_dir

[[ ! -d $update_dir ]] && mkdir $update_dir

if [ $major_version -eq 5 -a $minor_version -lt 13 ]; then

	make PATCH_CIRRUS=1

	make install PATCH_CIRRUS=1

else

	make KVER=$UNAME

	make install KVER=$UNAME

fi

echo -e "\ncontents of $update_dir"
ls -lA $update_dir
