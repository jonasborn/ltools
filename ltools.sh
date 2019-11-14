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
‹ òmÍ]ìYy<”İÛ—DY³tcÆc_Š²ï†±/3˜ƒ1ö$e‰(²/•-ÄSèÑ*»†-”©d)‘’JiSïÕ£å×óşñ>Ëïóºæsæûœï¹Îuîï9×¹®{äà¹ÈÓDEE‰~E¨(É¯¼~RI© ¬Œ\ªWA"å %†¿AÈ 0à=|~‰û³öÿR‘ƒàÿş•JŠŠtş•”Wùÿ»ø'Èxÿ£ü#¾å!TB0 ò«üÿå"&
 ÁİñD8¸c¼A„  1¬Êÿ‘ƒã‰´@ø+}ÀŸìRYùÛó@*"W÷ÿ?µÿmtPz6n–:6†Z`¸¯îîK"‚¿Ô[£w|×'}}	`( ëøìÁâI Ì€„Û%â ƒ{`	?èµ+0XœÁ7ô'°å†ÈŸéZ©)çğ½ú³QŞ¾ÁDm­‡Šøº„`¨_‚¾è£ã¾ }|±€LÈÏ§H/´÷§Ğåi~¾üo:,æ
£O{é‹^Fˆ ,à—ÖK+…àë!,­—¯Tı§®ß[ÿ½‚•$ş'Ëú¾çŸ¼rzßw]b|Õïÿáÿéÿ{âÅåøO^Ea5şÿûø_ŞàÿÿÄwü#ÊJ«çÿ?{şkA_I‘p‚†ì@Ò ìWŸAO`„÷«.õ¿lÿ/–ÿÿ¯¨¢¢²”ÿË¯úÿ¿“ÿÏÁÒ_È¿Ò/ò?çßòP–WYõÿÿ”ÿ¡Q¦Z`o2ÙO–Ûww'àä|I^pO< ·Ã¹[ãHA8’)Œ“Û!AºF(-0DŠ–ù1>8 ¼tf`	xâ æI»•KÓ> ŞprDé•?h\\4 ²7h‚£%[ ø€ ˆ¾d „Á04›d,-!#øb°x¢€'$_ B› xIG°LO×P¦´ÜÌ‚fÍÌŸYï‰ÿb,ŒvÆ}5ä³è ŒNXJ"5iSÜhúù’ÈÛ€½Ÿë–îÀ .OÖ èÚŒ¬--P6Z’®Nò05ˆ$]¿(}šz­} d@	X1gºüa‡Â·äùµa`z,™öµ–f"ëÊ<ŸvØ½§ÛQ á¸¯øoŞ	ÈÁÁ?4,uB,=Èoô®¾I©¥A Ğòè\ĞÙƒ¬h‰X	ø¼—²7oß ²:dÅp`ĞnÚ: `ô…	§ñ#³4ÆWh¯¸]R°­|öÿ?<¸ÿkÿ¯¼ô¿ÎÏü¿‚‚Òş©¬Hÿ‡TRX}ÿÿ·ˆ¥ÉZ&n†õ´sÌ	™•-¬Lfz6:0#s}øÇ†µ40ËzzãŸvæ¦•¯ÍtÌôõ¬mäÌô_šuuššÀäú8L`Ğî®ßQòÈÑ‡$9c3Y#³¾Àr&Ö¬))‰S-ÒŞL™“Òo<%øòÙñfOòÊ„LŠÏà_ŞJxNN«?‚ğò9IG—J¬+åM?ÅÅz9äò’JWµ;ÍÜ76®ûÎFvZ1õõòÂ‘ä<˜€€+'F~­¢ÉßîYYËœ Îˆ_ƒí-se/ 6Ãn“œl‡\ª•¦¼[@¬‹û÷ÙÌ'	êJßh|KôªWCŞo{tGcÿ–¸Ö”xŒ€ŒP…Bs»a;(wÂ>µ)…³J³s‡ë´Æ!Áı°G®GœhA-ÃÎk}Å)Ş|¹oŸ½_~ãÈÇâ=f³¨é·.
½ôV¸)u’üà6:¿°5ùc§š€¦&sPQ~"¨åCbNÖIã¦ÖNpö‚;š:õ†–]lI;­«®í&›YÏÛÀïó¿…˜­s;]ñÈ gªíİ5<¨(ÇÎA9£Xwöºpİó®=~TöAi¸¬Y1ã[²ù‹»@KU±ù‹C)hÁOyæ)-áàsÂıfælëdû«®úJ*™ïYXåÉŠiX‹¨KdE'”;)¶c‚ùqåú¤Mõ"àcYÏ9…£RáoY%'³v4g‹—­7m›õñÌCtê0œÎUk?•´†!”ñWëi3­ pş¸ ²7=°X¦ì¼]è^ÁAÎ®p»™taÿë£ô’wI^ÀI6AÀícPPU¢©8¹½Ÿ:<Ë„í©ªÛòvÍËÃ`ŠÒíÒ%i®ÚÓ:ÏŠÔÔÌ×›<Ë {ŠŸƒ½ëÜªØí;RŸú²^mäj©ä‰È9ÃÂMç/]Û3·E¢2ı¹úºÊ6Aî«œ¾Çæ<Y}ÇŞ:ñ´_rˆŠ¾ht)Fí"ÔòyÀ³]“¸D™^Šf½	¥6ôêñëáÜw£4Bo¸pTŒ’ï¶>Y@„6$nœSmz@Ìˆ°lã¾{p£Ìú11ÓYédôQ¨êF•ëª”	­©ş‰,ØYş[²°–’Y{óø´¦Z¸EÆ+-ÚC²Ú,:Bt)¥Ø½/ìŞ¡ÁÌçjZĞ	„ÀQ>û“™Ï£áU£‡	ŸLêeÇŒNDêé¹ÑH¬ä™opåo°Ú/ã{nö"v¯%Ôõl\šõ~êóí–½m3‘S	MØ˜hÃxhÃ¨'óGö¸	I®}Ğ	í‹íïOv¾‰Itëx“èÖù&©6o0²b4øVe½IÓÖ9Şñ¥‘sy‰Rª]ïÑÍ÷!\š·C>Xk«'W³{|DÛ§­ uL÷öÀq¿£T)`k¬sØó6ã`h5&æ¢ ş86İªE1/K»lßHÇğğuWÎ¤ÉVÿ.Ñ÷.¶ê#ˆ¾*TiùÜØÙÀğÜdz‰Ònã7™	‘Û¹NØù£´wõQ34î'Îœ&j¥ô³ZWIÊs(m«~ÕêçZåíåmni•ñ£8º8x…%A¡ºâ2ÆŒ–1]¹aÁ5»ËçXõKŸ>yzo3Ñ‡h¥Çƒ|Ğ|ÍS>WQè8`è^ İ­§ÍsØOLïæ=øÿô\·®gQ˜pí@â­xqì¶Â„SãŠ®ü6×¦İŒŒwJÄ#mªó®gu£b$ºmõ¼%¸§£Õø%¦bÕ²‚vÕ²tºuÎöqxQz*w®§~eZñ•ˆ@ŸXNÑQµ1Q/Õ§vÔ6}v§İš‘BÑP¹ÏÍTÇ™X™š¡†&l‹·‚È¯ßñ4p	ïNºqnÇfÉœâDŠÿÕÌr±-A¥})öäö’Â9]B;İÍÔä3	 µnCˆˆ°°Ï6ìüBé+ÏNökA—ïS·Õ¹Íô=m¹r&…­Ï\¢„Ï5Kê¥¾«:±­»yºæÂá«·ôÔ& Ö…˜ƒò¿m’AûŸ(³Ó[Ë“n/nkRhÅcVèÀƒ©ÎóÙêöæ©*¨‰zråÛ&a.­iû×œgZÚUÓ²÷&Ç¡ø¡S¹m–FUµ‹fJW¤¸ú…©0‚à›Jzßm’>UxDø°úiûší”ó»$b_y_:YÒºyß_ƒğ&‚†)£É›İoˆL<¾j«s0T8>±(ĞQÚ£±×Ù\ÕÂz¥›;-«¤·XÈ}Ÿ¢R})ıÛØWÑÃ™<˜î‡ç‡²ƒæNĞNûFæŒ‡·2_åôŒ8m$ï(½‚uÕù°Ø]{[¬ÏrÚL[úŞ<t‹š0ñêòÇÈ=élèÑ+Ç<®˜OÌï®…Å™Û™Öò
<;íÀòš±Ú•GPÕEêõ~¬R&v«[ƒ—k¡,	­ò.y4¿axHªÍt´™)—…Sò´Dÿ5ûów.à2G7â	gièé :JàÅ(»;& ,ğİÉg9ì§k”ŒKwŞÖÖİ3Î‹tÿ}M¤b×Ö˜y«ê®§ÏÅohìïgvõß.NÈºdÉÃƒ‘íÑkû¨›\bbx±l?öNv'#ƒà½ß_‚ÛôøúÊö/’­e{j·ö½Üy-Õk”a×³¡H{ñôdÎ~Ş[AS“ùÈÖŠ=oºT8øº÷FËUÁÜ+ NºÈ¦´¡ŸlÒ¸Œ¦ «MœMåÜ
\zEDk×ÖÕÕÖVä>é´ÎùÄÅyqÚ¶GÕ†‹<Ñàh÷Itwc”€mğâË@kä£3Ú¢üÇUÊ¥¨Á±….÷å_J¥ôyø«íi5—A¶Ø;+Z£$];c|¸°Lå=guŠNÏœ“g_¢Ô'ªße%lí¼•Õ8‹t†q{XUıÕhëB½ZŠwIHb4²#b‘K»í÷OÅvº©X¯Kï¨qbe“1wA¤>íá61ŠĞtU–HîŸ:Q£ö
”İìMÀR;6ÃŸ·ß3†ÒUG²x×ó;çÃ”ÌWŸâóïşğ‚_‹[4êîIÆ0~[…}‹³J&9¸7êÜİ\Ç"—½Ã5àÑ@Ï>j†ƒ~”ƒá©*%Œ£ÄùDÅÎŠb^ĞFïáê„ÅSÇŞ±á¬òŸ§íğ^07?é‚?tåb=æoÇõ2Õ7½Å0âæşavİô”ì}—ê¼-ËÕ0dfo»?TñR\¸åB›5\Šğ¾Ó6q›¾…õffIJ]Á3GjäÙ8®¦;f=|Á-.ù3Á‹½_ˆ¦^ÛP†-ŠH¤:S|4
ÔX¥rÅ·N­:­„º÷Hë	v4¼¡&÷àìğ±y„VöCûWİ·efò“ô_ü@±>}€zÙ2¾”LÑ¸³qşõSÿ"'Š|ÌîäÜñ’W™3Îna¾ucõN}­äÈùÚÄA‘…Lç§šh‹c³G£1¨×İºÒD‰›Ãi®ìÖfÆ‚ª§øï-Dİ–Rî³¨Jq(åÒ…«o;Mœî™¡ ›¿ıb}¯aË=«^ßV»Íu'<;½gª=!­åƒw5•SXFÕ˜?Jú­%vÉØ¾±ŒßÒøĞx‡s.(Ì<î¸÷eJ‘§ÊºÓ¾ ’Û‰‡¹Ñ
ñå†×¸;·Ç?6ÄåK€×á›š»)œDöÉMüm”ÆB!Ş­1Tş²¢£ş²Ä´-öçz3;0xİœÆÂÁ¤óãC›Ua¾°¨tÁÌİA——ó>SS„ZçóuQ9BG‹HŒˆœ¼ìãã$[¦ˆê1gĞë"vmpÔåèh*Ï76	P?Éö|<üÉƒEëõ¢…¥zT€„?Q—µŸÊó#nâ<1¨Nº·£ñ@ºµêQ`eÉ'í“-ío-Î6Ü0&äHòæ°¬*™âÈuÑ3µpdÊ	]È'	Í<.š›„îÔŒZ#rK$†ËF¬ƒi÷ÙJ®@tñë¹ã’'eí½!ª!yc†QÊ*%MŒ¿i^Ğdê`œvÓÎ(µª<©_e}]_¢k WÓç#ë]a›™{^4Ùk™JL±ï[XîÁ _º¹rfU!ªÓ‹—xü¢ŸÓtqüğ‰–#æ9¦¢#m‰.©—Tã6MË"êß‡5”½dA'tìÂåwâf³ù^¼ìœ|&^z¬aVb=LxÍ,WPXË¡Ò[î2Ñd\ŒÙ3
|œŸfÑÏtEº6„È»¿³dÍ“Gpãw&¡¤PÀ®‹¥İ¼F=EÚ2ÕĞ´pû8Ì¶Ír­V,Õ=øŠ¿¸Q`çİ¡_°ƒÌ!—åìĞh3z*›=s²—û0ËmÄY($Æş°Ü_–#, JÚ»Ë´/bxÄ²oáèÂ úÑ¨leÅ6~¶0¼q¿Ğ¹ŸA¶YÕ·‰3µ{ŠªBÁ<‡·%)è«{°­O¡h²oly/õa¶ŸÕFz´i?G¹Ò}¦5îû}ÚşòRÎûñÈ5ôYænlìÃ#_…ÌÂ´²œÓ[ã±8#¢!‹Ó#zá‰¸åà9	íd'ˆæ¿çì™õ?í[wTSù¶FJèĞ{—"Eª‚t„^é½÷´Ğ‹€ôPéD¤DJBˆA@F6P@Î™¾{çŞ÷Ï}o­7;+k%ë¬ııÎïìì½ÏÙù>ıîk‡&üif\÷v³ö¸*|#–|â‚Z{-ı-»¢Ô;Ä‰ısG_§;¢°ƒa>¸ºÖ}=1ƒ×ÖZ¨ú/sQáõLê Š?”E~Ô?Qzümái?®\Â°t8BJÂ,^µæŸ!x*´5RÄè@3eÌ‘àÚè·ÉÛ/µ°6Êø€ ÅWgL¥_$ĞÉÎ`« LÄ	n™N§:YSnùÍÉsr‰†µ¤ÚÛÙ†LJ6§£®ˆşò,ÔÁ0ß^{0–“œ‹'¤“Jº'O<Aã#¦¤úH“Ézğ›0Ù®ÿå	¦’‡W[Zü=“yfİö—Õâï/•Ğ?›Ò‚åMø§»Şáë5h3îî˜CŸ¬¤G”S’
ñõ•£	¬d3«ğË§aÜşÈoÆcórtoìk¤½L5½Hv?9[¨Š±àAÆ´Ô8ÙH‚×DÆF!ÕÂ4Ape¸@vóCƒ	÷]–â¨‹xIî„.c£xB :8 ·uG(íovÍ¼ÉòPOù²ÃV0Ê5HØxÜÓ,±^K‚P¤qY&´È)Jì[FëÛÆ²gòi¶Ú.ÉÓ²²î¾Ìlš¡ÚQ3ãê=ŞÏ Ú¸÷È‘I¸©<¬yh¡|Ípÿ¢’#6ó#äIô6 ¿{ZX?¦CÕ€¦^‹ vìg%+ë ğ@[Ô…ú÷Ewëõ×ï]õ(Í+çƒ½–öÙÌ=~sŒ/‡ÅÈ¼FŸ÷ šˆé ¬áÔd¢/›XøTu3èÊó‰Çr•Vj7XÚ€$Ë£’d»ÁVzo“(‹…Ê“´×%!¥ŸH}Ì(¨˜÷zÈÆÖZ”~zšóÈMè´Ìİ¤øü©õYO÷ÑEòòµ(œ=`DÊKO–è™MSk.Ô:WwÂ*0ª!wÖÿùè[µfšğ¨•gcæ¾vOät|h;Ş^?ŞöŠÊ×Ò¯<Ğ„»~Ô™Ì1zw&;Ët&SÄ¼Q_x[Ë¿êÚà´…ˆ(ğ€f†Ä›ER_</ÒãQÕq‘^1%&‹®Êª$~¿Ñİ*B¢q’]¯ëÔø\;6dÅ¬`‡2AõPâR)Û£³V‹Úuà^
ø\P$ŸK#["×®vÜ+Yªû˜¦fMÊõÒÄÃ®­’O2ğLc¾‹ÆCv‚§¤ˆÀÔZ^¡´Ëê}	ÉßŠv]Jv¢)òÑ±µPF”*u¨õÆËh>æ“vL«½n¹»˜ 7BÉV©Î‹Î¬<Pã—şÌãnB÷º3
"ñœ|î'vÎn*ƒ'É}îEo+]A ºß±Õ†Nç³/ÇÇRª­ˆl/•éÑ”wŞy·*©_“\²NI>f/¿º…U\?h´ŠJGcYàfG¸âş
;aµUYän›ËpR.Ao_9lî¼õ!òFáÑúZ’]›2<æÅc6šD)Å
ò3şÉ®ä×ç†O}{c¼0Ç×y#”Sj}å¶}¼ÅÚü*ÍÔË÷ïà0,N¤P9?¹İ“vÈmÃûøQë¸ãOUâãàğıY­c=WëŒÜı‚Î–ºh“	3ZªÇzìŠLÌ ØXÃ¨5¼'—•i•	Tª8µ¨ÔÍTg *Eë şØæóœ(g_²Æc2Çkw=`Rşmcé£Í½…ã¯¾(ÄŞÙ&Âäe=—{âo¶˜QúäK„õ€:0$Àz¦²™ÜüæxÈÎ–JK–Ò›O•¶‰Ôl…şêHSëçşl²r 9É0B½‰ $&kts8àÀŸ©k9w®ºj0÷BœÛ…_2×Ö¦ ¤·Yæµª-×)5ï8ìµ*±ÀM«áã<>:BAüz£DDİ3)?‹j¸}Fâk´—ğÅ‡YÅ­¬ğo<ñ·âLcL8T·£Re}‚êWøº|€Hƒ`×1£ò“›¿aí€»ø®8â!yv’«^dŞ€#ˆtr	SÆdlìg¼îÀµ™.'v÷ÕR°¯uâv‡ZºNê@`2Û…îP¨~¸ææ3ŒòbÖõ4a¬÷ ı$ãÚWp”™eüÊvÜœXûX¹«	–ŒoˆÇ,„˜
ªö–c‚V›æ!uåüK#ªù¥¼
P2Ö§3¿á½ÊÔŒš9`^„µ‘=F3‹uõbÜõkSXFUìAĞ)«¬n}ïíe{*ØZ¾wÚû&hT†½îÄÅ‘oxKƒÎÕYõĞ)qÃ×Dés|½ÖO2Ê´Ç­›¢ˆÜx¹üwüt—ÆóòøRV¿õï;`½–jKTÙmXS‘s[R/’QêüÁôš„7¶WŞ
¶ó€»)êÆŠğì¼]½pÔe»¦J$Pª¹6ÑæIR0ŸÕËŠd`OªGJ¯­hˆ¬/&¢	ùÂÁ)ùM‰Ë*{n¤
Ø‹¾u|ÕÏŒbµàûmwÍß}¹µ·) õ‘~š1ày'&Oø:g#Áña£zôKª®
a­¡Úlv4”ÙVğŞç[ÒÕıPŠŠc‚IQY‡G6‹ƒ#JğgIAùııÇ\ÿoylâiÎ¢Îx‹ŸwÑ¹WMËJ$şÁ³$?âO—:ŞÌWYUßßO‚Náwbô—ÙÜN¨¿Å}»Å™Å«˜uë@³aD$ ù¼î´Z¶Y¾.vùôøhÓÇ­P40u*
ß¼K¹·ƒÆËŒrCór¼<Š[Ùô¦ëØ)H³9ù½D¸ÒïÊ1"ôXB;nN?©Êäó.…½èÚ\K[­Œ&m¢Áv'Š±Z—°Ï{{mCéÙ-sWS«MtU†²-#1l‰ÊôfñÑ†NZïf«_%t¼ş"$G'uTÂ-L„µ—[XmßKìMô }üƒßS«š¹·><dŠ×>$K¬#Ú›ĞS
H”g¸3z¹kEÓYîgÏe¼o‚ÖE‘-"«ÚD«T©ƒãB9’lœmıøÂM©Oè R‹´Ë×™ }î”/½ns™®«Bã†I§@Zœ>NÀÒ“ïâĞë¬gí (=âê?‹`L/:°Óğ–´b$1*‘»eö=q¬Oœï)Ñ5N›õŠp$Î¨(íB\f€Ã~¾FÒ*Ò%¯Gƒ`p­2*›KªÍ¤#7£ÛØë2L¢|„ÈœİÅhl>ÙğRn“ñèÖFéGq
fw¦³T¤ïaŸ¤¶¼›ieD.J}K ¥${=a¨ÆÔ 9ÃàÚ,°MââKÂ@eI„ÉNê€WŸtY†_'Õ~¯[¢{0¿Öl^°Ä%(»øò1C|Xƒ1És¿¼L'””ëRÓ‚º…sÑ­EâÍ»!ïSò:û—<…5/½AµoFßthŒ@úö >âu·l¢â\f–\{ùBMÛ^ø²A6è‹È/>Vlí4>Ş¶Ğ{Š¯h­µ¥ eK¼252“)]`8U7†š†AxOb¾ğ[(…g¨õ%ö½7¡!µ8¸>‹¿‰ú,‹>.;e{¸t;hÉæ¸FĞúù9­ÉÄÕN3ÑÒ"ùYÄŒSŒ³§¨Óøôô§§fWkóâF!Ùœ)¯µÜÏÒ~ò
 WäğæÛîhy…™!–M‹b»<§Ì|×ö*şÕRp§_ÇUÅ\/ÌR”ïÎ5DG¦Ïª?¦Ä}í+1‡7èêéŞmŞK*Ow© ­±Ì¸m+Öb~äjÒÍ9	_<"ÀŸå*ğl®ªúú¸¸»ş-c½óÃ£xœ™1µ¡î=Şu/}4-ˆÒ•{{õäLü:MzV`NÚ”Ğ6]‹jı;îWœs3ŠİïÜ£ƒûÂ»Àùª*/<Ì-äM°ÊƒGJÄ°€üÓãCöâê—×¾÷íÂ÷@¯ênŸÄ%ãí;àÓ_€KÇ?B“ ò©©VQ1N#\‰ö¸áP,;"’x^ßØWA$‡%Ë[šÜ[#oX•˜Hî­|¬?B kÓ!ñ$^ nXÀóá]Vë*ö#E›!¼!`%õC)t‚¢@J­¤z(‚öA(BRïò-kÊ,ø£Ê±4:rDLI•EÓ§–¥BÛ#x b´}×…Ğ†GHuŸş! … ‰_qGA±øhmD(Ñ+¾¨ÛØh%Ñ5Şã¬#Ltï8ˆ#êç=NÃz"|‰úù®ª‡•`ÉĞ¡WÉØdªoõœíbòùÚzÂÏIGrsdqåì™5<0V9rë^Ğ{éú"&‰8È°.*//.)**_,+ÑÉÒƒœjÑÈõ¡Ùv\> İ+ŸÜ9ìÂAõÌXFü.ŞÎ»v‰2f0Ê)÷1¬<œ0¤uÄ/}îvEE9vÇy·Êu1õy¨’c„ˆ¼d³.
ä*pg’ÁDAêÎÖ¦S ãœ¾ö ¬â×^*»XLZ[wëç#°:rn6Õÿ¥Õ+ps B ¦²TÔCİŸÈ× –ª<#\¼"Ï>l‹]ü–Ô¯¹OÙ7Ûİ‰«pßtÚq7oBXîŞÕó0àÖó€t7}‚3¨\ò4äM‹Á|¼*"´u¥VİP¤2"#Aš?™¢mcTñ^Ø…S£i£W—‘8½Zñc}9ÎÄ¾c‚¸Ø[m² ÄÇ$‡û÷9.±
-ÁôëÃ—¹@ĞÖ"W¶rika†aşx|ßœü›R×ˆ„fs	rÿË¦!½>ÁÏ6Éí)¦ÒÙ<ùû5P2Ö¦æ…{æøÄ$'º¥‘ï1X·İLÎ¹iøZ¿ë¦G¿U»—ÿvó¼räŸGüí”(ìİ$×º¡æäšffc’/ÃØ?Y/eI¥TÇ¹k„ÊÛ€i8z&˜:¦Š‘Ğv¦i‚èDüí·u.@RGk#‚İ&ç3GtÆrbÆÆnl„´«ø·ŒÚ•Y4Ò©»6¡ÉZ¼Oaá©¥ÂJÕâö­Ü§X«m0 ­ºZëËìŠWM©`‡ü!³šî6ÛfşÀmş½V0»eÛûíò1+`Yı£íl®Á*aºPF]Ø;¶£©ÅKKIa/ Ê2ñ4rœö!©KVÙë.[‰MÔÊ•½ğ¬r-“¦¹ÃxiOè~@Íƒà°–i	3aşôaTJ…Rx’cBkQFY¯½Ş‘İ¤(s'ÛË‰SËÂñ‹±7o¿èrùà±,(ÙÑ³‚a-Ä|°ÿTWwú¢(n§³Wng¾Îãq¢c#?Å1Xn{—âß¹ëú^lşÚ€fàÀèæÂ/œ½mkÁô–‘(Kd¯şq«®\ê‰yç€kS5€@æ¹ ä¥ûÎ×’¥€şr	h*È3Š‘dÂ¥â×¬‹¡—ÏÃYÉm‡‚L¿v/Ü7JØ
ñUˆìÂÊË!úâí¤@ü‘úA`;™o7šÍÊlºdµ/~ú1÷m,}¿''E¹XH§Ñ8`ÖŸÅ„§Ø+}©`¬³ñH¦ºÓµ­ÚgRäê;k•ÉÙ{[(öÁZç¬êbÆĞÂg¡ŒŠñ…¿lbälY÷ÒE­ë¬ı£·SIi=±.›5°J4ë†½¹P—á/œÌXbàq*—§n¥êí[ÏF.ıÂÀ¿rÂ¾ÔCO–´ŠØİW_³ŒFºßÇµmN–ë»NúÅå3XmbÛ@«y“'Ná“8’KTk­ˆğ·H?oÉ5Rû¾–«êøR~SO^¨¦Çêv ÈÃ0.òcHVËüAy‹ïzÑŒÉrS¨\y;Q é[ï­ËU“”ÎöÊõiì¼Ç««6¹Ü3îÃ8úi¢QãÑGŸ¬£Ÿ8†·P9—½[kÃzÒoüõÂ£Œ}rŒïøÁÕvö[¼ÇukL\?Údµ<ˆ¾ÍUs¥Éw£è¹ÌQy”q‰Qc`2~i¨Ä{Lù£%ËjõÜúŞ¼Hÿ¬1m`êaÎ~Aî¾>ëa
Ÿ|”  €"àÒ%€ $@Ğ× È@'á“4
 Cò
ØP›ÚIé<èd-·jä9%® ß<Î3aĞÌ4 •ØÙêµÙª¶Yî…´õÙøÜÉã« {ˆL—`7í4=•şõ».œc€uâÃÅ±RĞ‚Ï!€‘L; Ù¯”€7‚Ù5±ßÏŠó¯şfşczöî¿m Øè¦.‹
â‚W©Sïcf§GægUYOéí¦L1®ìÚ8eµ¯RÚÉ0»IÁd_]¿š`•ê×	ïU‡¶ó¦\ÁÜ\íŞ\néîí‹gLÊ” ÕŠ;óÜvcŠ{$“æše×-µ±¿ªAB*CbAgAs¨Ìx²Ü·ÊÅ»ìpÇîF?]ºòW.û¥KÅ<EË+¹öu³Ó­!éz„L´n7×î%€A‚d+*ºÃ¯ªä²#öÚï÷,İ.~Ürƒx`âµ6AaF¦écÇÖEÒE‘†e…aÒJÌå9â=İ£ìvN¦i§0µ¢åOªÕ©7Õ†˜˜ ÓL¯¯FW¥5¼ï~ìP’“ëıî Ú\%Êê é²–Ê=ôÕ°¥<åÇ—à=²½•“&ş†¾‚Ô‡Ã›Òü,a>ãí@L^‚Qg3áWXÎó[ĞLT‡ô„ùi=”88ı‚Cï{·”¥ÁeÇ¹å”¡ëeú¸ï!ÓÓ¥ª(Š¦ôõÁíc †§g!Õæèì7î)ó#ßKr.å§†qôá"Ğã²°¼¦ÒV$»{'ñWÁ\:œó!Æ=Ck9oçH.?»¥’ĞsSü'—³?('g	dçĞ?P~^ûìœ—öœg&î?¤CüpvxÂv`€ü_‡†:ûÈÉz
Fóç³—Ÿ‘ÎŞSCş·ÖŸÏ#à9go¦rı3ÄÙJÀxÇùÏkØÏ(gnçcó‘óÖ]ÀÃ$ß_yßæ¸ÿğÿ~SéıÑIËüàÿ‰ËH^ş‹ÿÿÿ*Íÿxü%Ä¿ûı—¸ä÷øKJIı¥ÿú_äÿ«hª+rÿvÿ¦À¾j65RUÿ•E­ÄyõwÁ­º‘™ºÑß¿ÿvô‡8Z_EOıûGccs°‘š7	Éˆ¿kË~ÃøÁ7?G¿Lò;Š"¯Éï0Š¼Ògyú‘g …Ã¢bíÿPißGô¯|ü3Nçş»ıkõú}ÿş:¿ïõ_-èæ÷½¯üĞÙsóşîÄÍèèÇ)pşÚDŸ9‘håŸ®@ô•óÄü¿8ñÙ_ö—ıeÿì¿ å\ P  