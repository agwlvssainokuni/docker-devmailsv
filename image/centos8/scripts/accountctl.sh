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
    echo "Usage: $0 [options] file..." 1>&2
    echo "  -a  TO ADD MAIL ADDR" 1>&2
    echo "  -a  TO DEL MAIL ADDR" 1>&2
    exit $1
}

do_add=false
do_del=false

while getopts adh OPT; do
    case $OPT in
    a) do_add=true;;
    d) do_del=true;;
    h) usage_and_exit 0;;
    \?) usage_and_exit -1;;
    esac
done
shift $((OPTIND - 1))

########################################################################
# 主処理
do_main() {
    grep -v '^#' $1 | sed -e 's/[,:;]/ /g' | while read u p ignore; do
        if [[ $do_add == "true" ]]; then
            useradd -m -s /sbin/nologin $u || exit -1
            (echo $u:$p | chpasswd) || exit -1
        elif [[ $do_del == "true" ]]; then
            userdel -r $u || exit -1
        fi
    done
}

if [[ $# -eq 0 ]]; then
    do_main
else
    for file in $@; do
        do_main ${file}
    done
fi
