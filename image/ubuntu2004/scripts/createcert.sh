#!/bin/bash
# -*- coding: utf-8 -*-
#
#  Copyright 2020,2021 agwlvssainokuni
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

########################################################################
# コマンドラインオプション解析
usage_and_exit() {
    echo "Usage: $0 [options]" 1>&2
    echo "  -n  CERT FILE NAME (default: devmailsv)" 1>&2
    echo "  -c  COMMON NAME (default: devmailsv)" 1>&2
    echo "  -o  ORGANIZATION UNIT (default: devmailsv)" 1>&2
    echo "  -k  KEY LENGTH (default: 4096)" 1>&2
    echo "  -d  DAYS (default: 3650)" 1>&2
    exit $1
}

CERT_NAME=devmailsv
CERT_CN=devmailsv
CERT_OU=devmailsv
CERT_KEYLEN=4096
CERT_DAYS=3650

while getopts n:c:o:k:d:h OPT; do
    case $OPT in
    n) CERT_NAME=${OPTARG};;
    c) CERT_CN=${OPTARG};;
    o) CERT_OU=${OPTARG};;
    k) CERT_KEYLEN=${OPTARG};;
    d) CERT_DAYS=${OPTARG};;
    h) usage_and_exit 0;;
    \?) usage_and_exit -1;;
    esac
done
shift $((OPTIND - 1))

########################################################################
# 主処理
openssl req -x509 -outform PEM -keyform PEM \
    -out ${CERT_NAME}-cert.pem \
    -keyout ${CERT_NAME}-key.pem \
    -subj "/OU=${CERT_OU}/CN=${CERT_CN}" -nodes \
    -newkey rsa:${CERT_KEYLEN} -days ${CERT_DAYS}
