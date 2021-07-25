SIZE="$1"
NAME="$2"
if [ -z "$SIZE" ]
then
      echo "raf - create random files with size and md5 sum in file name"
      echo "Usage: raf <size> [name]"
      exit
fi
TARGET=$(mktemp)
head -c $SIZE </dev/urandom >"$TARGET"
md5=($(md5sum "$TARGET"))
echo "File successfully created"
echo "MD5-Hash: $md5"

if [ -z "$NAME" ]
then
	mv "$TARGET" "./$SIZE-$md5"
else
	mv "$TARGET" "$NAME"
fi


