#!/usr/bin/env bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

####
## NOTE: For downloading Llama 3.1 please refer to https://github.com/meta-llama/llama-models/tree/main/models/llama3_1#download
####

set -e

#read -p "Enter the URL from email: " PRESIGNED_URL
#echo ""
#read -p "Enter the list of models to download without spaces (8B,8B-instruct,70B,70B-instruct), or press Enter for all: " MODEL_SIZE
PRESIGNED_URL="https://download6.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoiaXNzcXZjODI2Z3gwY3J2d3cyNGdwYnprIiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQ2LmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MjM0ODE5NjB9fX1dfQ__&Signature=Kc74A7B08o34VTf3TzLOAvh6IOPrk9XSr5O9JnTTeRuU9eWIOUirMOI%7ECFKbdUoQl92PQkuKuCEEn57bL%7EHKSBkihiUX3Ek0s1ywzM7Hns-SZh2KiC0%7Eqbrl%7EmutPRsrOrxk9RMr-%7EL7pH9dR1ddfbQS0fsPALqBop0SofNGOqSue00YLWghUfwdYZxDdmgT4GOOcx3B2R15MlVJvtSQZJfGbRnm6Hd5X6-MySL%7ElPPj1n7yaOTHZZrmyRBSifHrKofyv7LMVajuqMigpBpThRByBgscfm3CFgOzDDDRy1ynS-K9HY4xaeUE4%7EUfdisDxJo%7EP29lDf5VE4DZ9aXoHw__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=427406383664175"
MODEL_SIZE="8b-instruct"
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE="8B,8B-instruct,70B,70B-instruct"
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget --continue ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget --continue ${PRESIGNED_URL/'*'/"USE_POLICY"} -O ${TARGET_FOLDER}"/USE_POLICY"

for m in ${MODEL_SIZE//,/ }
do
    if [[ $m == "8B" ]] || [[ $m == "8b" ]]; then
        SHARD=0
        MODEL_FOLDER_PATH="Meta-Llama-3-8B"
        MODEL_PATH="8b_pre_trained"
    elif [[ $m == "8B-instruct" ]] || [[ $m == "8b-instruct" ]] || [[ $m == "8b-Instruct" ]] || [[ $m == "8B-Instruct" ]]; then
        SHARD=0
        MODEL_FOLDER_PATH="Meta-Llama-3-8B-Instruct"
        MODEL_PATH="8b_instruction_tuned"
    elif [[ $m == "70B" ]] || [[ $m == "70b" ]]; then
        SHARD=7
        MODEL_FOLDER_PATH="Meta-Llama-3-70B"
        MODEL_PATH="70b_pre_trained"
    elif [[ $m == "70B-instruct" ]] || [[ $m == "70b-instruct" ]] || [[ $m == "70b-Instruct" ]] || [[ $m == "70B-Instruct" ]]; then
        SHARD=7
        MODEL_FOLDER_PATH="Meta-Llama-3-70B-Instruct"
        MODEL_PATH="70b_instruction_tuned"
    fi

    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/consolidated.${s}.pth"
    done

    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/params.json"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/tokenizer.model"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}/checklist.chk"
    echo "Checking checksums"
    CPU_ARCH=$(uname -m)
    if [[ "$CPU_ARCH" == "arm64" ]]; then
      (cd ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}" && md5 checklist.chk)
    else
      (cd ${TARGET_FOLDER}"/${MODEL_FOLDER_PATH}" && md5sum -c checklist.chk)
    fi
done