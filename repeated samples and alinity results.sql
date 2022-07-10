WITH repeated_samples AS (
    SELECT *
    FROM (
        SELECT alinity_results.tube_barcode, COUNT(*)
        FROM alinity_messages
            LEFT JOIN alinity_results ON alinity_messages.id = alinity_results.alinity_message_id
        WHERE TRUE
            AND lab_id = 3
            AND alinity_messages.created_at >= CURRENT_DATE - INTERVAL '11 day' --get all the results within past 6 days
        GROUP BY alinity_results.tube_barcode
    ) AS sample_scan_count
    WHERE sample_scan_count.Count = 2
)
SELECT alinity_results.created_at, alinity_results.tube_barcode, alinity_results.interpretation, alinity_results.time_of_analysis, alinity_results.cn, 
    alinity_messages.lab_id, alinity_messages.alinity_machine_name, 
    SUBSTRING(alinity_messages.alinity_machine_name, 1, 16) AS machine_name
FROM repeated_samples
    LEFT JOIN alinity_results ON alinity_results.tube_barcode = repeated_samples.tube_barcode
    LEFT JOIN alinity_messages ON alinity_results.alinity_message_id = alinity_messages.id 