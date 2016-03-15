#!/bin/sh

OUT_FILE=out.csv
WORK_DIR=`pwd`/

#S3バケット名入力
S3_PATH=cloudtrail4test/

#認証情報レポートファイルの確認
if [ -e "$WORK_DIR"status_reports*.csv ]; then
	echo "status reports file found."
else
	echo "status reports file NOT found."
fi

#プロファイルの入力
echo  "Please enter a connection profile"
echo  "Input profile:"
read profile

#S3バケットからのログダウンロード
cd "$WORK_DIR"
mkdir "$WORK_DIR"log
case "$profile" in
	[0-9a-zA-Z]* ) aws s3 sync s3://"$S3_PATH"log --profile "$profile" ;;
	* ) aws s3 sync s3://${S3_PATH} log ;;
esac

echo user,eventTime,additionalEventData, > ${OUT_FILE}

find log -name "*.json.gz" | xargs gunzip -c | jq ".Records[]" | \
jq -r '"\(.userName),\(.eventTime),\(.additionalEventData) "' \
| sort -k 1,1 >> ${OUT_FILE}

