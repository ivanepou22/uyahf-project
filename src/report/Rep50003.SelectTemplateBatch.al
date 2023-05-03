/// <summary>
/// Report Select Template & Batch (ID 50052).
/// </summary>
report 50003 "Select Template & Batch"
{
    // version Payment Processing ()

    Caption = 'Select Template & Batch';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Gen. Journal Line"; "Gen. Journal Line")
        {
            RequestFilterFields = "Journal Template Name", "Journal Batch Name";


            trigger OnPostDataItem();
            begin
                // , Check whether batch exists in the selected template.
                GenJournalBatch.SETRANGE("Journal Template Name", JournalTemplateName);
                GenJournalBatch.SETRANGE(Name, JournalBatchName);
                IF NOT GenJournalBatch.FIND('-') THEN
                    ERROR('The General Journal Batch ' + JournalBatchName + ' does not exist in General Journal Template ' + JournalTemplateName);

                // GenJournalBatch.RESET;
                // GenJournalBatch.SETRANGE("Journal Template Name", JournalTemplateName);
                // GenJournalBatch.SETRANGE(Name, JournalBatchName);
                // IF GenJournalBatch.FIND('-') THEN BEGIN
                //     IF GenJournalBatch."Cashier ID" <> '' THEN BEGIN
                //         IF GenJournalBatch."Cashier ID" <> USERID THEN BEGIN
                //             IF UserSetup.GET(USERID) THEN
                //                 IF UserSetup."Glue to Batch" = TRUE THEN
                //                     ERROR('To use this journal %1, you must be logged in as %2 \ ', JournalBatchName,
                //                           GenJournalBatch."Cashier ID");
                //         END
                //         ELSE
                //             "Cashier ID" := GenJournalBatch."Cashier ID";
                //     END
                //     ELSE BEGIN
                //         IF UserSetup.GET(USERID) THEN
                //             IF UserSetup."Glue to Batch" = TRUE THEN
                //                 ERROR('You must only transfer to your assigned Journal batch! \ ');
                //     END;
                // END;


                // Stores the Journal details in the purchases and payables setup.
                PurchasesPayablesSetup.GET;
                PurchasesPayablesSetup."Payment Voucher Jnl. Template" := JournalTemplateName;
                PurchasesPayablesSetup."Payment Voucher Jnl. Batch" := JournalBatchName;
                PurchasesPayablesSetup.MODIFY;
                //  - END
            end;

            trigger OnPreDataItem();
            var
                JournalBatch: Record "Gen. Journal Batch";
                Txt001: Label 'You are not allowed to access this Batch, Please contact your Systems Administrator';
            begin
                JournalTemplateName := "Gen. Journal Line".GETFILTER("Journal Template Name");
                JournalBatchName := "Gen. Journal Line".GETFILTER("Journal Batch Name");

                IF JournalTemplateName = '' THEN
                    ERROR('Please select a Journal Template Name');

                IF JournalBatchName = '' THEN
                    ERROR('Please select a Journal Batch Name');

                // if (JournalTemplateName <> '') and (JournalBatchName <> '') then begin
                //     JournalBatch.Reset();
                //     JournalBatch.SetRange(JournalBatch."Journal Template Name", JournalTemplateName);
                //     JournalBatch.SetRange(JournalBatch.Name, JournalBatchName);
                //     if JournalBatch.FindFirst() then begin
                //         if JournalBatch."Cashier ID" <> UserId then
                //             Error(Txt001);
                //     end;
                // end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        GenJournalBatch: Record "Gen. Journal Batch";
        PaymentVoucherLine: Record "Payment Voucher Line";
        Text001: Label 'Total Payee amount is less total Expenditure amount by %1. Are you sure you want to transfer the entries to the journal';
        Text002: Label 'Status for No %1 must be Released in order to archive this Requisition';
        Text003: Label 'You are not permitted to Archieve  document No. %1';
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GenJournalLine: Record "Gen. Journal Line";
        UserSetup: Record "User Setup";
        PaymentVoucher: Page "Cash Voucher";
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
        DocumentNo: Code[20];
}

