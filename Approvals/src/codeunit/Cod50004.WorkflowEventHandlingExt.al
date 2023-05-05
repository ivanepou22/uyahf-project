/// <summary>
/// Codeunit Workflow Event Handling Ext (ID 50004).
/// </summary>
codeunit 50004 "PRQ Workflow EventHandling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendClaimForApprovalCode(), Database::"NFL Requisition Header", ClaimSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelClaimApprovalCode(), Database::"NFL Requisition Header", ClaimApprovalRequestCancelEventDescTxt, 0, false);
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
        exit(UpperCase('RunWorkflowOnSendClaimForApproval'))
    end;

    /// <summary>
    /// RunWorkflowOnSendClaimForApproval.
    /// </summary>
    /// <param name="Claim">VAR Record "NFL Requisition Header".</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Functions Requisition", 'OnSendClaimForApproval', '', true, true)]
    procedure RunWorkflowOnSendClaimForApproval(var Claim: Record "NFL Requisition Header")
    begin
        workflowManagement.HandleEvent(RunWorkflowOnSendClaimForApprovalCode, Claim);
    end;

    /// <summary>
    /// RunWorkflowOnCancelClaimApprovalCode.
    /// </summary>
    /// <returns>Return value of type Code[128].</returns>
    procedure RunWorkflowOnCancelClaimApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelClaimApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Functions Requisition", 'OnCancelClaimForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelClaimApproval(var Claim: Record "NFL Requisition Header")
    begin
        workflowManagement.HandleEvent(RunWorkflowOnCancelClaimApprovalCode, Claim);
    end;

    // ==========================================

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
        WorkflowSetup.InsertTableRelation(Database::"NFL Requisition Header", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
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
        // WorkflowEventHandlingCust: Codeunit "Workflow Event Handling Ext";
        WorkflowResponseHandling: Codeunit 1521;
        Claim: Record "NFL Requisition Header";
    begin
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument,
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
        Claim: Record "NFL Requisition Header";
    begin
        Claim.SetRange(Claim.Status, Status);
        exit(StrSubstNo(ClaimTypeCondTxt, WorkflowSetup.Encode(Claim.GetView(false))))
    end;

    var
        workflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        ClaimSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a Purchase Requisition document is requested';
        ClaimApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a Purchase Requisition document is canceled';

        WorkflowSetup: Codeunit 1502;
        ClaimWorkflowCategoryTxt: TextConst ENU = 'CDW2';
        ClaimWorkflowCategoryDescTxt: TextConst ENU = 'Purchase Requisition Document';
        ClaimApprovalWorkflowCodeTxt: TextConst ENU = 'CAPW2';
        ClaimApprovalWorkfowDescTxt: TextConst ENU = 'Purchase Requisition Approval Workflow';
        ClaimTypeCondTxt: TextConst ENU = '<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”Claim”>%1</DataItem></DataItems></ReportParameters>';
}