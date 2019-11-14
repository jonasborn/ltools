#!/bin/sh
# This script was generated using Makeself 2.4.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3905888130"
MD5="aa9bf8e747c78e7d9ce85e714ec68bc6"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="born's linux tools"
script="./install.sh"
scriptargs=""
licensetxt=""
helpheader=''
targetdir="src"
filesizes="10113"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt" | more
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 587 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 52 KB
	echo Compression: gzip
	echo Date of packaging: Thu Nov 14 16:08:34 CET 2019
	echo Built with Makeself version 2.4.0 on 
	echo Build command was: "./makeself-2.4.0/makeself.sh \\
    \"/home/icm/git/ltools/src\" \\
    \"ltools.sh\" \\
    \"born's linux tools\" \\
    \"./install.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"src\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=52
	echo OLDSKIP=588
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 587 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 587 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 587 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 52 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
	
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = xy; then
	    echo
	fi
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf "$tmpdir"; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 52; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (52 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd "$TMPROOT"
    /bin/rm -rf "$tmpdir"
fi
eval $finish; exit $res
� �m�]�Yy<��ۗDY�tc�c_��/3��1�$e�(�/�-�S��*���-��d)��JiS�գ�����>����s�����u��9׹�{�����DEE�~E�(ɯ�~RI����\�WA"� %��A� 0�=|~�����R�������J��t���W����'�x���#��!�TB0 ����"&
 ���D8��c�A�  1�����㉴@�+}���RY����@*"W��?��mtPz6n�:6�Z`����K"���[�w|�'�}}	`( �����I ����%� ��{`	?�+0X��7�'��ȟ�Z�)�����Q޾�Dm������`�_���� }|��L�ϧH/�����i~��o:,�
�O{�^F� ,���K+���!,���T����[����$�'�����rz�w]b|�������{����O^Ea5����_�����w�#�J���?{�kA_I�p���@� �W�AO`���.��l�/����������˯��������_ȿ�/�?���P�WY������Q�Z`o2�O�ۍww'��|I^pO< �ù[�HA8�)���ۍ!�A�F(-0D���1>8 �tf`	x� �I��K�> �prD�?h\\4 �7�h��%[ �� ��d ��04�d,-!#�b�x��'�$_ B� xIG��LO�P���̂f�̟Y��b,�v�}5�� �NXJ"5iS�h����ۀ����� .O� �ڌ�--P6Z��N�05�$]�(}�z�} d@	X1g��a�·���a`�z,����f"��<�v����Q ����o�	���?4,uB,=�o���I��A ���\�ك�h�X	����7o� �:d�p`�n�: `�	��#�4�Wh��]R��|��?<��k���������������H��TRX}������Z&n���s�	��-�Lfz6:0#s}����40�zz�v榕���t̍���m���_�uu�����8L`��Q��ч$9c3Y#���r&֬)�)�S�-��L���o<%����fO�ʄL���_��JxNN�?���9IG�J�+�M?��z9��JW�;��76���FvZ1����<���+'F~�����YY˜ Έ_��-se/ 6��n��l�\����[@������'	�J�h|K��WC�o{tGc���֔x���P�Bs�a;(w�>�)��J�s�����!���G�G�hA-��k}�)ޝ|�o���_~����=f���.
��V�)u����6:��5�c����&sPQ~"��CbN�I��N�p��;�:���]l�I;�����&�Y����󿅘�s;]�Ƞg���5<�(��A9�Xw��p��=~T�Ai��Y1�[����@KU���C)h�Oy�)-���s��f�l�d�����J*��YX�ɊiX��KdE'�;)�c��q���M�"�cY�9��R�oY%'�v4g���7m����Ct�0��Uk?����!��W�i3��p��� ��7=�X��]�^�AΏ��p��ta����wI^�I6A��cPPU��8���:<�������v���`����%i���:�����כ<� {�����ܪ��;R���^m�j���9ÍM�/]��3�E�2�����6A���<Y}��:�_r���ht)F�"��y���]��D�^��f�	�6������w�4Bo�p�T���>Y@�6$n�Smz@̈�l��{p���11�Y�d�Q��F�몔	�����,�Y�[�����Y{����Z�E�+-�C��,:Bt)�ؽ�/�ޡ���jZ�	��Q>���ϣ�U��	�L�eǌND����H��op�o��/�{n�"v�%��l\��~���햽m3�S	Mؘh�xhè'�G��	I�}�	�����Ov��It�x�����&�6o0�b4��Ve�I��9��sy�R�]����!\��C>Xk�'W�{|Dۧ��uL���q���T)`k�s��6�`h5&� �86ݪE1/K�l�H����uW�ΤɍV�.��.��#��*Ti�������dz��n�7�	�۹N����w�Q3�4�'Μ&j���ZWI�s(m�~���Z���mni��8�8x�%A���2ƌ�1]�a�5���X�K�>yzo3чh�ǃ|�|�S>WQ�8`�^ ݭ��s�OL��=���\��gQ�p�@�xq�S㊮�6צ���wJ�#m���gu�b$�m��%�����%�bղ�v��t�u��qxQz*w��~eZ�@�XN�Q�1Q/էv�6}v�ݚ�B�P���TǙX�����&l���ȯ��4p	�N�qn�fɜ�D�����r�-A�})�����9]�B;����3	 �nC������6��B�+�N�kA��S�չ��=m�r&���\���5K꥾�:���y���᫷��&������m�A��(��[˓n/nkRh�cV����������*���zr��&a.�i�לgZ�UӲ�&����S�m�FU��fJW������0���Jz�m�>UxD���i����$b_y_:YҺy�_��&��)�ɛ�o�L<�j�s0T8>�(�Qڣ���\��z��;-���X�}��R})���؎W�Ù<��燲��N�N�F指�2_��8�m$�(���u����]{[��r�L[��<t��0�����=�l��+�<��O�ﮅř����
<;���ڕGP�E��~�R&v�[��k�,	��.y4�axH��t���)��S�D�5��w.�2G7�	g�i��:J�Ŏ(�;�&�,���g9�k��Kw����3΋t�}M�b�֘y�ꮧ��oh��gv���.NȺd������k���\bbx�l?�Nv'#����_�������/��e{j����y-�k�a׳�H{��d�~�[AS���֊=o�T8���F�U��+ N�Ȧ���lҸ����M��M��
\�zEDk�����V�>������yqڶGՆ�<ѝ�h�Itwc��m���@k�3ڢ��Uʥ����.��_J��y���i5�A��;+Z�$];c|��L�=gu�NϜ�g_��'��e%l��8�t�q{XU��h��B�Z�wIHb4�#b�K���O�v��X�K�qb�e�1wA�>��61��tU�H�:Q��
����M�R;6ß��3��UG�x��;�Ô�W��������_�[4��I�0~[�}��J&9�7���\�"���5��@�>j��~���*%����D�Ίb^�F����S�ޱ����^07?邐?t�b=�o��2�7�ŏ0���av����}��-˞�0dfo�?T�R\���B�5\���6q����ffIJ]�3Gj��8��;f=|�-.�3���_���^�P�-�H�:S|4
�X�rŷ�N�:����H�	v4��&����y�V�C�Wݷef��_�@�>}�z�2��LѸ�q��S�"'�|������W�3�na�uc��N}������A��L秚h�c�G�1��ݺ�D���i���f������-DݖRJq(����o;M��� ���b}�a�=�^�V��u'<;�g�=!��w5�SXF՘?J��%v�ؾ�������x�s.(�<�����eJ��ʺӾ �ۉ���
��׸;��?6��K��ᛚ�)�D���M�m��B!ޭ1T������Ĵ-��z3;0xݜ������C�Ua���t���A���>SS�Z��uQ9BG�H�������$[���1g��"vmp���h*�76	P?��|<�ɃE�����zT��?Q�����#n�<1�N�����@���Q`�eɞ'��-��o-�6�0&�H�氝�*���uѐ3�pd�	]�'	�<.����ԌZ#rK$��F��i��J�@t���'e�!�!yc�Q�*%M��i^�d�`�v��(��<�_e}]_��k W��#�]a��{^4�k�JL��[X�� _��rfU!�Ӌ�x����tq�����#��9��#m�.��T�6M�"�߇5��dA't����w�f��^��|&^z�aV�b�=Lx�,WPXˡ�[�2�d\���3�
|��f��tE�6�Ȼ��d͓Gp�w&��P�����ݼF=�E�2�дp�8̶�r�V,�=����Q�`�ݡ_���!����h3z*�=s���0�m�Y($����_�#,�Jڞ�˴/�bxĲo���� �Ѩle�6~�0�q�й�A�Yշ�3�{��B�<��%)諏{���O�h�oly/�a���Fz�i?G��}�5��}���R����5��Y�nl��#�_��´���[�8#�!��#zቸ��9	�d'�����?�[wTS��FJ��{�"E��t�^����Ћ��P�D�DJB��A@F6P@�Ν��{����}o�7;+k%����������>��k�&�if\�v���*|#�|�Z{-�-���;ĉ�sG_�;���a>���}=1���Z��/sQ��Lꠊ?�E~�?Qz�m�i?�\��t8BJ�,^��!x*�5R��@3ȇ������/��6��� �WgL�_$���`� L�	n�N�:YSn���sr������نLJ6������,��0��^{0����'��J�'O<A�#���H��z�0ٮ��	���W[Z�=�yf������/��?�҂�M������5h3��C���G�S�
����	�d3�����a���o�c�rto�k��L5�Hv?9[����Aƴ�8�H��D�F!��4Ap�e�@v�C�	�]�⨋xI�.c�xB :8 �uG(�ovͼ��PO���V0�5H�x��,�^K�P�qY&��)J�[F��Ʋg�i��.�Ӳ���l���Q3��=�� ���ȁ�I��<�yh�|�p���#6�#�I�6 �{ZX?�CՀ�^�� v�g%+���@[ԅ��Ew����]�(�+烽����=~s�/��ȼF�� ����� ���d�/�X�Tu3�����r�Vj�7X��$ˣ�d��Vzo��(��ʓ��%!��H}�(���z���Z�~z���M��ݤ����YO��E��(�=`D�KO��MSk.Ԟ:Ww�*0�!w����[�f���gc�vO�t|h;�^?�����ү<Є�~ԙ�1zw&;�t&S��Q_x[˿��അ�(��f�ěER_</��Q�q�^1%&��ʪ$~���*B�q�]����\;6d��`�2A�P�R)ۣ�V��u�^
�\P$�K#["׮v�+Y����fM����î��O2�Lc���C�v�������Z^����}	�ߊv]Jv�)����PF�*u����h>��vL��n��� 7B�V�΋ά<P����nB��3
"�|�'v���n*�'�}�Eo+]A��߱ՆN�/�ǐR���l/��ѝ�w�y�*�_�\�NI>f/���U\?h���JGcY�fG����
;a�UY�n��pR.Ao�_9l��!�F���Z�]�2<��c6�D)�
�3�ɮ���O}{c�0��y#�Sj}�}����*������0,N�P9?���v�m���Q��OU�����Y�c=W����Ζ�h�	3Z��z�L̠�Xè5�'��i�	T�8����Tg *E� ����(g_��c�2�kw=`R�mc�������(���&��e=�{�o��Q��K���:0$�z����ܞ��x�ΖJK�қO����l���HS���l�r 9�0B���$&kts8������k9w��j0�B�ۅ_2�֦���Y浪-�)5�8�*��M���<>:BA�z�DD�3)?�j�}F�k���ŇYŭ���o<��LcL8T��Re}��W��|�H�`�1�򓛿a����8�!yv��^dހ#�tr�	S�dl�g�����.'v��R��u�v�Z�N�@`2�ۅ�P�~���3��b��4a�� �$��Wp��e��vܜX�X��	��o��,��
���c�V��!u��K#����
P2֧3���Ԍ�9`^���=F3�u��b��kSX�FU�A��)��n}��e{*�Z�w��&�hT����őoxK���Y��)q��D�s|��O2ʴǭ������x��w�t�����RV���;`��jKT�mXS�s[R/�Q������7��W�
��)�Ɗ��]�p�e��J$P��6���IR0��ˊd`O�GJ��h��/&�	���)�M��*{n�
؋��u|�όb���mw��}���) ��~�1�y'&O�:g#��a�z�K��
a���lv4���V���[���P��c�IQY�G6���#J�gIA����\�oyl�i΢�x��wѹWM�J$����$?�O�:��WYU��O�N�wb����N���}����ū�u�@�aD$ ���Z�Y�.v���h���P40u�*
߼K����ˌrC�r�<�[�����)H�9��D����1"�XB;nN?����.����\K[��&m��v'��Z���{{mC��-sWS�MtU��-#1l���f�цNZ�f��_%t��"$G'uT�-L���[Xm�K�M��}���S����><�d���>$K�#ڛ�S
�H�g�3z�kE�Y��g�e�o��E�-"��D�T���B9�l�m���M�O� R���י }���/�ns���B�I�@Z�>N�ғ����g� (=��?�`L/:����b$1*��e�=q�O��)�5N����p$Ψ(�B\f��~�F�*�%�G�`p�2*�K�ͤ#7����2L�|�Ȝ��hl>��Rn����F�Gq
fw��T��a�����ieD.J}K �${=a��Ԡ9���,�M��K�@eI��N�W�tY�_'�~�[�{0��l�^���%(���1C|X�1�s��L'���Rӂ��sѭE�ͻ!�S�:��<�5/�A�oF�th�@�� >�u�l��\f�\{�BM�^��A6��/>Vl�4>޶��{��h����eK�252�)]`8U7���AxOb��[(�g��%��7�!�8�>����,�>.;e{�t;h����F���9����N3��"�YČS������������fWk��F!ٜ)�����~�
�W�����hy��!�M�b�<��|��*��Rp�_�U�\/�R���5DG�Ϫ?��}�+1�7����m�K*Ow� ��̸m+�b~�j��9	_<"���*�l��������-c��ãx���1���=�u/}4-�ҕ{{��L�:MzV`Nڔ�6]�j�;�W�s3�������»���*/<�-�M�ʃGJİ����C��ꐗ׾�����@��n��%��;��_�K�?B� �VQ1�N#\����P,;"�x�^����WA$�%�[��[#oX��H�|�?B�k�!�$^�nX���]V�*�#E�!�!`%�C)t��@J��z(��A(B�R��-kʁ,��ʱ4:rDLI�Eӧ���B�#x b�}��ІGHu��! � �_qGA��hmD(�+����h%�5���#Lt��8�#��=N�z"|�������`�С�W��d�o���b���z��IGrsdq���5<0V9r�^��{��"�&�8Ȱ.*//.)**_,+������j�����v\>��+��9��A��XF�.�λv�2f0�)��1�<��0�u�/}�vEE9v�y��u1�y��c���d�.
�*pg��DA��֦S 㜾� ���^*�XLZ[w��#�:rn6����+ps B���T�Cݟ�� ��<#\�"�>l�]��ԯ�O�7�݉�p�t�q7oBX����0����t7}�3�\�4��M��|�*"�u�V�P�2"#A�?���mcT�^؅S�i�W��8�Z�c}9�ľc���[m����$���9.�
-������@��"W�rika��a�x|ߜ��R׈�fs	r�˦!�>��6��)���<��5P2���{���$'����1X��Lιi��Z��G�U���v�r��G�픍(��$�����ffc�/��?Y/�eI�Tǹk��ۀi8z&�:����v�i��D���u.@RGk#��&�3Gt�rb��nl��������Y4ҩ�6��Z�Oaᩥ�J����ܧX�m0����Z���WM�`��!���6�f��m��V0�e�����1+`Y����l���*a�PF]�;����KKIa/ �2�4r��!�KV��.[�M�ʕ��r-����xiO�~@̓ఖi	3a��aTJ�R�x�cBk�QFY��ޑݤ(s'�ˉ�S���7o��r��,(�����a�-�|���TWw��(�n��Wng���q�c#?�1X�n{��߹��^l�ڀf�����/��m�k����(Kd��q��\�y�kS�5�@������ג���r	h*�3��d¥�׬������Y�m��L�v/�7J�
�U�����!����@����A`;�o7���l�d�/~�1�m,}�''E�XH��8`֏�ń��+}�`���H��ӵ��gR��;k���{[(��Z珬�b���g������lb�lY��E������SIi=�.�5�J4����P��/��Xb�q*��n���[�F.����r¾�CO�����W_��F��ǵmN��N���3Xmb�@�y�'N�8�KTk���H?o�5R������R~SO^����v ��0.�cHV��Ay��zь�rS�\y;Q �[��U������i�ǫ�6��3��8�i�Q��G����8��P9��[k�z�o��£�}r�����v�[��ukL\?�d�<����Us��w���Qy�q�Qc`2~i��{L���%�j���޼H���1�m`�a��~A�>�a
�|�  �"��%� $@�� �@'�4
 C�
�P��I�<�d-�j�9%���<�3a��4 ����٪�Y������ {�L�`7�4=����.�c�u��űRЂ�!��L; ٯ��7��5������f�cz��m ��.�
��W�S�cf�G�gUYO��L1���8e��R��0�I�d_]��`���	�U���\��\��\n����g�Lʔ Պ;��v�c�{$��e�-����AB*CbAgAs��x��ܷ�Ż�p��F?]��W.��K�<E�+��u�ӭ!��z�L�n7��%�A�d+*�ï��#����,�.~�r�x`�6AaF��c��E�E��e�a�J���9�=ݣ�vN��i�0���O�թ7����� �L��FW�5��~�P������\%��� ���=�հ�<�Ǘ�=����&�����ԇÛ��,a>��@L^�Qg3�WX��[�LT���i=�88��C�{����eǹ���e���!�ӥ��(�������c���g!����7�)�#�Kr.姆q��"�㲰���V$�{'�W�\:��!�=Ck9o�H.?����НsS�'��?('g	d��?P~^�윗��g&�?�C�pvx�v`��_��:���z
F�糗����S�C��֟��#�9go�r�3��J�x����k��(gn�c���]���$�_yߝ�����~S���I������H^������*��x�%Ŀ�������KJI����_���h�+r��v����j65RU��E��y�w�������߿�v�8Z_EO��Gccs���7	���k�~���7?G�L�;�"���0���gy��g �âb��Pi�G��|�3N����k���}��:���_-��������s��������)p��D�9�h埮@������8��_���e�� �\� P  