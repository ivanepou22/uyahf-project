/// <summary>
/// Report Transfer Voucher Approval (ID 50021).
/// </summary>
report 50021 "Transfer Purch. Vouch Approval"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Transfer Purchase Requisitions Approval';
    Permissions = tabledata "Approval Entry" = rimd;

    dataset
    {
        dataitem("NFL Requisition Header"; "NFL Requisition Header")
        {
            RequestFilterFields = "No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Document Type";

            trigger OnPreDataItem()
            begin
                "NFL Requisition Header".CalcFields("Current Approver");
                "NFL Requisition Header".SetRange("Current Approver", FromApprover);
            end;

            trigger OnAfterGetRecord()
            begin
                ApprovalEntry.Reset();
                ApprovalEntry.SetRange("Document No.", "NFL Requisition Header"."No.");
                ApprovalEntry.SetRange("Approver ID", FromApprover);
                ApprovalEntry.SetRange(ApprovalEntry.Status, ApprovalEntry.Status::Open);
                if ApprovalEntry.FindFirst() then begin
                    ApprovalEntry."Approver ID" := ToApprover;
                    ApprovalEntry.Modify();
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field("From Approver Code"; FromApprover)
                    {
                        ApplicationArea = All;
                        TableRelation = "User Setup"."User ID";
                    }
                    field("To Approver Code"; ToApprover)
                    {
                        ApplicationArea = All;
                        TableRelation = "User Setup"."User ID";
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if FromApprover = '' then
            Error('From Approver Code can not Empty');
        if ToApprover = '' then
            Error('To Approver Code can not be empty');
        if FromApprover = ToApprover then begin
            Error('From Approver Code and To Approver Code can not be the same');
        end;
    end;

    var
        FromApprover: Code[100];
        ToApprover: Code[100];
        ApprovalEntry: Record "Approval Entry";
}