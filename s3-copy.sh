#!/usr/bin/env bash
set -e
if [ ! -d rclone-v1.65.0-linux-amd64 ]
then
  curl -LO https://downloads.rclone.org/v1.65.0/rclone-v1.65.0-linux-amd64.zip
  unzip rclone-v1.65.0-linux-amd64.zip
  rm rclone-v1.65.0-linux-amd64.zip
fi

read -p "S3 bucket name to sync: " s3_bucket
read -p "VK bucket name to sync: " vk_bucket

if [ ! -f ~/.config/rclone/rclone.conf ]
then
 echo 'insert credentials'
 read -sp "S3 access_key_id: " s3_access_key_id 
 read -sp "S3 secret_access_key: " s3_secret_access_key
 read -p "S3 region (like: eu-central-1): " s3_region     #comment if you use to same in line 11

 read -sp "VK access_key_id: " vk_access_key_id
 read -sp "VK secret_access_key: " vk_secret_access_key
 read -p "VK endpoint (like: https://example.com): " vk_endpoint


cat <<- EOF > ~/.config/rclone/rclone.conf
[s3]
type = s3
provider = AWS
access_key_id = $s3_access_key_id
secret_access_key = $s3_secret_access_key
region = $s3_region
location_constraint = $s3_region
acl = private
server_side_encryption = AES256

[vk]
type = s3
provider = Other
access_key_id = $vk_access_key_id
secret_access_key = $vk_secret_access_key
endpoint = $vk_endpoint
acl = private
EOF
fi

rclone mkdir s3:$s3_bucket 

read -p "Type copy: VK -> S3 = 1   S3 -> VK = 2 : " type_sync

if [[ type_sync -eq 1 ]]
then
 echo "--------Start Sync---------"
 ./rclone-v1.65.0-linux-amd64/rclone copy vk:$vk_bucket s3:$s3_bucket -v --ignore-existing
 echo "-----------DONE------------"
elif [[ type_sync -eq 2 ]]
then
 echo "--------Start Sync---------"
 ./rclone-v1.65.0-linux-amd64/rclone copy s3:$s3_bucket vk:$vk_bucket -v --ignore-existing
 echo "-----------DONE------------"
else
 echo "bad choys"
fi

#Clean
#rm -rf rclone-v1.65.0-linux-amd64    #delete rclone folder
#rm ~/.config/rclone/rclone.conf      #delete rclone config
