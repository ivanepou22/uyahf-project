/// <summary>
/// Page All Purchase Requisitions (ID 50026).
/// </summary>
page 50026 "All Purchase Requisitions"
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Request-By Name"; Rec."Request-By Name")
                {
                    ApplicationArea = All;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    ApplicationArea = All;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                }
                field("Order Address Code"; Rec."Order Address Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Requestor ID"; Rec."Requestor ID")
                {
                    Caption = 'Registered By';
                    ApplicationArea = All;
                }
                field("Release date"; Rec."Release date")
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
                        CASE Rec."Document Type" OF
                            Rec."Document Type"::"HR Cash Voucher":
                                PAGE.RUN(PAGE::"Blanket Purchase Order", Rec);
                            Rec."Document Type"::"Purchase Requisition":
                                PAGE.RUN(PAGE::"Purchase Order", Rec);
                            Rec."Document Type"::"Store Return":
                                PAGE.RUN(PAGE::"Purchase Invoice", Rec);
                            Rec."Document Type"::"Imprest Cash Voucher":
                                PAGE.RUN(PAGE::"Purchase Return Order", Rec);
                            Rec."Document Type"::"Cash Voucher":
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
                        ReqnHeader.SETRANGE("No.", Rec."No.");
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
        Rec.SETRANGE("Document Type", Rec."Document Type"::"Purchase Requisition");

        IF UserMgt.GetPurchasesFilter() <> '' THEN BEGIN
            Rec.FILTERGROUP(2);
            Rec.SETRANGE("Responsibility Center", UserMgt.GetPurchasesFilter());
            Rec.FILTERGROUP(0);
        END;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        UserMgt: Codeunit "User Setup Management";
}

