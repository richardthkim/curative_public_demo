SELECT test_kits.barcode AS test_kits_barcode, 
CASE WHEN SUBSTRING(patients.zipcode,1,5) IN ('76574', '78605', '78610', '78612', '78613', '78615', '78616', '78617', '78620', '78621', '78626', '78628', '78634', '78640', '78641', '78642', '78644', '78645', '78652', '78653', '78654', '78660', '78663', '78664', '78665', '78669', '78681', '78701', '78702', '78703', '78704', '78705', '78712', '78717', '78719', '78721', '78722', '78723', '78724', '78725', '78726', '78727', '78728', '78729', '78730', '78731', '78732', '78733', '78734', '78735', '78736', '78737', '78738', '78739', '78741', '78742', '78744', '78745', '78746', '78747', '78748', '78749', '78750', '78751', '78752', '78753', '78754', '78756', '78757', '78758', '78759')
        AND alinity_results.cn < 26
        THEN 'APH < 26'
    WHEN  SUBSTRING(patients.zipcode,1,5) IN ('76574', '78605', '78610', '78612', '78613', '78615', '78616', '78617', '78620', '78621', '78626', '78628', '78634', '78640', '78641', '78642', '78644', '78645', '78652', '78653', '78654', '78660', '78663', '78664', '78665', '78669', '78681', '78701', '78702', '78703', '78704', '78705', '78712', '78717', '78719', '78721', '78722', '78723', '78724', '78725', '78726', '78727', '78728', '78729', '78730', '78731', '78732', '78733', '78734', '78735', '78736', '78737', '78738', '78739', '78741', '78742', '78744', '78745', '78746', '78747', '78748', '78749', '78750', '78751', '78752', '78753', '78754', '78756', '78757', '78758', '78759')
        AND alinity_results.cn < 30
        THEN 'APH 26-30'
    WHEN (testing_sites.state = 'NM' AND patients.state = 'NM')
        AND alinity_results.cn < 26
        THEN 'Strong NM < 26'
    WHEN (testing_sites.state = 'NM' AND patients.state = 'NM')
        AND alinity_results.cn < 30
        THEN 'Strong NM 26-30'
    WHEN alinity_results.cn < 26
        THEN 'Strong Positive'
    ELSE 'Weak Positive'
END AS repeat_room_bucket,
Box.barcode AS box_barcode, 
appointments.result, 
alinity_results.cn , 
appointments.released_at AT TIME ZONE labs.time_zone AS appointments_released_at_lab_timezone, 
alinity_messages.alinity_machine_name, 
CASE WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00797' THEN 'A1'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00798' THEN 'A2'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00796' THEN 'A3'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00795' THEN 'A4'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00779' THEN 'A5'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00792' THEN 'A6'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00794' THEN 'A7'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00793' THEN 'A8'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00773' THEN 'B1'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00775' THEN 'B2'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00776' THEN 'B3'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00774' THEN 'B4'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00772' THEN 'B5'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00768' THEN 'B6'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00762' THEN 'B7'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00767' THEN 'B8'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00766' THEN 'C1'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00761' THEN 'C2'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00771' THEN 'C3'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00770' THEN 'C4'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00769' THEN 'C5'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00699' THEN 'D1'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00700' THEN 'D2'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00698' THEN 'D3'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00704' THEN 'D4'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00697' THEN 'E1'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00696' THEN 'E2'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00702' THEN 'E3'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00701' THEN 'E4'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00705' THEN 'E5'
    WHEN SUBSTRING(alinity_messages.alinity_machine_name,1,16) = 'Alinity m-M00703' THEN 'E6'
END AS local_machine_name,
CASE WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00797', 'Alinity m-M00798', 'Alinity m-M00796', 'Alinity m-M00795', 'Alinity m-M00779', 'Alinity m-M00792', 'Alinity m-M00794', 'Alinity m-M00793') THEN 'A'
    WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00773', 'Alinity m-M00775', 'Alinity m-M00776', 'Alinity m-M00774', 'Alinity m-M00772', 'Alinity m-M00768', 'Alinity m-M00762', 'Alinity m-M00767') THEN 'B'
    WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00766', 'Alinity m-M00761', 'Alinity m-M00771', 'Alinity m-M00770', 'Alinity m-M00769') THEN 'C'
    WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00699', 'Alinity m-M00700', 'Alinity m-M00698', 'Alinity m-M00704') THEN 'D'
    WHEN SUBSTRING(alinity_messages.alinity_machine_Name,1,16) IN ('Alinity m-M00697', 'Alinity m-M00696', 'Alinity m-M00702', 'Alinity m-M00701', 'Alinity m-M00705', 'Alinity m-M00703') THEN 'E'
END AS local_machine_room

FROM alinity_results
    INNER JOIN (
        SELECT alinity_results.tube_barcode, MAX(alinity_results.created_at) AS created_at from alinity_results group by alinity_results.tube_barcode
    ) AS alinity_results_agg on alinity_results.tube_barcode = alinity_results_agg.tube_barcode AND alinity_results.created_at = alinity_results_agg.created_at
    LEFT JOIN alinity_messages on alinity_results.alinity_message_id = alinity_messages.id
    LEFT JOIN test_kits on test_kits.barcode = alinity_results.tube_barcode
    LEFT JOIN appointments on test_kits.appointment_id = appointments.id
    LEFT JOIN Box on Box.id = appointments.box_id
    LEFT JOIN labs on labs.id = appointments.accessioned_lab_id
    LEFT JOIN testing_sites on testing_sites.id = appointments.testing_site_id
    LEFT JOIN patients on patients.id = appointments.patient_id

WHERE TRUE
    AND appointments.result = 'POSITIVE'
    AND SUBSTRING(Box.barcode, 1, 8) = 'ARACK-TX'
    AND appointments.accessioned_lab_id = '3'
    AND appointments.resulted_at >= CURRENT_TIMESTAMP + INTERVAL '-24 hour'

ORDER BY test_kits.barcode