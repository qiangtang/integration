*** Settings ***
Library           RequestsLibrary
Library           Collections
Resource          RuleAddr.robot
Resource          ../CommonKeywords/HttpRequest.robot

*** Keywords ***
ruleMgtSuiteVariable
    ${RULEDIC}    create dictionary    rulename=gy2017001    description=create a new rule!    content=package rule2017001    enabled=1
    set suite variable    ${RULEDIC}

queryConditionRule
    [Arguments]    ${queryParam}    ${codeFlag}=1
    [Documentation]    ${queryParam} : The data type is Json .
    create session    microservices    ${ruleMgtHost}
    ${param}    set variable    queryrequest\=${queryParam}
    ${headers}    set variable
    ${getResponse}    get request    microservices    ${ruleMgtUrl}    ${headers}    ${param}
    run keyword if    ${codeFlag}==1    Should be equal as strings    ${getResponse.status_code}    200
    run keyword if    ${codeFlag}!=1    Should be equal as strings    ${getResponse.status_code}    499
    [Return]    ${getResponse}

traversalRuleAttribute
    [Arguments]    ${responseJsonData}    ${expectAttrDic}
    [Documentation]    ${expectAttrDic} : The data type is dictionary;
    ...    key is the name of the attribute, value is the expected value of the attribute.
    @{responseRules}    Get From Dictionary    ${responseJsonData}    rules
    : FOR    ${rule}    IN    @{responseRules}
    \    log    ${rule}
    \    verifyRuleAttribute    ${rule}    ${expectAttrDic}

verifyRuleAttribute
    [Arguments]    ${singleRule}    ${expectAttrDic}
    [Documentation]    ${expectAttrDic} : The data type is dictionary; key is the name of the attributes to be traversaled, value is the expected value of the attributes.
    log    ${singleRule}
    log    ${expectAttrDic}
    @{attrsKeys}    get dictionary keys    ${expectAttrDic}
    : FOR    ${attr}    IN    @{attrsKeys}
    \    log    ${attr}
    \    ${actualResponse}    get from dictionary    ${singleRule}    ${attr}
    \    ${expectResponse}    get from dictionary    ${expectAttrDic}    ${attr}
    \    Comment    log    ${actualResponse}
    \    Comment    log    ${expectResponse}
    Should be equal as strings    ${actualResponse}    ${expectResponse}

createRule
    [Arguments]    ${jsonParams}    ${codeFlag}=1
    [Documentation]    ${codeFlag} : The data type is string, defult value is 1, indicating that the case need to assert thatthe statues code is 200.
    ...    Then other values indicating that the case need to assert that the statues code is 499.
    ${response}    httpPut    ${ruleMgtHost}    ${ruleMgtUrl}    ${jsonParams}
    run keyword if    ${codeFlag}==1    Should be equal as strings    ${response.status_code}    200
    run keyword if    ${codeFlag}!=1    Should be equal as strings    ${response.status_code}    499
    [Return]    ${response}

modifyRule
    [Arguments]    ${jsonParams}    ${codeFlag}=1
    ${response}    httpPost    ${ruleMgtHost}    ${ruleMgtUrl}    ${jsonParams}
    run keyword if    ${codeFlag}==1    Should be equal as strings    ${response.status_code}    200
    run keyword if    ${codeFlag}!=1    Should be equal as strings    ${response.status_code}    499
    [Return]    ${response}

deleteRule
    [Arguments]    ${jsonParam}    ${codeFlag}=1
    ${response}    httpDelete    ${ruleMgtHost}    ${ruleMgtUrl}    ${jsonParam}
    run keyword if    ${codeFlag}==1    Should be equal as strings    ${response.status_code}    200
    run keyword if    ${codeFlag}!=1    Should be equal as strings    ${response.status_code}    499
    [Return]    ${response}
