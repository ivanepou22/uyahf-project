/// <summary>
/// Page Purchase Requisition Archive (ID 50223).
/// </summary>
page 50031 "Purchase Requisition Archive"
{
    Caption = 'Purchase Requisition Archive';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "NFL Requisition Header Archive";
    SourceTableView = WHERE("Document Type" = CONST("Purchase Requisition"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field("No."; "No.")
                {
                }
                field("Request-By No."; "Request-By No.")
                {
                }
                field("Request-By Name"; "Request-By Name")
                {
                }
                field("Store Requisition No."; "Store Requisition No.")
                {
                }
                field("Created Quotes"; "Created Quotes")
                {
                    Editable = false;
                }
                field("Order Date"; "Order Date")
                {
                }
                field("Document Date"; "Document Date")
                {
                }
                field("Requested Receipt Date"; "Requested Receipt Date")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                }
                field(Status; Status)
                {
                }
            }
            part(PurchLinesArchive; "Purchase Req Archive Subform")
            {
                Editable = false;
                SubPageLink = "Document No." = FIELD("No.");
            }
            group(Version)
            {
                Caption = 'Version';
                Editable = false;
                field("Version No."; "Version No.")
                {
                }
                field("Archived By"; "Archived By")
                {
                }
                field("Date Archived"; "Date Archived")
                {
                }
                field("Time Archived"; "Time Archived")
                {
                }
                field("Interaction Exist"; "Interaction Exist")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ver&sion")
            {
                Caption = 'Ver&sion';
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Vendor Card";
                    RunPageLink = "No." = FIELD("Buy-from Vendor No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Purch. Archive Comment Sheet";
                    RunPageLink = "No." = FIELD("No."),
                                  "Document Line No." = CONST(0),
                                  "Doc. No. Occurrence" = FIELD("Doc. No. Occurrence"),
                                  "Version No." = FIELD("Version No."),
                    "Document Type" = CONST(Order);
                }
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        NFLRequisitionHeaderArchive: Record "NFL Requisition Header Archive";
                        PurchaseRequisitionArchive: Report "Purchase Requisition Archive";
                    begin
                        CLEAR(NFLRequisitionHeaderArchive);
                        CLEAR(PurchaseRequisitionArchive);
                        NFLRequisitionHeaderArchive.SETRANGE("No.", "No.");
                        NFLRequisitionHeaderArchive.SETRANGE("Archive No.", "Archive No.");
                        NFLRequisitionHeaderArchive.SETRANGE("Document Type", "Document Type"::"Purchase Requisition");
                        NFLRequisitionHeaderArchive.SETRANGE("Doc. No. Occurrence", "Doc. No. Occurrence");
                        NFLRequisitionHeaderArchive.SETRANGE("Version No.", "Version No.");
                        NFLRequisitionHeaderArchive.FINDFIRST;
                        REPORT.RUN(50034, TRUE, TRUE, NFLRequisitionHeaderArchive);

                    end;
                }
                separator("...")
                {
                }
                action("Revision Log")
                {
                    Caption = 'Revision Log';

                    trigger OnAction();
                    var
                        lvChangeLogEntry: Record "Change Log Entry";
                        DateTimeArchived: DateTime;
                        lvfrmRevLog: Page "Revision Log";
                    begin
                        lvChangeLogEntry.RESET;
                        lvChangeLogEntry.SETCURRENTKEY(lvChangeLogEntry."Date and Time");
                        // lvChangeLogEntry.SETFILTER(lvChangeLogEntry."Table No.", '%1|%2', DATABASE::Table51406290,  IE
                        // DATABASE::Table51406291);
                        lvChangeLogEntry.SETFILTER(lvChangeLogEntry."Primary Key Field 1 Value", '%1', 'Purchase Requisition');
                        lvChangeLogEntry.SETFILTER(lvChangeLogEntry."Primary Key Field 2 Value", "No.");

                        //filter by chaanges before the archiving
                        DateTimeArchived := CREATEDATETIME("Date Archived", "Time Archived");
                        lvChangeLogEntry.SETFILTER(lvChangeLogEntry."Date and Time", '<%1', DateTimeArchived);
                        lvfrmRevLog.SETTABLEVIEW(lvChangeLogEntry);
                        lvfrmRevLog.RUNMODAL;
                    end;
                }
                action("Print Form 5")
                {
                    Image = Archive;
                    Promoted = true;

                    trigger OnAction();
                    begin
                        ReqnHeader.SETRANGE("Document Type", ReqnHeader."Document Type"::"Purchase Requisition");
                        ReqnHeader.SETRANGE("No.", "No.");
                        Rept.SETTABLEVIEW(ReqnHeader);
                        Rept.RUNMODAL;
                        CLEAR(Rept);
                    end;
                }
            }
        }
    }

    var
        DocPrint: Codeunit "Document-Print";
        RptPurchaseReqnArch: Report "Purchase Requisition Archive";
        Rept: Report "Form 5 Archive";
        ReqnHeader: Record "NFL Requisition Header Archive";
}

