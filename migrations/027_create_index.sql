
-- Create index on invoice_date column of invoice table to optimize filtering in WHERE clause
CREATE INDEX IF NOT EXISTS idx_invoice_invoice_date
ON public.invoice (invoice_date);