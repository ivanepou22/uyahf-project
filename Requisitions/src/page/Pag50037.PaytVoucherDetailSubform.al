/// <summary>
/// Page Payt Voucher Detail Subform (ID 50229).
/// </summary>
page 50037 "Payt Voucher Detail Subform"
{
    // version MAG

    AutoSplitKey = true;
    Caption = 'Payt Voucher Detail Subform';
    PageType = ListPart;
    SourceTable = "Payt Voucher Detail Archieve";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Details; Details)
                {
                }
                field(Amount; Amount)
                {
                }
            }
        }
    }

    actions
    {
    }
}

