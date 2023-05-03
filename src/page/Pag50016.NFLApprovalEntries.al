/// <summary>
/// Page NFL Approval Entries (ID 50208).
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
                field("Table ID"; "Table ID")
                {
                }
                field("Limit Type"; "Limit Type")
                {
                }
                field("Approval Type"; "Approval Type")
                {
                }
                field("Document Type"; "Document Type")
                {
                }
                field("Document No."; "Document No.")
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
                field("Sequence No."; "Sequence No.")
                {
                }
                field("Approval Code"; "Approval Code")
                {
                }
                field(Status; Status)
                {
                }
                field("Sender ID"; "Sender ID")
                {
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                }
                field("Approver ID"; "Approver ID")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                }
                field("Available Credit Limit (LCY)"; "Available Credit Limit (LCY)")
                {
                }
                field("Date-Time Sent for Approval"; "Date-Time Sent for Approval")
                {
                }
                field("Last Date-Time Modified"; "Last Date-Time Modified")
                {
                }
                field("Last Modified By ID"; "Last Modified By User ID")
                {
                }
                field(Comment; Comment)
                {
                }
                field("Due Date"; "Due Date")
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
                        ApprovalComments: Page "NFL Approval Comments";
                    // ApprovalEntry: Record "NFL Approval Entry";
                    begin
                        ApprovalComments.Setfilters("Table ID", "Document Type", "Document No.", "Sequence No.");
                        ApprovalComments.SetUpLine("Table ID", "Document Type", "Document No.", "Sequence No.");
                        ApprovalComments.RUN;
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
                        SETFILTER(Status, '%1|%2', Status::Created, Status::Open);
                        SETFILTER("Due Date", '<%1', TODAY);
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
                        SETRANGE(Status);
                        SETRANGE("Due Date");
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
            FILTERGROUP(2);
            Filterstring := GETFILTERS;
            FILTERGROUP(0);
            IF STRLEN(Filterstring) = 0 THEN BEGIN
                FILTERGROUP(2);
                SETCURRENTKEY("Approver ID");
                IF Overdue = Overdue::Yes THEN
                    SETRANGE("Approver ID", Usersetup."User ID");
                SETRANGE(Status, Status::Open);
                FILTERGROUP(0);
            END ELSE
                SETCURRENTKEY("Table ID", "Document Type", "Document No.");
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
        NFLApprovalComment: Record "NFL Approval Comment Line";

    /// <summary>
    /// Description for Setfilters.
    /// </summary>
    /// <param name="TableId">Parameter of type Integer.</param>
    /// <param name="DocumentType">Parameter of type Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation","Store Return".</param>
    /// <param name="DocumentNo">Parameter of type Code[20].</param>
    procedure Setfilters(TableId: Integer; DocumentType: Option "Store Requisition","Purchase Requisition",Payment,"Bank Reconciliation","Store Return"; DocumentNo: Code[20]);
    begin
        IF TableId <> 0 THEN BEGIN
            FILTERGROUP(2);
            SETCURRENTKEY("Table ID", "Document Type", "Document No.");
            SETRANGE("Table ID", TableId);
            SETRANGE("Document Type", DocumentType);
            IF DocumentNo <> '' THEN
                SETRANGE("Document No.", DocumentNo);
            FILTERGROUP(0);
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

