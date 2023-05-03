/// <summary>
/// Page NFL Requisition List (ID 50221).
/// </summary>
page 50028 "NFL Requisition List"
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
                field("No."; "No.")
                {
                }
                field("Request-By No."; "Request-By No.")
                {
                }
                field("Request-By Name"; "Request-By Name")
                {
                }
                field("Requestor ID"; "Requestor ID")
                {
                }
                field("Order Address Code"; "Order Address Code")
                {
                    Visible = false;
                }
                field("Buy-from Post Code"; "Buy-from Post Code")
                {
                    Visible = false;
                }
                field("Buy-from Country/Region Code"; "Buy-from Country/Region Code")
                {
                    Visible = false;
                }
                field("Buy-from Contact"; "Buy-from Contact")
                {
                    Visible = false;
                }
                field("Pay-to Vendor No."; "Pay-to Vendor No.")
                {
                    Visible = false;
                }
                field("Pay-to Name"; "Pay-to Name")
                {
                    Visible = false;
                }
                field("Pay-to Post Code"; "Pay-to Post Code")
                {
                    Visible = false;
                }
                field("Pay-to Country/Region Code"; "Pay-to Country/Region Code")
                {
                    Visible = false;
                }
                field("Pay-to Contact"; "Pay-to Contact")
                {
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    Visible = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    Visible = false;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    Visible = false;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    Visible = false;

                }
                field("Location Code"; "Location Code")
                {
                    Visible = true;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    Visible = false;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                }
                field("Currency Code"; "Currency Code")
                {
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
            }
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
}

