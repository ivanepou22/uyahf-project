/// <summary>
/// Page NFL Requisition List (ID 50023).
/// </summary>
page 50023 "NFL Requisition List"
{
    // version NFL02.001

    Caption = 'NFL Requisition List';
    DataCaptionFields = "Document Type";
    Editable = false;
    PageType = List;
    SourceTable = "NFL Requisition Header";

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
                field("Request-By No."; Rec."Request-By No.")
                {
                    ApplicationArea = All;
                }
                field("Request-By Name"; Rec."Request-By Name")
                {
                    ApplicationArea = All;
                }
                field("Requestor ID"; Rec."Requestor ID")
                {
                    ApplicationArea = All;
                }
                field("Order Address Code"; Rec."Order Address Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Post Code"; Rec."Pay-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Contact"; Rec."Pay-to Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Visible = false;
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
                    ApplicationArea = All;
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
            }
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
}

