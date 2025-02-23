codeunit 63080 "EMADV Transaction Match Mgt."
{

    Permissions = TableData 17 = rimd;
    procedure UpdateAccountsExpenseEntries() UpdatedEntries: Integer
    var
        ExpenseMatch: Record "CEM Expense Match";
        ExpenseMatchModify: Record "CEM Expense Match";
        Expense: Record "CEM Expense";
        BankTransaction: Record "CEM Bank Transaction";
    begin
        ExpenseMatch.SetCurrentKey("Processed");
        ExpenseMatch.SetRange("Processed", false);
        if ExpenseMatch.IsEmpty then
            exit(0);

        ExpenseMatch.FindSet();
        repeat
            // Get related expense and bank transaction entries and update G/L Entry
            if (Expense.Get(ExpenseMatch."Expense Entry No.") AND BankTransaction.Get(ExpenseMatch."Transaction Entry No.")) then begin
                if UpdateGLEntry(Expense, BankTransaction) then begin
                    UpdatedEntries += 1;
                    if ExpenseMatchModify.GetBySystemId(ExpenseMatch.SystemId) then begin
                        ExpenseMatchModify."Processed" := true;
                        ExpenseMatchModify.Modify();
                    end;
                end
            end;
        until ExpenseMatch.Next = 0;
    end;

    local procedure UpdateGLEntry(Expense: Record "CEM Expense"; BankTransaction: Record "CEM Bank Transaction"): Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Document No.");

        // Find and update GL entries linked to Expense Entry
        GLEntry.SetRange("Document No.", Expense."Created Doc. ID");
        if GLEntry.IsEmpty then
            exit;

        GLEntry.FindSet();
        repeat
            GLEntry."Expense Entry No." := Expense."Entry No.";
            GLEntry.Modify();
        until GLEntry.Next = 0;

        // Find and update GL entries linked to Bank Transaction Entry
        GLEntry.SetRange("Document No.", BankTransaction."Posted Doc. ID");
        if GLEntry.IsEmpty then
            exit;

        GLEntry.FindSet();
        repeat
            GLEntry."Expense Entry No." := Expense."Entry No.";
            GLEntry.Modify();
        until GLEntry.Next = 0;

        exit(true)
    end;

    procedure ResetProcessedEntries()
    var
        ExpenseMatch: Record "CEM Expense Match";
    begin
        ExpenseMatch.SetCurrentKey("Processed");
        ExpenseMatch.SetRange("Processed", true);
        if ExpenseMatch.IsEmpty then
            exit;

        ExpenseMatch.ModifyAll(Processed, false);
    end;
}
