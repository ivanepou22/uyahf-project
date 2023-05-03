/// <summary>
/// Report Cheque Payment Voucher (ID 50051).
/// </summary>
report 50002 "Cheque Payment Voucher"
{
    // version

    DefaultLayout = RDLC;
    RDLCLayout = './Cheque Payment Voucher.rdlc';

    dataset
    {
        dataitem("Payment Voucher Header"; "Payment Voucher Header")
        {
            column(hide; hide)
            {
            }
            column(BalancingEntry_PaymentVoucherHeader; "Payment Voucher Header"."Balancing Entry")
            {
            }
            column(AccountabilityComment_PaymentVoucherHeader; "Payment Voucher Header"."Accountability Comment")
            {
            }
            column(No_PaymentVoucherHeader; "Payment Voucher Header"."No.")
            {
            }
            column(DocumentType_PaymentVoucherHeader; "Payment Voucher Header"."Document Type")
            {
            }
            column(FinancialYear; "Payment Voucher Header"."Fiscal Year Start Date")
            {
            }
            column(FiscalYearEndDate_PaymentVoucherHeader; "Payment Voucher Header"."Fiscal Year End Date")
            {
            }
            column(Date; "Payment Voucher Header"."Posting Date")
            {
            }
            column(Receivedby_PaymentVoucherHeader; "Payment Voucher Header"."Received by")
            {
            }
            column(Payee_PaymentVoucherHeader; "Payment Voucher Header".Payee)
            {
            }
            column(Address; CompanyInformation.Address)
            {
            }
            column(Address1; CompanyInformation."Address 2")
            {
            }
            column(PhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(Recipient; Recipient)
            {
            }
            column(RecipientSign; RecipientSign)
            {
            }
            column(AccCode; AccCode)
            {
            }
            column(CostCentre; CostCentre)
            {
            }
            column(Prepared_By; "Payment Voucher Header"."Prepared by")
            {
            }
            column(Prepared_By_Name; Prepared_By_Name)
            {
            }
            // column(ReleaseDate; "Payment Voucher Header".re)
            // {
            // }
            column(Debit; Debit)
            {
            }
            column(Credit; Credit)
            {
            }
            column(Approved; Approved)
            {
            }
            column(AmountUGX; AmountUGX)
            {
            }
            column(HOD; HOD)
            {
            }
            column(MDCD; MDCD)
            {
            }
            column(AmountWords; AmountWords)
            {
            }
            column(Details; Details)
            {
            }
            column(CompanyInfo; CompanyInformation.Picture)
            {
            }
            column(Audit; ChiefAudit)
            {
            }
            column(Finance; FinanceMana)
            {
            }
            column(NewVision; NewVision)
            {
            }
            column(Fax; CompanyInformation."Fax No.")
            {
            }
            column(Header; ReportHeader)
            {
            }
            column(Caption000001; Caption000001)
            {
            }
            column(Caption000002; Caption000002)
            {
            }
            column(Caption000003; Caption000003)
            {
            }
            column(Caption000004; Caption000004)
            {
            }
            column(Caption000005; Caption000005)
            {
            }
            column(PVDate; PVDate)
            {
            }
            column(Cheque; Cheque)
            {
            }
            column(FinanceYear1; FinancialYear)
            {
            }
            column(NumberText1; NumberText[1])
            {
            }
            column(NumberText2; NumberText[2])
            {
            }
            column(FirstApprover; FullNames[1])
            {
            }
            column(SecondApprover; FullNames[2])
            {
            }
            column(ThirdApprover; FullNames[3])
            {
            }
            column(FourthApprover; FullNames[4])
            {
            }
            column(FifthApprover; FullNames[5])
            {
            }
            column(SixthApprover; FullNames[6])
            {
            }
            column(SeventhApprover; FullNames[7])
            {
            }
            column(EscalationOne; EscalatedByName[1])
            {
            }
            column(EscalationTwo; EscalatedByName[2])
            {
            }
            column(EscalationThree; EscalatedByName[3])
            {
            }
            column(EscalationFour; EscalatedByName[4])
            {
            }
            column(EscalationFive; EscalatedByName[5])
            {
            }
            column(EscalationSix; EscalatedByName[6])
            {
            }
            column(EscalationSeven; EscalatedByName[7])
            {
            }
            column(FirstDateOfApproval; ApprovalDate1)
            {
            }
            column(SecondDateOfApproval; ApprovalDate2)
            {
            }
            column(ThirdDateOfApproval; ApprovalDate3)
            {
            }
            column(FourthDateOfApproval; ApprovalDate4)
            {
            }
            column(AppPositionOne; JobTitle1)
            {
            }
            column(AppPositionTwo; JobTitle2)
            {
            }
            column(AppPositionThree; JobTitle3)
            {
            }
            column(AppPositionFour; JobTitle4)
            {
            }
            column(PostingDate_PaymentVoucherHeader; "Payment Voucher Header"."Posting Date")
            {
            }
            column(CurrencyCode_PaymentVoucherHeader; "Payment Voucher Header"."Currency Code")
            {
            }
            dataitem("Payment Voucher Detail"; "Payment Voucher Detail")
            {
                DataItemLinkReference = "Payment Voucher Header";
                DataItemLink = "Document No." = FIELD("No.");
                column(Detail; "Payment Voucher Detail".Details)
                {
                }
                column(Amount; "Payment Voucher Detail".Amount)
                {
                }

                trigger OnAfterGetRecord();
                begin
                    TotalAmount := TotalAmount + "Payment Voucher Detail".Amount;
                end;

                trigger OnPostDataItem();
                begin
                    InitTextVariable;
                    FormatNoText(NumberText, TotalAmount);
                end;

                trigger OnPreDataItem();
                begin
                    TotalAmount := 0;
                end;
            }
            dataitem("Payment Voucher Line1"; "Payment Voucher Line")
            {
                DataItemLinkReference = "Payment Voucher Header";
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = WHERE("Exclude Amount" = FILTER(false));
                column(Amount_PaymentVoucherLine1; "Payment Voucher Line1".Amount)
                {
                }
                column(CurrencyCode_PaymentVoucherLine1; "Payment Voucher Line1"."Currency Code")
                {
                }
                column(AmountLCY_PaymentVoucherLine1; "Payment Voucher Line1"."Amount (LCY)")
                {
                }

                trigger OnAfterGetRecord();
                begin
                    GeneralLedgerSetup.GET;
                    IF "Payment Voucher Line"."Currency Code" <> '' THEN BEGIN
                        CurrencyCode := "Payment Voucher Line"."Currency Code";
                    END ELSE BEGIN
                        CurrencyCode := GeneralLedgerSetup."LCY Code";
                    END;

                    // Get Dimension codes and names
                    GeneralLedgerSetup.GET;
                    gvDimensionLabel[1] := GeneralLedgerSetup."Shortcut Dimension 1 Code";
                    gvDimensionLabel[2] := GeneralLedgerSetup."Shortcut Dimension 2 Code";
                    gvDimensionLabel[3] := GeneralLedgerSetup."Shortcut Dimension 3 Code";
                    gvDimensionLabel[4] := GeneralLedgerSetup."Shortcut Dimension 4 Code";
                    gvDimensionLabel[5] := GeneralLedgerSetup."Shortcut Dimension 5 Code";
                    gvDimensionLabel[6] := GeneralLedgerSetup."Shortcut Dimension 6 Code";
                    gvDimensionLabel[7] := GeneralLedgerSetup."Shortcut Dimension 7 Code";
                    gvDimensionLabel[8] := GeneralLedgerSetup."Shortcut Dimension 8 Code";

                    //loop through all dimension codes.
                    FOR i := 1 TO 8 DO BEGIN
                        DimensionSetEntry.RESET;
                        DimensionSetEntry.SETRANGE("Dimension Set ID", "Payment Voucher Line"."Dimension Set ID");
                        DimensionSetEntry.SETRANGE("Dimension Code", gvDimensionLabel[i]);
                        IF DimensionSetEntry.FIND('-') THEN BEGIN
                            DimensionSetEntry.CALCFIELDS("Dimension Value Name");
                            DimName[i] := DimensionSetEntry."Dimension Value Name";
                            DimCode[i] := DimensionSetEntry."Dimension Value Code";
                        END;
                    END;
                end;
            }
            dataitem("Payment Voucher Line"; "Payment Voucher Line")
            {
                DataItemLinkReference = "Payment Voucher Header";
                DataItemLink = "Document No." = FIELD("No.");
                column(ExcludeAmount_PaymentVoucherLine; "Payment Voucher Line"."Exclude Amount")
                {
                }
                column(AdvanceCode_PaymentVoucherLine; "Payment Voucher Line"."Advance Code")
                {
                }
                column(DimLabel1; gvDimensionLabel[1])
                {
                }
                column(DimLabel2; gvDimensionLabel[2])
                {
                }
                column(DimLabel3; gvDimensionLabel[3])
                {
                }
                column(DimLabel4; gvDimensionLabel[4])
                {
                }
                column(DimLabel5; gvDimensionLabel[5])
                {
                }
                column(DimLabel6; gvDimensionLabel[6])
                {
                }
                column(DimLabel7; gvDimensionLabel[7])
                {
                }
                column(DimLabel8; gvDimensionLabel[8])
                {
                }
                column(DimName1; DimName[1])
                {
                }
                column(DimName2; DimName[2])
                {
                }
                column(DimName3; DimName[3])
                {
                }
                column(DimName4; DimName[4])
                {
                }
                column(DimName5; DimName[5])
                {
                }
                column(DimName6; DimName[6])
                {
                }
                column(DimName7; DimName[7])
                {
                }
                column(DimName8; DimName[8])
                {
                }
                column(DimCode1; DimCode[1])
                {
                }
                column(DimCode2; DimCode[2])
                {
                }
                column(DimCode3; DimCode[3])
                {
                }
                column(DimCode4; DimCode[4])
                {
                }
                column(DimCode5; DimCode[5])
                {
                }
                column(DimCode6; DimCode[6])
                {
                }
                column(DimCode7; DimCode[7])
                {
                }
                column(DimCode8; DimCode[8])
                {
                }
                column(CurrencyCode; CurrencyCode)
                {
                }
                column(BudgetComment_PaymentVoucherLine; "Payment Voucher Line"."Budget Comment")
                {
                }
                column(CurrencyCode_PaymentVoucherLine; "Payment Voucher Line"."Currency Code")
                {
                }
                column(BudgetCommentfortheYear_PaymentVoucherLine; "Payment Voucher Line"."Budget Comment for the Year")
                {
                }
                column(AccountNo_PaymentVoucherLine; "Payment Voucher Line"."Account No.")
                {
                }
                column(Description_PaymentVoucherLine; "Payment Voucher Line".Description)
                {
                }
                column(AmountLCY_PaymentVoucherLine; "Payment Voucher Line"."Amount (LCY)")
                {
                }
                column(Amount_PaymentVoucherLine; "Payment Voucher Line".Amount)
                {
                }
                column(AccountType_PaymentVoucherLine; "Payment Voucher Line"."Account Type")
                {
                }
                column(ShortcutDimension1Code_PaymentVoucherLine; "Payment Voucher Line"."Shortcut Dimension 1 Code")
                {
                }
                column(ShortcutDimension2Code_PaymentVoucherLine; "Payment Voucher Line"."Shortcut Dimension 2 Code")
                {
                }
                column(DocumentType_PaymentVoucherLine; "Payment Voucher Line"."Document Type")
                {
                }
                column(BalAccountType_PaymentVoucherLine; "Payment Voucher Line"."Bal. Account Type")
                {
                }
                column(BalAccountNo_PaymentVoucherLine; "Payment Voucher Line"."Bal. Account No.")
                {
                }
                column(DimensionSetID_PaymentVoucherLine; "Payment Voucher Line"."Dimension Set ID")
                {
                }


                trigger OnAfterGetRecord();
                begin
                    GeneralLedgerSetup.GET;
                    IF "Payment Voucher Line"."Currency Code" <> '' THEN BEGIN
                        CurrencyCode := "Payment Voucher Line"."Currency Code";
                    END ELSE BEGIN
                        CurrencyCode := GeneralLedgerSetup."LCY Code";
                    END;

                    //MAG 26062017, Get Dimension codes and names
                    GeneralLedgerSetup.GET;
                    gvDimensionLabel[1] := GeneralLedgerSetup."Shortcut Dimension 1 Code";
                    gvDimensionLabel[2] := GeneralLedgerSetup."Shortcut Dimension 2 Code";
                    gvDimensionLabel[3] := GeneralLedgerSetup."Shortcut Dimension 3 Code";
                    gvDimensionLabel[4] := GeneralLedgerSetup."Shortcut Dimension 4 Code";
                    gvDimensionLabel[5] := GeneralLedgerSetup."Shortcut Dimension 5 Code";
                    gvDimensionLabel[6] := GeneralLedgerSetup."Shortcut Dimension 6 Code";
                    gvDimensionLabel[7] := GeneralLedgerSetup."Shortcut Dimension 7 Code";
                    gvDimensionLabel[8] := GeneralLedgerSetup."Shortcut Dimension 8 Code";

                    //loop through all dimension codes.
                    FOR i := 1 TO 8 DO BEGIN
                        DimensionSetEntry.RESET;
                        DimensionSetEntry.SETRANGE("Dimension Set ID", "Payment Voucher Line"."Dimension Set ID");
                        DimensionSetEntry.SETRANGE("Dimension Code", gvDimensionLabel[i]);
                        IF DimensionSetEntry.FIND('-') THEN BEGIN
                            DimensionSetEntry.CALCFIELDS("Dimension Value Name");
                            DimName[i] := DimensionSetEntry."Dimension Value Name";
                            DimCode[i] := DimensionSetEntry."Dimension Value Code";
                        END;
                    END;
                end;
            }

            dataitem("Approval Entry"; "Approval Entry")
            {
                DataItemLinkReference = "Payment Voucher Header";
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = where(status = filter(Approved));
                column(Approver_Id; "Approver ID")
                {
                }
                column(Escalated_Id; "Escalated By")
                {
                }
                column(ApproversName; ApproversName)
                {
                }
                trigger OnAfterGetRecord()
                var
                    User: Record User;
                begin
                    ApproversName := '';
                    User.Reset();
                    User.SetRange(User."User Name", "Approval Entry"."Approver ID");
                    if User.FindFirst() then
                        ApproversName := User."Full Name";
                end;
            }

            trigger OnAfterGetRecord();
            begin

                Prepared_By_Name := '';
                UserName.Reset();
                UserName.SetRange(UserName."User Name", "Payment Voucher Header"."Prepared by");
                if UserName.FindFirst() then
                    Prepared_By_Name := UserName."Full Name";

                GetApprovers;
                CLEAR(hide);
                IF "Payment Voucher Header"."Balancing Entry" = "Payment Voucher Header"."Balancing Entry"::"Same Line" THEN
                    hide := 0
                ELSE
                    IF "Payment Voucher Header"."Balancing Entry" = "Payment Voucher Header"."Balancing Entry"::"Different Line" THEN
                        hide := 1;
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

    trigger OnPreReport();
    begin
        CompanyInformation.GET;
        CompanyInformation.CALCFIELDS(Picture);
    end;

    var
        AccCode: Label 'Account Code';
        CostCentre: Label 'Cost Centre';
        Debit: Label 'Debit';
        Credit: Label 'Credit';
        UGX: Label 'Uganda Shillings';
        Approved: Label 'Approved By:';
        HOD: Label 'Head of Dept';
        ChiefAudit: Label 'Chief Internal Auditor';
        MDCD: Label 'MD/CS';
        AmountWords: Label '"The sum of "';
        Details: Label 'Details';
        Prepared_By_Name: Text[100];
        UserName: Record User;
        AmountUGX: Label 'Amount Uganda SHS.';
        Recipient: Label 'Recipient :';
        RecipientSign: Label 'Recipient Signature :';
        CompanyInformation: Record "Company Information";
        ReportHeader: Label 'CHEQUE PAYMENT VOUCHER';
        NewVision: Label 'The New Vision Priting and Publishing Co. Ltd.';
        FinanceMana: Label 'Finance Manager';
        PVDate: Label 'Date';
        FinancialYear: Label 'Financial Year';
        Cheque: Label 'Cheque No:';
        ApproversName: Text[100];
        Caption000001: Label '...................................';
        Caption000002: Label '.............................................................................';
        Caption000003: Label '...............';
        Caption000004: Label '.......................................................';
        Caption000005: Label '......................................................................................................................................................';
        NumberText: array[2] of Text[80];
        TotalAmount: Decimal;
        OnesText: array[20] of Text[30];
        TensText: array[20] of Text[30];
        ExponentText: array[5] of Text[30];
        GLSetup: Record "General Ledger Setup";
        ApprovalEntry: Record "Approval Entry";
        ApproverID: array[20] of Code[100];
        EscalationID: array[20] of Code[100];
        User: Record User;
        FullNames: array[20] of Text[100];
        EscalatedByName: array[100] of Text[100];
        JobTitle: array[20] of Text[50];
        Employee: Record Employee;
        RequestorDesignation: Text;
        gvEmployee: Record Employee;
        ApproverDate: array[100] of DateTime;
        Approver1: Text[80];
        Approver2: Text[80];
        Approver3: Text[80];
        Approver4: Text[80];
        // ApproverRec: Record "NFL Approval Entry";
        ApprovalDate1: Date;
        ApprovalDate2: Date;
        ApprovalDate3: Date;
        ApprovalDate4: Date;
        Signature1: Integer;
        JobTitle1: Text[80];
        JobTitle2: Text[80];
        JobTitle3: Text[80];
        JobTitle4: Text[80];
        LvUser: Record "User Setup";
        LvUser2: Record "User Setup";
        LvUser3: Record "User Setup";
        LvUser4: Record "User Setup";
        GvUsers: Record User;
        LCYCode: Code[20];
        CurrencyCode: Code[20];
        GeneralLedgerSetup: Record "General Ledger Setup";
        gvDimensionLabel: array[8] of Text;
        i: Integer;
        DimensionSetEntry: Record "Dimension Set Entry";
        DimName: array[8] of Text;
        DimCode: array[8] of Code[20];
        hide: Integer;

    /// <summary>
    /// Description for InitTextVariable.
    /// </summary>
    procedure InitTextVariable();
    begin
        OnesText[1] := 'ONE';
        OnesText[2] := 'TWO';
        OnesText[3] := 'THREE';
        OnesText[4] := 'FOUR';
        OnesText[5] := 'FIVE';
        OnesText[6] := 'SIX';
        OnesText[7] := 'SEVEN';
        OnesText[8] := 'EIGHT';
        OnesText[9] := 'NINE';
        OnesText[10] := 'TEN';
        OnesText[11] := 'ELEVEN';
        OnesText[12] := 'TWELVE';
        OnesText[13] := 'THIRTEEN';
        OnesText[14] := 'FOURTEEN';
        OnesText[15] := 'FIFTEEN';
        OnesText[16] := 'SIXTEEN';
        OnesText[17] := 'SEVENTEEN';
        OnesText[18] := 'EIGHTEEN';
        OnesText[19] := 'NINETEEN';

        TensText[1] := '';
        TensText[2] := 'TWENTY';
        TensText[3] := 'THIRTY';
        TensText[4] := 'FORTY';
        TensText[5] := 'FIFTY';
        TensText[6] := 'SIXTY';
        TensText[7] := 'SEVENTY';
        TensText[8] := 'EIGHTY';
        TensText[9] := 'NINETY';

        ExponentText[1] := '';
        ExponentText[2] := 'THOUSAND';
        ExponentText[3] := 'MILLION';
        ExponentText[4] := 'BILLION';
    end;

    /// <summary>
    /// Description for FormatNoText.
    /// </summary>
    /// <param name="NoText">Parameter of type array [2] of Text[80].</param>
    /// <param name="No">Parameter of type Decimal.</param>
    procedure FormatNoText(var NoText: array[2] of Text[80]; No: Decimal);
    var
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
    begin
        CLEAR(NoText);
        NoTextIndex := 1;
        NoText[1] := '****';

        IF No < 1 THEN
            AddToNoText(NoText, NoTextIndex, PrintExponent, 'ZERO')
        ELSE BEGIN
            FOR Exponent := 4 DOWNTO 1 DO BEGIN
                PrintExponent := FALSE;
                Ones := No DIV POWER(1000, Exponent - 1);
                Hundreds := Ones DIV 100;
                Tens := (Ones MOD 100) DIV 10;
                Ones := Ones MOD 10;
                IF Hundreds > 0 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, 'HUNDRED');
                END;
                IF Tens >= 2 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    IF Ones > 0 THEN
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                END ELSE
                    IF (Tens * 10 + Ones) > 0 THEN
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                IF PrintExponent AND (Exponent > 1) THEN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                No := No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(1000, Exponent - 1);
            END;
        END;

        //IF "Purchase Line"."Currency Code" = '' THEN
        AddToNoText(NoText, NoTextIndex, PrintExponent, GLSetup."LCY Code"); // LCY
                                                                             //ELSE
                                                                             //AddToNoText(NoText,NoTextIndex,PrintExponent,("Purchase Line"."Currency Code"));

        AddToNoText(NoText, NoTextIndex, PrintExponent, ' SHILLINGS');
        AddToNoText(NoText, NoTextIndex, PrintExponent, 'ONLY ****');
    end;

    /// <summary>
    /// Description for AddToNoText.
    /// </summary>
    /// <param name="NoText">Parameter of type array [2] of Text[80].</param>
    /// <param name="NoTextIndex">Parameter of type Integer.</param>
    /// <param name="PrintExponent">Parameter of type Boolean.</param>
    /// <param name="AddText">Parameter of type Text[30].</param>
    local procedure AddToNoText(var NoText: array[2] of Text[80]; var NoTextIndex: Integer; var PrintExponent: Boolean; AddText: Text[30]);
    begin
        PrintExponent := TRUE;

        WHILE STRLEN(NoText[NoTextIndex] + ' ' + AddText) > MAXSTRLEN(NoText[1]) DO BEGIN
            NoTextIndex := NoTextIndex + 1;
            IF NoTextIndex > ARRAYLEN(NoText) THEN
                ERROR('%1 results in a written number that is too long.', AddText);
        END;

        NoText[NoTextIndex] := DELCHR(NoText[NoTextIndex] + ' ' + AddText, '<');
    end;

    /// <summary>
    /// Description for GetApprovers.
    /// </summary>
    procedure GetApprovers();
    var
        i: Integer;
        LvPurchReq: Record "NFL Requisition Header";
        LvApprovalEntry: Record "Approval Entry";
        ApproverName: array[5] of Text[80];
        LvUser: Record User;
        EscalatedByUser: Record User;
    begin
        //Get approvers
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Table ID", '50075');
        LvApprovalEntry.SETFILTER(LvApprovalEntry."Document No.", "Payment Voucher Header"."No.");
        LvApprovalEntry.SETFILTER(LvApprovalEntry.Status, 'Approved');
        i := 1;

        IF LvApprovalEntry.FIND('-') THEN
            REPEAT
                ApproverID[i] := LvApprovalEntry."Approver ID";
                EscalationID[i] := LvApprovalEntry."Escalated by";
                ApproverDate[i] := LvApprovalEntry."Last Date-Time Modified";
                User.SETRANGE("User Name", ApproverID[i]);
                IF User.FINDFIRST THEN BEGIN
                    FullNames[i] := User."Full Name";
                END;

                EscalatedByUser.SETRANGE("User Name", EscalationID[i]);
                IF EscalatedByUser.FIND('-') THEN BEGIN
                    EscalatedByName[i] := EscalatedByUser."Full Name";
                END;
                i += 1;
            UNTIL LvApprovalEntry.NEXT = 0;
        //MAG - END

    end;
}

