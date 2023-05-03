/// <summary>
/// Report Generate Bank Payment 1 (ID 50055).
/// </summary>
report 50006 "Generate Bank Payment 1"
{
    // version MAG

    ProcessingOnly = true;

    dataset
    {
        dataitem("Payment Voucher Line"; "Payment Voucher Line")
        {
            dataitem(DataItem2; "Payment Voucher Header")
            {
                DataItemLink = "No." = FIELD("Document No.");
                RequestFilterFields = "Posting Date";
            }

            trigger OnAfterGetRecord();
            begin
                PaymentVoucherHeader.SETRANGE("No.", "Payment Voucher Line"."Document No.");
                PaymentVoucherHeader.SETRANGE("Document Type", "Payment Voucher Line"."Document Type"::"Cheque Payment Voucher"); // Only cheque vouchers are exported to the bank
                IF PaymentVoucherHeader.FIND('-') THEN BEGIN
                    IF ("Payment Voucher Line"."Bank File Generated" = FALSE) AND
                      (PaymentVoucherHeader.Status = PaymentVoucherHeader.Status::Released)
                     THEN BEGIN
                        "Payment Voucher Line"."Bank File Generated" := TRUE;
                        "Payment Voucher Line"."Bank File Generated On" := TODAY;
                        "Payment Voucher Line"."Bank File Gen. by" := USERID;
                        MODIFY;
                        MakeExcelDataBody;
                    END;
                END;
            end;
        }
    }

    requestpage
    {

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

    trigger OnPostReport();
    begin
        CreateExcelbook;
    end;

    trigger OnPreReport();
    begin
        IF UserSetup.GET(USERID) THEN BEGIN
            IF UserSetup."Export Payment File" THEN
                MakeExcelDataHeader
            ELSE
                ERROR('You do not have permissions to export payments to a file');
        END ELSE
            ERROR('User not found in the User Setup');
    end;

    var
        VendRec: Record vendor;
        VendName: Text[50];
        VendorBankRec: Record "Vendor Bank Account";
        GenJnl: Record "Gen. Journal Line";
        Text001: Label 'Web Bank List';
        Text002: Label 'Data';
        ExcelBuf: Record "Excel Buffer" temporary;
        VendorBankAccount: Record "Vendor Bank Account";
        PaymentVoucherHeader: Record "Payment Voucher Header";
        StaffAdvanceName: Text[200];
        UserSetup: Record "User Setup";

    /// <summary>
    /// Description for MakeExcelDataHeader.
    /// </summary>
    procedure MakeExcelDataHeader();
    begin
        ExcelBuf.AddColumn('Name', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Account No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Bank Name', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Bank Code', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Branch Code', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Net Pay', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('PAY', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
    end;

    /// <summary>
    /// Description for MakeExcelDataBody.
    /// </summary>
    procedure MakeExcelDataBody();
    var
        BlankFiller: Text[250];
    begin
        "Payment Voucher Line".TESTFIELD("Beneficary Name");
        "Payment Voucher Line".TESTFIELD("Beneficary Bank Account No.");
        "Payment Voucher Line".TESTFIELD("Beneficary Bank Name");
        "Payment Voucher Line".TESTFIELD("Beneficary Bank Code");
        "Payment Voucher Line".TESTFIELD("Beneficary Branch Code");
        BlankFiller := PADSTR(' ', MAXSTRLEN(BlankFiller), ' ');
        ExcelBuf.NewRow;

        ExcelBuf.AddColumn("Payment Voucher Line"."Beneficary Name", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Payment Voucher Line"."Beneficary Bank Account No.", FALSE, '', FALSE, FALSE, FALSE, '@', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Payment Voucher Line"."Beneficary Bank Name", FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Payment Voucher Line"."Beneficary Bank Code", FALSE, '', FALSE, FALSE, FALSE, '@', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Payment Voucher Line"."Beneficary Branch Code", FALSE, '', FALSE, FALSE, FALSE, '@', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Payment Voucher Line".Amount, FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Number);
        ExcelBuf.AddColumn('PAY', FALSE, '', FALSE, FALSE, FALSE, '', ExcelBuf."Cell Type"::Text);
    end;

    /// <summary>
    /// Description for CreateExcelbook.
    /// </summary>
    procedure CreateExcelbook();
    var
        customFunction: Codeunit "Custom Functions And EVents";
    begin
        // LF   ExcelBuf.CreateBookAndOpenExcel('Web Bank List', '', '', 'The New Vision', USERID);
    end;
}

