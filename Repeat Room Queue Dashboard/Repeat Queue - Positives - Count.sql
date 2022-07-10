SELECT COUNT(*)

FROM alinity_results
    INNER JOIN (
        SELECT alinity_results.tube_barcode, MAX(alinity_results.created_at) AS created_at FROM alinity_results GROUP BY alinity_results.tube_barcode
    ) AS alinity_results_agg on alinity_results.tube_barcode = alinity_results_agg.tube_barcode AND alinity_results.created_at = alinity_results_agg.created_at
    LEFT JOIN test_kits on test_kits.barcode = alinity_results.tube_barcode
    LEFT JOIN appointments on test_kits.appointment_id = appointments.id
    LEFT JOIN Box on Box.id = appointments.box_id

WHERE TRUE
    AND appointments.result = 'POSITIVE'
    AND SUBSTRING(Box.barcode, 1, 8) = 'ARACK-TX'
    AND appointments.accessioned_lab_id = '3'
    AND appointments.resulted_at >= CURRENT_TIMESTAMP + INTERVAL '-24 hour'