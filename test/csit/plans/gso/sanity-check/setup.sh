#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Place the scripts in run order:
# Start all process required for executing test case

source ${SCRIPTS}/common_functions.sh

# Start MSB
${SCRIPTS}/common-services-microservice-bus/startup.sh i-msb
MSB_IP=`get-instance-ip.sh i-msb`
curl_path='http://'${MSB_IP}'/openoui/microservices/index.html'
sleep_msg="Waiting_connection_for_url_for:i-msb"
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' GREP_STRING="org_openo_msb_route_title" REPEAT_NUMBER="15"

# Start Inventory
run-instance.sh openoint/common-tosca-inventory inventory " -i -t -e MSB_ADDR=${MSB_IP}:80"
INV_ADDR=`get-instance-ip.sh inventory`
sleep 8

# Start servicegateway
run-instance.sh openoint/gso-service-gateway gso-sgw " -i -t -e MSB_ADDR=${MSB_IP}:80"
sleep_msg="Waiting_for_gso-sgw"
curl_path='http://'${MSB_IP}':80/openoapi/servicegateway/v1/domains'
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=15 GREP_STRING="\["

#Start gso
run-instance.sh openoint/gso-service-manager gso " -i -t -e MSB_ADDR=${MSB_IP}:80 -e MYSQL_ADDR=${INV_ADDR}:3306"
sleep_msg="Waiting_for_gso-sgw"
curl_path='http://'${MSB_IP}':80/openoapi/gso/v1/services'
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=25 GREP_STRING="\["

echo SCRIPTS
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP}  -v SCRIPTS:${SCRIPTS}"

#18009 is using by simulator, if already a simulator running using port 18009 ,stop it
docker ps | grep '18009' | awk '{print $1}' | xargs --no-run-if-empty docker kill
docker ps | grep '18009' | awk '{print $1}' | xargs --no-run-if-empty docker rm
#run simulator
docker run -d -i -t --name gso_csit_simulator -e SIMULATOR_JSON=Stubs/testcase/gso/main.json -p 18009:18009 -p 18008:18008  openoint/simulate-test-docker
SIMULATOR_IP=`get-instance-ip.sh gso_csit_simulator`
sleep_msg="Waiting_for_simulator"
curl_path='http://'${SIMULATOR_IP}':18009/openoapi/extsys/v1/vims'
wait_curl_driver CURL_COMMAND=$curl_path WAIT_MESSAGE='"$sleep_msg"' REPEAT_NUMBER=15 GREP_STRING="\["


ROBOT_VARIABLES="-v MSB_IP:${MSB_IP}  -v SCRIPTS:${SCRIPTS}  -v SIMULATOR_IP:${SIMULATOR_IP}"
robot ${ROBOT_VARIABLES} ${SCRIPTS}/../tests/gso/sanity-check/register_simulator_to_msb.robot
