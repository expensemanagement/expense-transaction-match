codeunit 63080 "EMADV Transaction Match Mgt."
{

    Permissions = TableData 17 = rimd;

    trigger OnRun()
    begin
        Code;
    end;

    local procedure "Code"()
    begin
        UpdateAccountsExpenseEntries(false);
    end;

    procedure UpdateAccountsExpenseEntries(ShowMessage: Boolean)
    var
        ExpenseMatch: Record "CEM Expense Match";
        ExpenseMatchModify: Record "CEM Expense Match";
        Expense: Record "CEM Expense";
        BankTransaction: Record "CEM Bank Transaction";
        UpdatedEntries: Integer;
        lblUpdatedTransactions: Label '%1 G/L Entries have been updated with the Ext. Document No. of the related Expense', Locked = false, Comment = 'Label for the updated transactions, %1 will be replaced with number of processed entries';
    begin
        // Filter non-processed entries in Expense Match table
        ExpenseMatch.SetCurrentKey("Processed");
        ExpenseMatch.SetLoadFields("Expense Entry No.", "Transaction Entry No.", Processed);
        ExpenseMatch.SetRange("Processed", false);
        if not ExpenseMatch.IsEmpty then begin
            // Set loadfields
            Expense.SetLoadFields("Entry No.", "Created Doc. ID");
            BankTransaction.SetLoadFields("Entry No.", "Posted Doc. ID");

            // Iterate and process each entry
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

        if ShowMessage then
            Message(lblUpdatedTransactions, UpdatedEntries);
    end;

    local procedure UpdateGLEntry(var Expense: Record "CEM Expense"; var BankTransaction: Record "CEM Bank Transaction"): Boolean
    var
        GLEntry: Record "G/L Entry";
        ExpenseExtDocNo: Code[35];
    begin
        GLEntry.SetLoadFields("Entry No.", "Document No.", "External Document No.");
        GLEntry.SetCurrentKey("Document No.");

        // Find and update GL entries linked to Expense Entry
        GLEntry.SetRange("Document No.", Expense."Created Doc. ID");
        if GLEntry.IsEmpty then
            exit;

        if GLEntry.FindFirst() then
            ExpenseExtDocNo := GLEntry."External Document No.";

        // Find and update GL entries linked to Bank Transaction Entry
        GLEntry.SetRange("Document No.", BankTransaction."Posted Doc. ID");
        if GLEntry.IsEmpty then
            exit;

        GLEntry.FindSet();
        repeat
            GLEntry."External Document No." := ExpenseExtDocNo;
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
