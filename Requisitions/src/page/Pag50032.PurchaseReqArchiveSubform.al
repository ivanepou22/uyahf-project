/// <summary>
/// Page Purchase Req Archive Subform (ID 50224).
/// </summary>
page 50032 "Purchase Req Archive Subform"
{
    Caption = 'Purchase Req Archive Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NFL Requisition Line Archive";
    SourceTableView = WHERE("Document Type" = FILTER("Purchase Requisition"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field(Nonstock; Nonstock)
                {
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field(Quantity; Quantity)
                {
                    BlankZero = true;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    Visible = false;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    BlankZero = true;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    Visible = false;
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                    Visible = false;
                }
                field("Unit Price (LCY)"; "Unit Price (LCY)")
                {
                    Visible = false;
                }
                field("Line Amount"; "Line Amount")
                {
                    BlankZero = true;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    BlankZero = true;
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    Visible = false;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    Visible = false;
                }
                field("Allow Item Charge Assignment"; "Allow Item Charge Assignment")
                {
                    Visible = false;
                }
                field("Job No."; "Job No.")
                {
                    Visible = false;
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    Visible = false;
                }
                field("Blanket Order No."; "Blanket Order No.")
                {
                    Visible = false;
                }
                field("Blanket Order Line No."; "Blanket Order Line No.")
                {
                    Visible = false;
                }
                field("Appl.-to Item Entry"; "Appl.-to Item Entry")
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
                field("Budget Amount as at Date"; "Budget Amount as at Date")
                {
                }
                field("Budget Amount for the Year"; "Budget Amount for the Year")
                {
                }
                field("Actual Amount as at Date"; "Actual Amount as at Date")
                {
                }
                field("Actual Amount for the Year"; "Actual Amount for the Year")
                {
                }
                field("Commitment Amount as at Date"; "Commitment Amount as at Date")
                {
                }
                field("Commitment Amount for the Year"; "Commitment Amount for the Year")
                {
                }
                field("Balance on Budget as at Date"; "Balance on Budget as at Date")
                {
                }
                field("Balance on Budget for the Year"; "Balance on Budget for the Year")
                {
                }
                field("Budget Comment as at Date"; "Budget Comment as at Date")
                {
                }
                field("Budget Comment for the Year"; "Budget Comment for the Year")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction();
                    begin
                        //This functionality was copied from page #51406302. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLinesArchive.PAGE.*/
                        _ShowDimensions;

                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction();
                    begin
                        //This functionality was copied from page #51406302. Unsupported part was commented. Please check it.
                        /*CurrPage.PurchLinesArchive.PAGE.*/
                        _ShowLineComments;

                    end;
                }
            }
        }
    }

    procedure _ShowDimensions();
    begin
        Rec.ShowDimensions;
    end;

    procedure ShowDimensions();
    begin
        Rec.ShowDimensions;
    end;

    procedure _ShowLineComments();
    begin
        Rec.ShowLineComments;
    end;

    procedure ShowLineComments();
    begin
        Rec.ShowLineComments;
    end;
}

