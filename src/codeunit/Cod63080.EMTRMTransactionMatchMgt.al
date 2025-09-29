codeunit 63080 "EMTRM Transaction Match Mgt."
{

    Permissions = TableData "G/L Entry" = M;

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
        lblUpdatedTransactions: Label '%1 G/L Entries that are linked to a matched Expense and Bank Transaction have been updated with the Bank Transaction Entry No.', Locked = false, Comment = 'Label for the updated transactions, %1 will be replaced with number of processed entries';
    begin
        // Filter non-processed entries in Expense Match table
        ExpenseMatch.SetCurrentKey("Processed");
        ExpenseMatch.SetLoadFields("Expense Entry No.", "Transaction Entry No.", Processed);
        ExpenseMatch.SetRange("Processed", false);
        if not ExpenseMatch.IsEmpty then begin
            // Set loadfields
            Expense.SetLoadFields("Entry No.", "Created Doc. ID", Posted, "Settlement No.");
            BankTransaction.SetLoadFields("Entry No.", "Posted Doc. ID");
            ExpenseMatchModify.SetLoadFields("Expense Entry No.", "Transaction Entry No.", Processed);

            // Iterate and process each entry
            ExpenseMatch.FindSet();
            repeat
                // Get related expense and bank transaction entries and update G/L Entry
                if (Expense.Get(ExpenseMatch."Expense Entry No.") AND BankTransaction.Get(ExpenseMatch."Transaction Entry No.")) then begin
                    // Ensure the Expense is posted before updating G/L entries
                    if Expense.Posted then
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
        // Prepare GLEntry record
        GLEntry.SetLoadFields("Entry No.", "Document No.", "External Document No.");
        GLEntry.SetCurrentKey("Document No.", "Posting Date");

        // Find and update GL entries linked to Expense Entry
        GLEntry.SetRange("Document No.", Expense."Created Doc. ID");
        GLEntry.SetRange("Posting Date", Expense."Posting Date");
        if Expense."Settlement No." <> '' then
            // If there is a settlement number, we need to identify the G/L Entry by External Document No. (e.g. "EXPENSE 123")
            GLEntry.SetRange("External Document No.", STRSUBSTNO('%1 %2', Expense.TABLECAPTION, Expense."Entry No."));

        if GLEntry.IsEmpty then
            exit;

        if GLEntry.FindSet() then
            repeat
                GLEntry."Bank Transaction Entry No." := BankTransaction."Entry No.";
                GLEntry.Modify(false);
            until GLEntry.Next = 0;

        // Find and update GL entries linked to Bank Transaction Entry
        GLEntry.SetRange("Document No.", BankTransaction."Posted Doc. ID");
        GLEntry.SetRange("Posting Date", BankTransaction."Posting Date");
        GLEntry.SetRange("External Document No.");
        if GLEntry.IsEmpty then
            exit;

        if GLEntry.FindSet() then
            repeat
                GLEntry."Bank Transaction Entry No." := BankTransaction."Entry No.";
                GLEntry.Modify();
            until GLEntry.Next = 0;

        exit(true)
    end;

    procedure ResetProcessedEntries()
    var
        ExpenseMatch: Record "CEM Expense Match";
        GLEntry: Record "G/L Entry";
    begin
        ExpenseMatch.SetCurrentKey("Processed");
        ExpenseMatch.SetRange("Processed", true);
        if ExpenseMatch.IsEmpty then
            exit;

        if ExpenseMatch.FindSet() then
            repeat
                GLEntry.SetRange("Bank Transaction Entry No.", ExpenseMatch."Transaction Entry No.");
                if not GLEntry.IsEmpty then
                    GLEntry.ModifyAll("Bank Transaction Entry No.", 0);

                ExpenseMatch."Processed" := false;
                ExpenseMatch.Modify(false);
            until ExpenseMatch.Next = 0;

        // Finally, reset the processed status in the Expense Match table
        ExpenseMatch.ModifyAll(Processed, false);
    end;
}
