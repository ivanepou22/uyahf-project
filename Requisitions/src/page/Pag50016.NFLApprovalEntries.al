/// <summary>
/// Page NFL Approval Entries (ID 50016).
/// </summary>
page 50016 "NFL Approval Entries"
{
    // version NFL02.000

    Caption = 'NFL Approval Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Approval Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Overdue; Overdue)
                {
                    Caption = 'Overdue';
                    Editable = false;
                    OptionCaption = 'Yes';
                    ToolTip = 'Overdue Entry';
                }
                field("Table ID"; Rec."Table ID")
                {
                }
                field("Limit Type"; Rec."Limit Type")
                {
                }
                field("Approval Type"; Rec."Approval Type")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                // field(Payee; Payee)
                // {
                // }
                // field("Payment Voucher Currency"; "Payment Voucher Currency")
                // {
                // }
                // field("Payment Voucher Details Total"; "Payment Voucher Details Total")
                // {
                // }
                // field("Payment Voucher Lines Total"; "Payment Voucher Lines Total")
                // {
                // }
                field("Sequence No."; Rec."Sequence No.")
                {
                }
                field("Approval Code"; Rec."Approval Code")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Sender ID"; Rec."Sender ID")
                {
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                }
                field("Approver ID"; Rec."Approver ID")
                {
                }
                field("Currency Code"; Rec."Currency Code")
                {
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                }
                field("Available Credit Limit (LCY)"; Rec."Available Credit Limit (LCY)")
                {
                }
                field("Date-Time Sent for Approval"; Rec."Date-Time Sent for Approval")
                {
                }
                field("Last Date-Time Modified"; Rec."Last Date-Time Modified")
                {
                }
                field("Last Modified By ID"; Rec."Last Modified By User ID")
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field("Due Date"; Rec."Due Date")
                {
                }
                // field(Escalated; Escalated)
                // {
                // }
                // field("Escalated by"; "Escalated by")
                // {
                // }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Show")
            {
                Caption = '&Show';
                action(Document)
                {
                    Caption = 'Document';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    // trigger OnAction();
                    // var
                    //     ApprovalEntry: Record "NFL Approval Entry";
                    // begin
                    //     CurrPage.SETSELECTIONFILTER(ApprovalEntry); // MAG 20TH. NOV. 2018, Prevent users accidentally locking tables.
                    //     IF ApprovalEntry.FIND('-') THEN
                    //         Rec.ShowDocument;
                    // end;
                }
                action(Comments)
                {
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                    // ApprovalComments: Page "NFL Approval Comments"; TODO:Review the comments on this page
                    // ApprovalEntry: Record "NFL Approval Entry";
                    begin
                        // ApprovalComments.Setfilters(Rec."Table ID", Rec."Document Type", Rec."Document No.", Rec."Sequence No.");
                        // ApprovalComments.SetUpLine(Rec."Table ID", Rec."Document Type", Rec."Document No.", Rec."Sequence No.");
                        // ApprovalComments.RUN;
                    end;
                }
                action("O&verdue Entries")
                {
                    Caption = 'O&verdue Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.SETFILTER(Status, '%1|%2', Rec.Status::Created, Rec.Status::Open);
                        Rec.SETFILTER("Due Date", '<%1', TODAY);
                    end;
                }
                action("All Entries")
                {
                    Caption = 'All Entries';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.SETRANGE(Status);
                        Rec.SETRANGE("Due Date");
                    end;
                }
            }
        }
        area(processing)
        {
            // action(Approve)
            // {
            //     Caption = '&Approve';
            //     Image = Approve;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     Visible = ApproveVisible;

            //     trigger OnAction();
            //     var
            //         ApprovalEntry: Record "NFL Approval Entry";
            //     begin
            //         IF NOT CONFIRM('Are you sure you want to approve the selected request?', FALSE) THEN
            //             EXIT;

            //         CurrPage.SETSELECTIONFILTER(ApprovalEntry);
            //         IF ApprovalEntry.FIND('-') THEN
            //             REPEAT
            //                 ApprovalMgt.ApproveApprovalRequest(ApprovalEntry);
            //             UNTIL ApprovalEntry.NEXT = 0;
            //     end;
            // }

            // action("&Delegate")
            // {
            //     Caption = '&Delegate';
            //     Image = Delegate;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;

            //     trigger OnAction();
            //     var
            //         ApprovalEntry: Record "NFL Approval Entry";
            //         TempApprovalEntry: Record "NFL Approval Entry";
            //         ApprovalSetup: Record "NFL Approval Setup";
            //     begin
            //         IF NOT CONFIRM('Are you sure you want to delegate the selected request?', FALSE) THEN
            //             EXIT;


            //         CurrPage.SETSELECTIONFILTER(ApprovalEntry);

            //         CurrPage.SETSELECTIONFILTER(TempApprovalEntry);
            //         IF TempApprovalEntry.FIND('-') THEN BEGIN
            //             TempApprovalEntry.SETFILTER(Status, '<>%1', TempApprovalEntry.Status::Open);
            //             IF NOT TempApprovalEntry.ISEMPTY THEN
            //                 ERROR(Text001);
            //         END;

            //         IF ApprovalEntry.FIND('-') THEN BEGIN
            //             IF ApprovalSetup.GET THEN;
            //             IF Usersetup.GET(USERID) THEN;
            //             IF (ApprovalEntry."Sender ID" = Usersetup."User ID") OR
            //                (ApprovalSetup."Approval Administrator" = Usersetup."User ID") OR
            //                (ApprovalEntry."Approver ID" = Usersetup."User ID")
            //             THEN BEGIN
            //                 REPEAT
            //                     ApprovalMgt.DelegateApprovalRequest(ApprovalEntry);
            //                 UNTIL ApprovalEntry.NEXT = 0;
            //             END;
            //         END;

            //         MESSAGE(Text002);
            //     end;
            // }
            // action(Escalate)
            // {
            //     Caption = '&Escalate';
            //     Image = SelectItemSubstitution;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;

            //     trigger OnAction();
            //     var
            //         ApprovalEntry: Record "NFL Approval Entry";
            //         TempApprovalEntry: Record "NFL Approval Entry";
            //         ApprovalSetup: Record "NFL Approval Setup";
            //     begin
            //         IF NOT CONFIRM('Are you sure you want to escalade the selected request?', FALSE) THEN
            //             EXIT;

            //         CurrPage.SETSELECTIONFILTER(ApprovalEntry);

            //         CurrPage.SETSELECTIONFILTER(TempApprovalEntry);
            //         IF TempApprovalEntry.FIND('-') THEN BEGIN
            //             TempApprovalEntry.SETFILTER(Status, '<>%1', TempApprovalEntry.Status::Open);
            //             IF NOT TempApprovalEntry.ISEMPTY THEN
            //                 ERROR(Text0010);
            //         END;

            //         IF ApprovalEntry.FIND('-') THEN BEGIN
            //             IF ApprovalSetup.GET THEN;
            //             IF Usersetup.GET(USERID) THEN;
            //             IF (ApprovalEntry."Sender ID" = Usersetup."User ID") OR
            //                (ApprovalSetup."Approval Administrator" = Usersetup."User ID") OR
            //                (ApprovalEntry."Approver ID" = Usersetup."User ID")
            //             THEN BEGIN
            //                 REPEAT
            //                     ApprovalMgt.EscaladeApprovalRequest(ApprovalEntry);
            //                 UNTIL ApprovalEntry.NEXT = 0;
            //             END;
            //         END;

            //         MESSAGE(Text0020);
            //     end;
            // }
        }
    }

    trigger OnAfterGetRecord();
    begin
        Overdue := Overdue::" ";
        // IF FormatField(Rec) THEN
        //     Overdue := Overdue::Yes;
    end;

    trigger OnInit();
    begin
        RejectVisible := TRUE;
        ApproveVisible := TRUE;
    end;

    trigger OnOpenPage();
    var
        Filterstring: Text[250];
    begin
        IF Usersetup.GET(USERID) THEN BEGIN
            Rec.FILTERGROUP(2);
            Filterstring := Rec.GETFILTERS;
            Rec.FILTERGROUP(0);
            IF STRLEN(Filterstring) = 0 THEN BEGIN
                Rec.FILTERGROUP(2);
                Rec.SETCURRENTKEY("Approver ID");
                IF Overdue = Overdue::Yes THEN
                    Rec.SETRANGE("Approver ID", Usersetup."User ID");
                Rec.SETRANGE(Status, Rec.Status::Open);
                Rec.FILTERGROUP(0);
            END ELSE
                Rec.SETCURRENTKEY("Table ID", Rec."Document Type", Rec."Document No.");
        END;
    end;

    var
        Usersetup: Record "User Setup";
        // ApprovalMgt: Codeunit "NFL Approvals Management";
        Text001: Label 'You can only delegate open approval entries.';
        Text002: Label '"The selected approval(s) have been delegated. "';
        Overdue: Option Yes," ";
        Text004: Label 'Approval Setup not found.';
        [InDataSet]
        ApproveVisible: Boolean;
        [InDataSet]
        RejectVisible: Boolean;
        Text0010: Label 'You can only escalade open approval entries.';
        Text0020: Label '"The selected approval(s) have been escaladed. "';
        NFLReqnHeader: Record "NFL Requisition Header";
    // NFLApprovalComment: Record "NFL Approval Comment Line";

    /// <summary>
    /// Description for Setfilters.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocumentType">Parameter of type Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation","Store Return".</param>
    /// <param name="DocumentNo">Parameter of type Code[20].</param>
    procedure Setfilters(TableId: Integer; DocumentType: Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation","Store Return"; DocumentNo: Code[20]);
    begin
        IF TableId <> 0 THEN BEGIN
            Rec.FILTERGROUP(2);
            Rec.SETCURRENTKEY("Table ID", Rec."Document Type", Rec."Document No.");
            Rec.SETRANGE("Table ID", TableId);
            Rec.SETRANGE("Document Type", DocumentType);
            IF DocumentNo <> '' THEN
                Rec.SETRANGE("Document No.", DocumentNo);
            Rec.FILTERGROUP(0);
        END;

        ApproveVisible := FALSE;
        RejectVisible := FALSE;
    end;

    /// <summary>
    /// Description for FormatField.
    /// </summary>
    /// <param name="Rec">Parameter of type Record "NFL Approval Entry".</param>
    /// <returns>Return variable OK of type Boolean.</returns>


    /// <summary>
    /// Description for CalledFrom.
    /// </summary>
    procedure CalledFrom();
    begin
        Overdue := Overdue::" ";
    end;
}

