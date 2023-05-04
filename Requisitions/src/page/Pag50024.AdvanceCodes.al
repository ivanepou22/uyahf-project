/// <summary>
/// Page Revision Log (ID 50222).
/// </summary>
page 50024 "Advance Codes"
{
    PageType = List;
    SourceTable = "Staff Advances";

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Bank No."; Rec."Bank No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank No. field.';
                }
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Code field.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Name field.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account No. field.';
                }
                field("Branch Code"; Rec."Branch Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Branch Code field.';
                }
                field("payment Type"; Rec."payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the payment Type field.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field.';
                }
                field(TIN; Rec.TIN)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the TIN field.';
                }
                field("Staff Control Account"; Rec."Staff Control Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Staff Control Account field.';
                }
            }
        }
    }

    actions
    {
    }
}

