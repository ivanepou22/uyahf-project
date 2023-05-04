/// <summary>
/// Codeunit Workflow Setup Ext (ID 50004).
/// </summary>
codeunit 50004 "Workflow Setup Ext"
{
    trigger OnRun()
    begin
    end;

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
        WorkflowEventHandlingCust: Codeunit "Workflow Event Handling Ext";
        WorkflowResponseHandling: Codeunit 1521;
        Claim: Record "NFL Requisition Header";
    begin
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument,
        WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
        0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildClaimTypeConditions(Claim.Status::Open),
            WorkflowEventHandlingCust.RunWorkflowOnSendClaimForApprovalCode,
            BuildClaimTypeConditions(Claim.Status::"Pending approval"),
            WorkflowEventHandlingCust.RunWorkflowOnCancelClaimApprovalCode,
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
        WorkflowSetup: Codeunit 1502;
        ClaimWorkflowCategoryTxt: TextConst ENU = 'CDW2';
        ClaimWorkflowCategoryDescTxt: TextConst ENU = 'Requisition Document 2';
        ClaimApprovalWorkflowCodeTxt: TextConst ENU = 'CAPW2';
        ClaimApprovalWorkfowDescTxt: TextConst ENU = 'Requisition Approval Workflow 2';
        ClaimTypeCondTxt: TextConst ENU = '<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”Claim”>%1</DataItem></DataItems></ReportParameters>';
}