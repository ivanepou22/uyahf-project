// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

/// <summary>
/// PageExtension UserSetup (ID 50100) extends Record User setup.
/// </summary>
/// //50270
pageextension 50000 "UserSetup" extends "User setup"
{
    layout
    {
        addafter(PhoneNo)
        {
            field("Budget Controller"; Rec."Budget Controller")
            {
                ApplicationArea = All;
            }
            field("Voucher Admin"; Rec."Voucher Admin")
            {
                ApplicationArea = All;
            }
            field("Archive Document"; Rec."Archive Document")
            {
                ApplicationArea = All;
            }

        }

    }
}