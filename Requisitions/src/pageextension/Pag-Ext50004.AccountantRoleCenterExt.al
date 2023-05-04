/// <summary>
/// PageExtension Accountant Role Center Ext (ID 50104) extends Record Accountant Role Center.
/// </summary>
pageextension 50004 "Accountant Role Center Ext" extends "Accountant Role Center"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("Cash Management")
        {
            group("Requisition Management")
            {
                group("Purchase Requisition")
                {
                    group(Lists3)
                    {
                        Caption = 'Lists';
                        action("Purchase Requisition List")
                        {
                            ApplicationArea = All;
                            Caption = 'Purchase Requisition List';
                            RunObject = page "Purchase Requisition List";
                            RunPageView = where(Status = filter(Open | "Pending Approval" | "Pending Prepayment"));
                            Image = Payables;
                        }
                        action("Pending Approvals Purchase Requisition")
                        {
                            ApplicationArea = All;
                            Caption = 'Pending Approvals Purchase Requisition';
                            RunObject = page "Purchase Requisition List";
                            RunPageView = where(Status = filter("Pending Approval" | "Pending Prepayment"));
                            Image = Payables;
                        }
                        action("Approved Purchase Requisitions")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'Approved Purchase Requisitions';
                            RunObject = page "Purchase Requisition List";
                            RunPageView = where(Status = filter(Released));
                        }
                        action("All Purchase Requisitions")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'All Purchase Requisitions';
                            RunObject = page "All Purchase Requisitions";
                        }
                    }
                    group(Archives12)
                    {
                        Caption = 'Archives';
                        action("NFL Requisition List Archives")
                        {
                            ApplicationArea = All;
                            Caption = 'NFL Requisition List Archives';
                            Image = Archive;
                            // RunObject = page "NFL Requisition List Archive";
                        }
                    }

                }
                group("Cash Requisition")
                {
                    group(Lists2)
                    {
                        Caption = 'Lists';
                        action("Cash Vouchers")
                        {
                            ApplicationArea = All;
                            Image = Approvals;
                            Caption = 'Cash Vouchers';
                            RunObject = page "Cash Vouchers";
                        }
                        action("Pending Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Payt Vouchers Pending Approval";
                        }
                        action("Released Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Released Payment Vouchers";
                        }
                        action("Open Vouchers Approval")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "Open Payment Vouchers";
                        }
                        action("All Payment Vouchers")
                        {
                            ApplicationArea = All;
                            Image = HRSetup;
                            RunObject = page "List of All Payment Vouchers";
                        }
                    }
                    group(Tasks3)
                    {
                        Caption = 'Tasks';
                        action("Generate Bank Payment")
                        {
                            Caption = 'Generate Bank Payment';
                            Image = BankAccountStatement;
                            ApplicationArea = All;
                            RunObject = report "Generate Bank Payment 1";
                        }
                    }
                    group(Archives1)
                    {
                        Caption = 'Archives';
                        action("Archived Payment Vouchers")
                        {
                            Caption = 'Archived Payment Vouchers';
                            ApplicationArea = All;
                            Image = Archive;
                            // RunObject = page "Archieved Payment Vouchers";
                        }
                    }
                }
                group(Setup12)
                {
                    Caption = 'Setup';
                    action("NFL Setup")
                    {
                        Caption = 'NFL Setup';
                        ApplicationArea = All;
                        // RunObject = page "NFL Setup";
                    }
                    // action("NFL Approval Setup")
                    // {
                    //     Caption = 'NFL Approval Setup';
                    //     ApplicationArea = All;
                    //     RunObject = page "NFL Approval Setup";
                    // }
                }
            }
        }
    }

    var
        myInt: Integer;
}