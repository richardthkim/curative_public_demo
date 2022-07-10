SELECT local_machine_room, repeat_room_racks, COUNT(*)
FROM (
    SELECT
    CASE WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00797', 'Alinity m-M00798', 'Alinity m-M00796', 'Alinity m-M00795', 'Alinity m-M00779', 'Alinity m-M00792', 'Alinity m-M00794', 'Alinity m-M00793') THEN 'A'
        WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00773', 'Alinity m-M00775', 'Alinity m-M00776', 'Alinity m-M00774', 'Alinity m-M00772', 'Alinity m-M00768', 'Alinity m-M00762', 'Alinity m-M00767') THEN 'B'
        WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00766', 'Alinity m-M00761', 'Alinity m-M00771', 'Alinity m-M00770', 'Alinity m-M00769') THEN 'C'
        WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00699', 'Alinity m-M00700', 'Alinity m-M00698', 'Alinity m-M00704') THEN 'D'
        WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00697', 'Alinity m-M00696', 'Alinity m-M00702', 'Alinity m-M00701', 'Alinity m-M00705', 'Alinity m-M00703') THEN 'E'
    END AS local_machine_room,
    CASE WHEN appointments.result IN ('NEGATIVE', 'INDETERMINATE') THEN 'Negative Rack'
        WHEN appointments.result = 'POSITIVE' THEN 'Positive Rack'
    END AS repeat_room_racks
    
    FROM alinity_results
        INNER JOIN (
            SELECT alinity_results.tube_barcode, MAX(alinity_results.created_at) AS created_at FROM alinity_results GROUP BY alinity_results.tube_barcode
        ) AS alinity_results_agg on alinity_results.tube_barcode = alinity_results_agg.tube_barcode AND alinity_results.created_at = alinity_results_agg.created_at
        LEFT JOIN alinity_messages on alinity_results.alinity_message_id = alinity_messages.id
        LEFT JOIN test_kits on test_kits.barcode = alinity_results.tube_barcode
        LEFT JOIN appointments on test_kits.appointment_id = appointments.id
        LEFT JOIN Box on Box.id = appointments.box_id
    
    WHERE TRUE
        AND appointments.result IN ('NEGATIVE', 'INDETERMINATE', 'POSITIVE')
        AND SUBSTRING(Box.barcode, 1, 8) = 'ARACK-TX'
        AND appointments.accessioned_lab_id = '3'
        AND appointments.resulted_at >= CURRENT_TIMESTAMP + (INTERVAL '-24 hour')

GROUP BY local_machine_room, repeat_room_racks