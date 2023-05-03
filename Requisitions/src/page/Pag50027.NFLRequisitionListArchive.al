/// <summary>
/// Page NFL Requisition List Archive (ID 50220).
/// </summary>
page 50027 "NFL Requisition List Archive"
{
    // version NFL02.001

    Caption = 'NFL Requisition List Archive';
    CardPageID = "Purchase Requisition Archive";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NFL Requisition Header Archive";
    SourceTableView = WHERE("Document Type" = CONST("Purchase Requisition"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Request-By No."; "Request-By No.")
                {
                    ApplicationArea = All;
                }
                field("Request-By Name"; "Request-By Name")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Posting Description"; "Posting Description")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Archive No."; "Archive No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Version No."; "Version No.")
                {
                    ApplicationArea = All;
                }
                field("Date Archived"; "Date Archived")
                {
                    ApplicationArea = All;
                }
                field("Time Archived"; "Time Archived")
                {
                    ApplicationArea = All;
                }
                field("Archived By"; "Archived By")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
        }
    }
}

