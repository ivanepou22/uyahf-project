/// <summary>
/// Codeunit Workflow Event Handling Ext (ID 50048).
/// </summary>
codeunit 50006 "PCV Workflow EventHandling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendClaimForApprovalCode(), Database::"Payment Voucher Header", ClaimSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelClaimApprovalCode(), Database::"Payment Voucher Header", ClaimApprovalRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelClaimApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelClaimApprovalCode, RunWorkflowOnSendClaimForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendClaimForApprovalCode);
        end;
    end;

    /// <summary>
    /// RunWorkflowOnSendClaimForApprovalCode.
    /// </summary>
    /// <returns>Return value of type Code[128].</returns>
    procedure RunWorkflowOnSendClaimForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendVoucherForApproval'))
    end;

    /// <summary>
    /// RunWorkflowOnSendClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "Payment Voucher Header".</param>

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Functions Cash", 'OnSendClaimForApproval', '', true, true)]
    procedure RunWorkflowOnSendVoucherForApproval(var Claim: Record "Payment Voucher Header")
    begin
        workflowManagement.HandleEvent(RunWorkflowOnSendClaimForApprovalCode, Claim);
    end;

    /// <summary>
    /// RunWorkflowOnCancelClaimApprovalCode.
    /// </summary>
    /// <returns>Return value of type Code[128].</returns>
    procedure RunWorkflowOnCancelClaimApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelVoucherApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Functions Cash", 'OnCancelClaimForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelVoucherApproval(var Claim: Record "Payment Voucher Header")
    begin
        workflowManagement.HandleEvent(RunWorkflowOnCancelClaimApprovalCode, Claim);
    end;

    //===================================================

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, true)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(ClaimWorkflowCategoryTxt, ClaimWorkflowCategoryDescTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', true, true)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record 454;
    begin
        WorkflowSetup.InsertTableRelation(Database::"Payment Voucher Header", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, true)]
    local procedure OnInsertWorkflowTemplates()
    begin
        InsertClaimApprovalWorkflowTemplate();
    end;

    local procedure InsertClaimApprovalWorkflowTemplate()
    var
        Workflow: Record 1501;
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, ClaimApprovalWorkflowCodeTxt, ClaimApprovalWorkfowDescTxt, ClaimWorkflowCategoryTxt);
        InsertClaimApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertClaimApprovalWorkflowDetails(var Workflow: Record 1501)
    var
        WorkflowStepArgument: Record 1523;
        BlankDateFormula: DateFormula;
        WorkflowResponseHandling: Codeunit 1521;
        Claim: Record "Payment Voucher Header";
    begin
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument,
        WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
        0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildClaimTypeConditions(Claim.Status::Open),
            RunWorkflowOnSendClaimForApprovalCode,
            BuildClaimTypeConditions(Claim.Status::"Pending approval"),
            RunWorkflowOnCancelClaimApprovalCode,
            WorkflowStepArgument,
            true);
    end;

    local procedure BuildClaimTypeConditions(Status: Integer): Text
    var
        Claim: Record "Payment Voucher Header";
    begin
        Claim.SetRange(Claim.Status, Status);
        exit(StrSubstNo(ClaimTypeCondTxt, WorkflowSetup.Encode(Claim.GetView(false))))
    end;

    var
        workflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        ClaimSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a Payment Voucher document is requested';
        ClaimApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a Payment Voucher document is canceled';

        WorkflowSetup: Codeunit 1502;
        ClaimWorkflowCategoryTxt: TextConst ENU = 'PVDW';
        ClaimWorkflowCategoryDescTxt: TextConst ENU = 'Payment Voucher Document';
        ClaimApprovalWorkflowCodeTxt: TextConst ENU = 'PVAPW';
        ClaimApprovalWorkfowDescTxt: TextConst ENU = 'Payment Voucher Approval Workflow';
        ClaimTypeCondTxt: TextConst ENU = '<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”Claim”>%1</DataItem></DataItems></ReportParameters>';
}