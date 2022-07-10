SELECT repeat_room_bucket, COUNT(*)
FROM(
    SELECT
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
    END AS repeat_room_bucket
    
    FROM alinity_results
        INNER JOIN (
            SELECT alinity_results.tube_barcode, MAX(alinity_results.created_at) AS created_at FROM alinity_results GROUP BY alinity_results.tube_barcode
        ) AS alinity_results_agg on alinity_results.tube_barcode = alinity_results_agg.tube_barcode AND alinity_results.created_at = alinity_results_agg.created_at
        LEFT JOIN test_kits on test_kits.barcode = alinity_results.tube_barcode
        LEFT JOIN appointments on test_kits.appointment_id = appointments.id
        LEFT JOIN Box on Box.id = appointments.box_id
        LEFT JOIN testing_sites on testing_sites.id = appointments.testing_site_id
        LEFT JOIN patients on patients.id = appointments.patient_id
    
    WHERE TRUE
        AND appointments.result = 'POSITIVE'
        AND SUBSTRING(Box.barcode, 1, 8) = 'ARACK-TX'
        AND appointments.accessioned_lab_id = '3'
        AND appointments.resulted_at >= CURRENT_TIMESTAMP + INTERVAL '-24 hour'
) AS repeat_queue_positives
GROUP BY repeat_room_bucket