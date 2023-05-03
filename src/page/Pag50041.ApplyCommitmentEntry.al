/// <summary>
/// Page Apply Commitment  Entry (ID 50233).
/// </summary>
page 50041 "Apply Commitment  Entry"
{
    // version MAG

    Caption = 'Commitment Ledger Entries';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Commitment Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("SalesPerson Code"; "SalesPerson Code")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("System-Created Entry"; "System-Created Entry")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("G/L Account Name"; "G/L Account Name")
                {
                    DrillDown = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Job No."; "Job No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Advance Code"; "Advance Code")
                {
                    ApplicationArea = All;
                }
                field("Cashier ID"; "Cashier ID")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("IC Partner Code"; "IC Partner Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Gen. Posting Type"; "Gen. Posting Type")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Additional-Currency Amount"; "Additional-Currency Amount")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("VAT Amount"; "VAT Amount")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; "Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Code"; "Source Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Reversed; Reversed)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Reversed by Entry No."; "Reversed by Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Reversed Entry No."; "Reversed Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("FA Entry Type"; "FA Entry Type")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("FA Entry No."; "FA Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
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
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                Image = Entry;
                action(Dimensions)
                {
                    AccessByPermission = TableData 348 = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction();
                    begin
                        ShowDimensions;
                        CurrPage.SAVERECORD;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        FILTERGROUP(2);
        SETRANGE(Reversed, FALSE);
        FILTERGROUP(0);
    end;

    var
        GLAcc: Record "G/L Account";

    /// <summary>
    /// Description for GetCaption.
    /// </summary>
    /// <returns>Return variable "Text[250]".</returns>
    local procedure GetCaption(): Text[250];
    begin
        IF GLAcc."No." <> "G/L Account No." THEN
            IF NOT GLAcc.GET("G/L Account No.") THEN
                IF GETFILTER("G/L Account No.") <> '' THEN
                    IF GLAcc.GET(GETRANGEMIN("G/L Account No.")) THEN;
        EXIT(STRSUBSTNO('%1 %2', GLAcc."No.", GLAcc.Name))
    end;
}

