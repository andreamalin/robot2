*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Desktop
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the Excel file
    Open the intranet website
    Read orders
    Generate zip
    Close Browser


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel file
    ${secret}    Get Secret    url
    Add text input    input_url    label=CSV url download    placeholder=${secret}[download_url]
    Run dialog

    Download    ${secret}[download_url]    overwrite=True

Close modal
    Wait Until Page Contains Element    css:.modal
    Click Button    css:.btn-dark

Read orders
    ${orders_info}    Read table from CSV    orders.csv    header=True

    FOR    ${order}    IN    @{orders_info}
        Close modal
        Wait Until Element Is Visible    css:#order
        Fill and submit the form for one person    ${order}
    END

Fill and submit the form for one person
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Preview robot
    Wait Until Keyword Succeeds    30 sec    2 sec    Save receipt    ${order}[Order number]

Save receipt
    [Arguments]    ${num_order}
    Click Button    id:order
    Wait Until Element Is Visible    css:#receipt
    ${html_content_as_string}    Get Element Attribute    css:#receipt    outerHTML
    Html To Pdf    ${html_content_as_string}    ${OUTPUT_DIR}${/}receipts/receipt.pdf
    ${files}    Create List
    ...    ${OUTPUT_DIR}${/}receipts/receipt.pdf
    ...    ${OUTPUT_DIR}${/}receipts/robot_preview.png
    Add Files To Pdf
    ...    ${files}
    ...    ${OUTPUT_DIR}${/}receipts/receipt_${num_order}.pdf
    Click Button    id:order-another

Preview robot
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}receipts/robot_preview.png

Generate zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts/compressed_receipts.zip
