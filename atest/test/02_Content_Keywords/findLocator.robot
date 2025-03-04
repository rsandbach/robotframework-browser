*** Settings ***
Resource        imports.resource

Test Setup      findLocator Setup

*** Test Cases ***
Normal Selector
    Click    css=input#login_button
    Get Text    text=Login failed. Invalid user name and/or password.

Normal With Strict Mode
    Run Keyword And Expect Error
    ...    *Error: strict mode violation: "//button" resolved to 11 elements:*
    ...    Click    //button
    Set Strict Mode    False
    Click    //button
    [Teardown]    Set Strict Mode    True

Frame With Strict Mode
    Go To    ${FRAMES_URL}
    Click    iframe[name="left"] >>> "foo"
    Run Keyword And Expect Error
    ...    *Error: strict mode violation: "//iframe" resolved to 2 elements:*
    ...    Click    //iframe >>> "foo"
    Run Keyword And Expect Error
    ...    *Error: strict mode violation: "//input" resolved to 2 elements:*
    ...    Click    iframe[name="left"] >>> //input
    Set Strict Mode    False
    Click    //iframe >>> "foo"
    Click    iframe[name="left"] >>> //input
    [Teardown]    Set Strict Mode    True

Nested Frame With Strict Mode
    Go To    ${DEEP_FRAMES_URL}
    Click    id=b >>> id=c >>> id=cc
    ${element} =    Get Element    id=b >>> id=c >>> id=cc
    Should Start With    ${element}    element
    ${elements} =    Get Elements    id=b >>> id=c >>> id=cc
    Length Should Be    ${elements}    1

Get Element And Get Elements
    ${element} =    Get Element    input#login_button
    Should Start With    ${element}    element
    ${elements} =    Get Elements    input
    Length Should Be    ${elements}    4
    FOR    ${element}    IN    @{elements}
        Should Start With    ${element}    element

    END

Click With Element ID
    ${element} =    Get Element    //tbody/tr[2]
    Run Keyword And Expect Error
    ...    TimeoutError: locator.click: Timeout 3000ms exceeded.*
    ...    Click    ${element} >> css=input#login_button
    Get Text    text=Login Page
    ${element} =    Get Element    //tbody/tr[3]
    Click    ${element} >> css=input#login_button
    Get Text    text=Login failed. Invalid user name and/or password.

Frames With Element ID
    Go To    ${FRAMES_URL}
    ${element} =    Get Element    iframe[name="left"]
    Run Keyword And Expect Error
    ...    TimeoutError: locator.click: Timeout 3000ms exceeded.*
    ...    Click    ${element} >>> "foo"

Get Element Count In iFrame
    Go To    ${FRAMES_URL}
    Get Element Count    iframe[name="left"] >>> //input    ==    2

Get Element Should Wait For Attached State
    New Page    ${WAIT_URL}
    Select Options By    \#dropdown    value    True    attached
    Click    \#submit    noWaitAfter=True
    ${locator} =    Get Element    id=victim
    Should Not Be Empty    ${locator}

Get Element Should Wait For Attached State
    New Page    ${WAIT_URL}
    Select Options By    \#dropdown    value    True    attached
    Click    \#submit    noWaitAfter=True
    ${locator} =    Get Elements    id=victim
    Should Not Be Empty    ${locator}

*** Keywords ***
findLocator Setup
    Set Browser Timeout    3 seconds
    New Page    ${LOGIN_URL}
