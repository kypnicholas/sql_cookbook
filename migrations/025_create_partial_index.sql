-- Create a partial index on `invoice(invoice_date)` where `total > 100` to optimize queries that filter for invoices with a total greater than 100.

CREATE INDEX IF NOT EXISTS idx_invoice_date_total_gt_100
ON invoice (invoice_date)
WHERE total > 100;
