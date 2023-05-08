/// <summary>
/// PageExtension OrderProcessor RoleCenter Ext (ID 50014) extends Record Order Processor Role Center.
/// </summary>
pageextension 50003 "OrderProcessor RoleCenter Ext" extends "Order Processor Role Center"
{
    layout
    {
        // Add changes to page layout here

    }

    actions
    {
        // Add changes to page actions here
        addafter("Posted Documents")
        {
            group("Requisition Management")
            {
                group("Purchase Requisition")
                {
                    group(Lists)
                    {
                        action("Purchase Requisition List")
                        {
                            ApplicationArea = All;
                            Caption = 'Purchase Requisition List';
                            RunObject = page "Purchase Requisition List";
                            RunPageView = where(Status = filter(Open | "Pending Approval" | "Pending Prepayment"), Archieved = filter(false));
                            Image = Payables;
                        }
                        action("Approved Purchase Requisitions")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'Approved Purchase Requisitions';
                            RunObject = page "Purchase Requisition List";
                            RunPageView = where(Status = filter(Released), Archieved = filter(false));
                        }
                        action("All Purchase Requisitions")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'All Purchase Requisitions';
                            RunObject = page "All Purchase Requisitions";
                            RunPageView = where(Archieved = filter(false));
                        }
                    }
                    group(Archives)
                    {
                        action("NFL Requisition List Archives")
                        {
                            ApplicationArea = All;
                            Caption = 'NFL Requisition List Archives';
                            Image = Archive;
                            RunObject = page "All Purchase Requisitions";
                            RunPageView = where(Status = filter(Released), Archieved = filter(true));
                        }
                    }

                }
                group("Cash Requisition")
                {
                    group(Lists1)
                    {
                        Caption = 'Lists';
                        action("Cash Vouchers")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'Cash Vouchers';
                            RunObject = page "Cash Vouchers";
                            RunPageView = where(Archieved = filter(false));
                        }
                        action("Pending Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Payt Vouchers Pending Approval";
                            RunPageView = where(Archieved = filter(false));
                        }
                        action("Released Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Released Payment Vouchers";
                            RunPageView = where(Archieved = filter(false));
                        }
                        action("Open Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Open Payment Vouchers";
                            RunPageView = where(Archieved = filter(false));
                        }
                        action("All Payment Vouchers")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "List of All Payment Vouchers";
                            RunPageView = where(Archieved = filter(false));
                        }
                    }
                    group(Archives100)
                    {
                        Caption = 'Archives';
                        action("Archived Payment Vouchers001")
                        {
                            Caption = 'Archived Payment Vouchers';
                            ApplicationArea = All;
                            Image = Archive;
                            RunObject = page "List of All Payment Vouchers";
                            RunPageView = where(Archieved = filter(true));
                        }
                    }
                }
                group(Setup)
                {
                    Caption = 'NFL Setup';
                    action("NFL Setup")
                    {
                        Caption = 'NFL Setup';
                        ApplicationArea = All;
                        // RunObject = page "NFL Setup";
                    }
                }
                group("Main Tasks")
                {
                    action("Generate Bank Payment")
                    {
                        Caption = 'Generate Bank Payment';
                        Image = BankAccountStatement;
                        ApplicationArea = All;
                        RunObject = report "Generate Bank Payment 1";
                    }
                    action("Commitment Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Commitment Ledger Entries';
                        Image = Ledger;
                        RunObject = page "Apply Commitment  Entry";
                    }
                }
            }
        }
    }

    var
        myInt: Integer;
}