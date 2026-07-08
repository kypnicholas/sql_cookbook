
-- Create index on invoice_date column of invoice table to optimize filtering in WHERE clause
CREATE INDEX IF NOT EXISTS idx_invoice_invoice_date
ON public.invoice (invoice_date);

-- Create index on invoice_id column of invoice_line table to optimize joins with invoice table
CREATE INDEX IF NOT EXISTS idx_invoice_line_invoice_id
ON public.invoice_line (invoice_id);

-- Create index on track_id column of invoice_line table to optimize joins with track table
CREATE INDEX IF NOT EXISTS idx_invoice_line_track_id
ON public.invoice_line (track_id);