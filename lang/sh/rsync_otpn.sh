#!/bin/sh

# カレントディレクトリとターゲットディレクトリのファイルを比較して変更があれば
# ファイルサイズとphpのシンタックスチェックを行い
# ファイルのコピーを行う

TARGET_DIR=/usr/local/apache
TMP_FILE1=/tmp/__rsync_otpn1.tmp

echo "コピーされるファイルをリストアップします。実際にコピーはまだされません"
rsync -acvn --exclude ".svn" . $TARGET_DIR > $TMP_FILE1
sed -i '1d' $TMP_FILE1
sed -i '$d' $TMP_FILE1
sed -i '$d' $TMP_FILE1
sed -i '$d' $TMP_FILE1
cat $TMP_FILE1

echo ""
echo "ファイルサイズとシンタックスチェックをします"
for i in `cat $TMP_FILE1`
do
  if test ${i} = ""
  then
    break
  fi

#   ls -l ${i}
  if ! test -s ${i}
  then
#     echo "OK	${i}"
#   else
    echo "NG	${i} のファイルサイズが0です"
	echo "終了します"
	rm $TMP_FILE1
	exit
  fi

  res=$(/usr/local/bin/php -l ${i})
  if [ "$res" != "No syntax errors detected in ${i}" ]
  then
    echo "NG	${i} が構文エラーです。phpのファイルならば修正してください"
	echo "  $res"
# phpじゃないファイルもあるのでexitしない
# 	echo "終了します"
# 	rm $TMP_FILE1
# 	exit
  fi
done
echo "チェック完了しました"

echo ""
echo "実際にコピーを実行してもよろしいですか？[y/N]"
read input

if test $input = "y"
then
  rsync -acv --exclude ".svn" . $TARGET_DIR
  echo "完了しました"
else
  echo "中止しました"
fi

rm $TMP_FILE1
