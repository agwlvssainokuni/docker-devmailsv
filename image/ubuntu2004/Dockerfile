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

FROM ubuntu:20.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        supervisor rsyslog openssh-server \
        postfix dovecot-imapd dovecot-pop3d mailutils \
    && systemctl disable supervisor.service \
    && systemctl disable rsyslog.service \
    && systemctl disable ssh.service \
    && systemctl disable postfix.service \
    && systemctl disable dovecot.service

COPY *.sh /
COPY scripts/*.sh /opt/

EXPOSE 22 25 465 587 993 995

CMD ["/docker-entrypoint.sh"]
