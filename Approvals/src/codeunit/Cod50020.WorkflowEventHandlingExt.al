/// <summary>
/// Codeunit Workflow Event Handling Ext (ID 50042).
/// </summary>
codeunit 50020 "Workflow Event Handling Ext"
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
        exit(UpperCase('RunWorkflowOnSendClaimForApproval2'))
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
        exit(UpperCase('RunWorkflowOnCancelClaimApproval2'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Functions Requisition", 'OnCancelClaimForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelClaimApproval(var Claim: Record "NFL Requisition Header")
    begin
        workflowManagement.HandleEvent(RunWorkflowOnCancelClaimApprovalCode, Claim);
    end;

    var
        workflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        ClaimSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a Requisition document is requested 2';
        ClaimApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a Requisition document is canceled 2';
}