# Splunk Dashboard

### Overview ###

This file consists of Splunk Search Strings to build GuardDuty dashboard in Splunk.

<<<<<<< HEAD
#### Splunk Dashboard Inputs ####
Format of below lines 'DashBoard Name :- Splunk Search String'
=======
#### Inputs ####
>>>>>>> f138ee47685bde1548ccab0d6c56145deea60705

```
Top 10 Event Types :- sourcetype="<SPLUNK SOURCE TYPE>" | top 10 "detail.type"

Top 10 Port Porbe Unprotected Ports :- sourcetype="<SPLUNK SOURCE TYPE>"   "detail.type"="Recon:EC2/PortProbeUnprotectedPort" | top 10 detail.service.action.portProbeAction.portProbeDetails{}.localPortDetails.port | rename "detail.service.action.portProbeAction.portProbeDetails{}.localPortDetails.port" AS "Port"

Top 10 Findings :- sourcetype="" | top 10 "detail.id" | rename "detail.id" AS "FindingID"

Top 10 Recon:Malicious IP calling AWS API :- sourcetype="<SPLUNK SOURCE TYPE>"   "detail.type"="Recon:IAMUser/MaliciousIPCaller" "detail.service.action.awsApiCallAction.remoteIpDetails.ipAddressV4"  != "< COMPANY IP OR KNOWN IP>" | top 10 detail.service.action.awsApiCallAction.remoteIpDetails.ipAddressV4 | rename "detail.service.action.awsApiCallAction.remoteIpDetails.ipAddressV4" AS "MaliciousIP"

Top 10 Backdoor EC2/XORDDOS :- sourcetype="<SPLUNK SOURCE TYPE>"  "detail.type"="Backdoor:EC2/XORDDOS" "detail.service.action.networkConnectionAction.remoteIpDetails.ipAddressV4" != "< COMPANY IP OR KNOWN IP>" | top 10 "detail.service.action.networkConnectionAction.remoteIpDetails.ipAddressV4" | rename "detail.service.action.networkConnectionAction.remoteIpDetails.ipAddressV4" AS "ipAddressV4"

High Severity Event Types (Severity > 7) :- sourcetype="<SPLUNK SOURCE TYPE>"  "detail.severity" >= 7  | top 0 "detail.type"

SSHBruteForce Events :- sourcetype="<SPLUNK SOURCE TYPE>"  "detail.type"="UnauthorizedAccess:EC2/SSHBruteForce" | top 0 "detail.service.action.networkConnectionAction.remoteIpDetails.ipAddressV4" | regex "detail.service.action.networkConnectionAction.remoteIpDetails.ipAddressV4" != "(^10\..*)"

Instances Port(s) other than 80,443 open to world :- sourcetype="<SPLUNK SOURCE TYPE>"  "detail.type"="Recon:EC2/PortProbeUnprotectedPort" ("detail.service.action.portProbeAction.portProbeDetails{}.localPortDetails.port" !=80 AND "detail.service.action.portProbeAction.portProbeDetails{}.localPortDetails.port" !=443)  |stats values(detail.service.action.portProbeAction.portProbeDetails{}.localPortDetails.port) AS PortList BY detail.resource.instanceDetails.instanceId


```
