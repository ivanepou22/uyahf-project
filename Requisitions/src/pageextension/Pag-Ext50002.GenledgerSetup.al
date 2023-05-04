/// <summary>
/// PageExtension GenledgerSetup (ID 50102) extends Record General Ledger Setup.
/// </summary>
pageextension 50002 "GenledgerSetup" extends "General Ledger Setup"
{
    layout
    {
        addafter(Reporting)
        {
            group(Commitment)
            {
                field("Approved Budget"; Rec."Approved Budget")
                {
                    ApplicationArea = All;
                }
                field("Commitments Budget"; Rec."Commitments Budget")
                {
                    ApplicationArea = All;
                }
                field("Activate Commitments Control"; Rec."Activate Commitments Control")
                {
                    ApplicationArea = All;
                }
            }
        }
        addafter(Application)
        {
            group("Payment Voucher")
            {
                Caption = 'Payment Voucher';
                field("WHT Account"; Rec."WHT Account")
                {
                    Caption = 'WHT Account';
                }
                field("WHT Percentage - Foreign"; Rec."WHT Percentage - Foreign")
                {
                    Caption = 'Foreign WHT Percentage';
                }
                field("WHT Pecentage"; Rec."WHT Pecentage")
                {
                    Caption = 'Domestic WHT Pecentage';
                }
                field("Foreign VAT Account No."; Rec."Foreign VAT Account No.")
                {
                    Caption = 'Foreign VAT Account No.';
                }
                field("Approved Payments Batch"; Rec."Approved Payments Batch")
                {
                }
                field("Approved Payments Template"; Rec."Approved Payments Template")
                {
                }
                field("Edit Status"; Rec."Edit Status")
                {
                    ToolTip = 'Specifies the value of the Edit Status field';
                    ApplicationArea = All;
                }
            }
            group("Journal Voucher")
            {
                Caption = 'Journal Voucher';
                Visible = false;
                field("Approved JV Batch"; Rec."Approved JV Batch")
                {
                }
                field("Approved JV Template"; Rec."Approved JV Template")
                {
                }
            }

            group("Requisition Setup")
            {

                field("Store Requisition Nos"; Rec."Store Requisition Nos")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Requisition Nos field.';
                }
                field("Purchase Requisition Nos"; Rec."Purchase Requisition Nos")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Requisition Nos. field.';
                }
                field("Archive Purch. Requisition"; Rec."Archive Purch. Requisition")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive Purch. Requisition field.';
                }
                field("Archive Store Requisition"; Rec."Archive Store Requisition")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive Store Requisition field.';
                }
                field("Store Req Item Jnl Template"; Rec."Store Req Item Jnl Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Req Item Jnl Template field.';
                }
                field("Store Return Item Jnl Batch"; Rec."Store Return Item Jnl Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Return Item Jnl Batch field.';
                }
                field("Store Req. Archive No. Series"; Rec."Store Req. Archive No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Req. Archive No. Series field.';
                }
                field("Store Return Archive No series"; Rec."Store Return Archive No series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Return Archive No series field.';
                }
                field("Store Return Item Jnl Template"; Rec."Store Return Item Jnl Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Return Item Jnl Template field.';
                }
            }
        }
    }


    actions
    {
    }
}