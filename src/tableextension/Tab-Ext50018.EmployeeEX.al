/// <summary>
/// TableExtension "EmployeeEX" (ID 50039) extends Record Employee.
/// </summary>
tableextension 50018 EmployeeEX extends Employee
{
    DrillDownPageId = Employees;
    LookupPageId = Employees;

    fields
    {
        // Add changes to table fields here
        field(50102; PIN; Text[30])
        {
        }
        field(50103; "Visa No."; Text[30])
        {
        }
        field(50104; "Visa End Date"; Date)
        {
        }
        field(50127; "Leave Category"; Code[10])
        {
            Description = 'Used in leave';
            Editable = false;
            //TableRelation = "HRM Leave Categories".Code;

            // trigger OnValidate();
            // begin
            //     //HRM1.0
            //     rLeaveCategory.GET("Leave Category");
            //     "Annual Leave Days Entitlement":= rLeaveCategory.Quantity;
            //     "Annual Leave Days Type":=rLeaveCategory."Annual Leave Days Type";
            //     MODIFY;

            //     "Leave Balance":="Annual Leave Days Entitlement"-"Leave Days used";
            //     rLeaveCategory.SETRANGE(Code,"Leave Category");
            //     IF rLeaveCategory.FINDLAST THEN BEGIN
            //     "Annual Leave Days Entitlement":= rLeaveCategory.Quantity;
            //     "Annual Leave Days Type":=rLeaveCategory."Annual Leave Days Type";
            //     MODIFY;
            //     END;
            //     //"Leave Balance":="Annual Leave Days Entitlement"-"Leave Days used";
            //     //VALIDATE("Annual Leave Days Entitlement");
            //     //"Leave Balance":="Annual Leave Days Entitlement"+qty - "Leave Days used";
            // end;
        }
        field(50128; "WC Leave Days used"; Decimal)
        {
            // CalcFormula = Sum("HRM Employee Ledger Entry".Quantity WHERE (HRM Document Type=CONST(Absence),
            //                                                               Employee No.=FIELD(No.),
            //                                                               Is leave=CONST(Yes),
            //                                                               Leave Entry Type=FILTER(Use|Deduct),
            //                                                               WC Leave=CONST(Yes)));
            // Description = 'Used in leave';
            // FieldClass = FlowField;

            // trigger OnValidate();
            // begin
            //     //"Leave Balance":="Annual Leave Days Entitlement"-"Leave Days used";
            //     //VALIDATE("Annual Leave Days Entitlement");
            //     //"Leave Balance":="Annual Leave Days Entitlement"+qty - "Leave Days used";
            // end;
        }
        field(50129; "Sick Leave Days used"; Decimal)
        {
            // CalcFormula = Sum("HRM Employee Ledger Entry".Quantity WHERE (HRM Document Type=CONST(Absence),
            //                                                               Employee No.=FIELD(No.),
            //                                                               Is leave=CONST(Yes),
            //                                                               WC Leave=CONST(No),
            //                                                               Sick Leave=CONST(Yes)));
            // Description = 'Used in leave';
            // FieldClass = FlowField;

            // trigger OnValidate();
            // begin
            //     //"Leave Balance":="Annual Leave Days Entitlement"-"Leave Days used";

            //     //VALIDATE("Annual Leave Days Entitlement");
            //     //"Leave Balance":="Annual Leave Days Entitlement"+qty - "Leave Days used";
            // end;
        }
        field(50130; "Allow Accrual without Loss"; Boolean)
        {
        }
        field(50131; "Med. Policy Group"; Code[30])
        {
            // TableRelation = "Employee Medical Groups"."Employee Group";
        }
        field(50132; USERID1; Code[10])
        {
            TableRelation = "User Setup"."User ID";

            trigger OnValidate();
            var
                lvEmployee: Record Employee;
            begin
                //rgk unique user id for employees
                /*
                IF "USER ID"<>'' THEN BEGIN
                lvEmployee.RESET;
                lvEmployee.SETFILTER(lvEmployee.USERID1,USERID);
                IF lvEmployee.FINDFIRST THEN  MESSAGE('found');
                  IF lvEmployee."No."<>"No." THEN
                    ERROR('Employee Number %1 has the same User ID. Choose a unique User ID',lvEmployee."No.")
                END;
                */

                lvEmployee.RESET;
                lvEmployee.SETRANGE(lvEmployee.USERID1, USERID);
                IF lvEmployee.FINDFIRST THEN MESSAGE('found');
                IF lvEmployee."No." <> "No." THEN
                    ERROR('Employee Number %1 has the same User ID. Choose a unique User ID', lvEmployee."No.")

            end;
        }
        field(50133; "Overide Max Leave Carry Over"; Boolean)
        {
            Description = 'Used in leave';
        }
        field(50134; "Leave Allowance Payment Group"; Code[10])
        {
            //TableRelation = "Leave Allowance Payment Groups".Code;
        }
        field(50135; "Training Group"; Code[10])
        {
            // Description = 'used in training';
            // TableRelation = "Training Groups".Code;

            // trigger OnValidate();
            // begin
            //     recRecomTrain.SETRANGE(recRecomTrain."Employee No.","No.");
            //     recRecomTrain.VALIDATE(recRecomTrain."Training Group","Training Group");
            // end;
        }
        field(50136; Type; Option)
        {
            Caption = 'Type';
            InitValue = Person;
            OptionCaption = 'Company,Person';
            OptionMembers = Company,Person;
        }
        field(50137; "Applicant No."; Code[10])
        {
        }
        field(50138; "Leave Balance"; Decimal)
        {
            Description = 'Leave';
            Editable = false;
        }
        field(50141; "Leave Allowance Accruals"; Decimal)
        {
            // CalcFormula = Sum("Leave Allowance Ledger Entry"."Leave Allowance Count" WHERE (Employee No.=FIELD(No.)));
            // FieldClass = FlowField;
        }
        field(50142; Blacklisted; Boolean)
        {
            Description = 'recruitment';

            // trigger OnValidate();
            // begin
            //     recApplicant.SETCURRENTKEY(recApplicant."National ID Number",recApplicant.Blacklisted);
            //     recApplicant.SETRANGE(recApplicant."National ID Number","National ID");
            //     recApplicant.SETRANGE(recApplicant.Blacklisted,FALSE);
            //     IF recApplicant.FIND('-') THEN BEGIN
            //      recApplicant.Blacklisted:=Blacklisted;
            //      recApplicant.MODIFY;
            //      MESSAGE('Applicant number %1 has been blacklisted as well',recApplicant."National ID Number");
            //      END
            //      ELSE BEGIN
            //      recApplicant.Blacklisted:=FALSE;
            //      recApplicant.MODIFY;
            //      END
            // end;
        }
        field(50143; "Sick Leave Balance"; Decimal)
        {
            Description = 'Leave';
        }
        field(50144; "Expected Termination Date"; Date)
        {
        }
        field(50145; Spouse; Code[40])
        {
            // TableRelation = Contact;

            trigger OnValidate();
            var
                lvEmp: Record Employee;
            begin
                IF "No." = Spouse THEN
                    FIELDERROR(Spouse, 'can''t be the same as employee number')
                ELSE
                    IF lvEmp.GET(Spouse) THEN BEGIN
                        IF Gender = lvEmp.Gender THEN
                            IF NOT CONFIRM('Same gender for spouse?', FALSE) THEN
                                ERROR('Input the correct spouse');
                    END;
            end;
        }
        field(50146; "Housing Eligibility"; Option)
        {
            OptionCaption = '" ,House,House Allowance,Both"';
            OptionMembers = " ",House,"House Allowance",Both;
        }
        field(50147; "Housing Blacklisted"; Boolean)
        {
            Editable = false;
        }
        field(50148; Acting; Boolean)
        {
            Editable = true;
        }
        field(50149; "Acting Position"; Code[20])
        {
            Editable = false;
            //TableRelation = "HRM Position".No.;
        }
        field(50150; "Accrued Leave"; Decimal)
        {
            MinValue = 0;

            // trigger OnValidate();
            // begin
            //     accrual:=0;
            //     //Finds any entries of type Accrual
            //     empledgentry.SETFILTER("HRM Document Type",'%1',empledgentry."HRM Document Type"::Absence);
            //     empledgentry.SETFILTER("Employee No.","No.");
            //     empledgentry.SETFILTER("Is leave",'%1',TRUE);
            //     empledgentry.SETFILTER("Leave Entry Type",'%1',empledgentry."Leave Entry Type"::Accrue);
            //     empledgentry.SETFILTER("WC Leave",'%1',FALSE);
            //     empledgentry.SETFILTER("Sick Leave",'%1',FALSE);
            //     IF empledgentry.FINDFIRST THEN BEGIN
            //       REPEAT
            //         accrual:=accrual+empledgentry.Quantity;
            //       UNTIL empledgentry.NEXT=0;
            //       "Accrued Leave":=accrual;
            //     END;
            // end;
        }
        field(50151; "Acting Days Type"; Option)
        {
            OptionMembers = "Working Days","Consecutive Days";
        }
        field(50152; "Leave Category Affln Date"; Date)
        {
            Description = 'Leave category Affiliation Date';
        }
        field(50153; Name; Text[40])
        {
        }
        field(50154; "Position Group"; Code[20])
        {
            //TableRelation = "HRM Position Groups".Code;
        }
        field(50155; "House No."; Code[20])
        {
            //TableRelation = "HRM House"."House No.";
        }
        field(50157; "Leave Balance Date"; Date)
        {
        }
        field(50159; "District Code"; Code[10])
        {
            //TableRelation = "HRM Districts".Code;
        }
        field(50160; Category; Option)
        {
            OptionMembers = Management,Supervisors,"Upper-tier","Lower-tier";
        }
        field(50161; "Div. Code"; Option)
        {
            OptionMembers = KARIRANA,MUTOSI,MUKEU,"FIELD",ADMIN,FACTORY,EXTENSION;
        }
        field(50162; "Data Category"; Text[30])
        {
            TableRelation = Employee;
        }
        field(50163; "Print Payslip"; Boolean)
        {
            InitValue = true;
        }
        field(50164; "Insurance Company"; Text[50])
        {
        }
        field(50165; "Employment Type"; Option)
        {
            OptionMembers = Permanent,Casuals;
        }
        field(50166; "Category Code"; Code[10])
        {
        }
        field(50167; "House Eligibility"; Option)
        {
            OptionCaption = '" ,Housed,House Allowance,Both"';
            OptionMembers = " ",Housed,"House Allowance",Both;
        }
        field(50169; "Gang No."; Code[10])
        {
            // TableRelation = Outlet.Code;
        }
        field(50170; "Employee Anniversary Date"; Date)
        {
        }
        field(50171; "Gratuity Eligible Days"; Integer)
        {
            Description = '//For gratuity Computation';
        }
        field(50172; Claims; Decimal)
        {
        }

        ///////////////////
        ///
        field(50175; "Work Permit No."; Text[30])
        {
        }
        field(50176; "Work Permit End Date"; Date)
        {
        }
        field(50177; "Branch Code"; Code[10])
        {
        }
        field(50178; "Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(50179; Affiliated; Boolean)
        {
            Editable = true;
        }
        field(50180; "Affiliation Class"; Option)
        {
            Editable = false;
            OptionMembers = " ","Employee(Permanent)",Casual,Apprentice,Attachment,Seasonal,Contract;
        }
        field(50181; "Affiliation Date"; Date)
        {
        }
        field(50182; "First Affiliation Date"; Date)
        {
        }
        field(50183; "Affiliation Expiry Date"; Date)
        {
        }
        field(50184; "Location Filter"; Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = Location.Code;
        }
        field(50185; "Annual Leave Days Entitlement"; Decimal)
        {
            Description = 'Used in leave';

            // trigger OnValidate();
            // begin
            //     CALCFIELDS("Leave Days used");

            //     qty:=0;
            //     //Finds any entries of type Opening Balance
            //     empledgentry.SETFILTER("HRM Document Type",'%1',empledgentry."HRM Document Type"::Absence);
            //     empledgentry.SETFILTER("Employee No.","No.");
            //     empledgentry.SETFILTER("Is leave",'%1',TRUE);
            //     empledgentry.SETFILTER("Leave Entry Type",'%1',empledgentry."Leave Entry Type"::"Opening Balance");
            //     empledgentry.SETFILTER("WC Leave",'%1',FALSE);
            //     empledgentry.SETFILTER("Sick Leave",'%1',FALSE);
            //     IF empledgentry.FINDFIRST THEN BEGIN
            //       REPEAT
            //         qty:=qty+empledgentry.Quantity;
            //       UNTIL empledgentry.NEXT=0;
            //     END;
            //     "Leave Balance":="Annual Leave Days Entitlement" - "Leave Days used";
            // end;
        }
        field(50186; "Annual Leave Days Type"; Option)
        {
            Description = 'Used in leave';
            OptionMembers = "Working Days","Consecutive Days";
        }
        field(50187; "Base Calendar Code"; Code[10])
        {
            Description = 'Used in leave';
            InitValue = 'NV';
            TableRelation = "Base Calendar".Code;
        }
        field(50188; "Leave Days used"; Decimal)
        {
            // CalcFormula = Sum("HRM Employee Ledger Entry".Quantity WHERE (HRM Document Type=CONST(Absence),
            //                                                               Employee No.=FIELD(No.),
            //                                                               Is leave=CONST(Yes),
            //                                                               Leave Entry Type=FILTER(Use|Deduct),
            //                                                               WC Leave=CONST(No),
            //                                                               Sick Leave=CONST(No)));
            // Description = 'Used in leave';
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                CALCFIELDS("Leave Days used");
                //VALIDATE("Annual Leave Days Entitlement");
                // VALIDATE("Leave Balance",("Annual Leave Days Entitlement"-"Leave Days used"));
            end;
        }
    }

    var
        myInt: Integer;
}