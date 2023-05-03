/// <summary>
/// Page All Purchase Requisitions (ID 50226).
/// </summary>
page 50034 "All Purchase Requisitions"
{
    // version MAG

    Caption = 'List of All Purchase Requisitions';
    CardPageID = "Purchase Requisition Card";
    DataCaptionFields = "Document Type";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    Permissions = TableData "NFL Requisition Header" = rim;
    RefreshOnActivate = true;
    SourceTable = "NFL Requisition Header";
    SourceTableView = WHERE("Document Type" = FILTER("Purchase Requisition"));

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
                field("Request-By Name"; "Request-By Name")
                {
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
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {

                    ApplicationArea = All;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                }
                field("Order Address Code"; "Order Address Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Requestor ID"; "Requestor ID")
                {
                    Caption = 'Registered By';
                    ApplicationArea = All;
                }
                field("Release date"; "Release date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction();
                    begin
                        CASE "Document Type" OF
                            "Document Type"::"HR Cash Voucher":
                                PAGE.RUN(PAGE::"Blanket Purchase Order", Rec);
                            "Document Type"::"Purchase Requisition":
                                PAGE.RUN(PAGE::"Purchase Order", Rec);
                            "Document Type"::"Store Return":
                                PAGE.RUN(PAGE::"Purchase Invoice", Rec);
                            "Document Type"::"Imprest Cash Voucher":
                                PAGE.RUN(PAGE::"Purchase Return Order", Rec);
                            "Document Type"::"Cash Voucher":
                                PAGE.RUN(PAGE::"Purchase Credit Memo", Rec);

                        END;
                    end;
                }
                action("Print PP Form 20")
                {

                    trigger OnAction();
                    var
                        ReqnHeader: Record "NFL Requisition Header";
                        RptPurchaseReqn: Report "Purchase Requisition";
                    begin
                        //TESTFIELD(Status,Status::Released); //HAK20131120
                        ReqnHeader.SETRANGE("Document Type", ReqnHeader."Document Type"::"Purchase Requisition");
                        ReqnHeader.SETRANGE("No.", "No.");
                        RptPurchaseReqn.SETTABLEVIEW(ReqnHeader);
                        RptPurchaseReqn.RUNMODAL;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    var
    // lvNFLApprovalEntry: Record "NFL Approval Entry";
    begin
    end;

    trigger OnOpenPage();
    begin
        SETRANGE("Document Type", "Document Type"::"Purchase Requisition");

        IF UserMgt.GetPurchasesFilter() <> '' THEN BEGIN
            FILTERGROUP(2);
            SETRANGE("Responsibility Center", UserMgt.GetPurchasesFilter());
            FILTERGROUP(0);
        END;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        UserMgt: Codeunit "User Setup Management";
}

