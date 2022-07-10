SELECT 
    test_kits.barcode AS test_kits_barcode,
    CASE WHEN appointments.result IS NULL
            THEN 'Missed Exceptions'
        WHEN appointments.result = 'POSITIVE'
            AND (testing_sites.state = 'NM' AND patients.state = 'NM')
            AND alinity_results.cn < 26
            THEN 'Strong NM < 26'
        WHEN appointments.result = 'POSITIVE'
            AND (testing_sites.state = 'NM' AND patients.state = 'NM')
            AND alinity_results.cn < 30
            THEN 'Strong NM 26-30'
        WHEN appointments.result = 'POSITIVE'
            AND SUBSTRING(patients.zipcode,1,5)  IN ('76574', '78605', '78610', '78612', '78613', '78615', '78616', '78617', '78620', '78621', '78626', '78628', '78634', '78640', '78641', '78642', '78644', '78645', '78652', '78653', '78654', '78660', '78663', '78664', '78665', '78669', '78681', '78701', '78702', '78703', '78704', '78705', '78712', '78717', '78719', '78721', '78722', '78723', '78724', '78725', '78726', '78727', '78728', '78729', '78730', '78731', '78732', '78733', '78734', '78735', '78736', '78737', '78738', '78739', '78741', '78742', '78744', '78745', '78746', '78747', '78748', '78749', '78750', '78751', '78752', '78753', '78754', '78756', '78757', '78758', '78759')
            AND alinity_results.cn < 26
            THEN 'APH < 26'
        WHEN appointments.result = 'POSITIVE'
            AND SUBSTRING(patients.zipcode,1,5)  IN ('76574', '78605', '78610', '78612', '78613', '78615', '78616', '78617', '78620', '78621', '78626', '78628', '78634', '78640', '78641', '78642', '78644', '78645', '78652', '78653', '78654', '78660', '78663', '78664', '78665', '78669', '78681', '78701', '78702', '78703', '78704', '78705', '78712', '78717', '78719', '78721', '78722', '78723', '78724', '78725', '78726', '78727', '78728', '78729', '78730', '78731', '78732', '78733', '78734', '78735', '78736', '78737', '78738', '78739', '78741', '78742', '78744', '78745', '78746', '78747', '78748', '78749', '78750', '78751', '78752', '78753', '78754', '78756', '78757', '78758', '78759')
            AND alinity_results.cn < 30
            THEN 'APH 26-30'
        WHEN appointments.result = 'POSITIVE'
            AND alinity_results.cn < 26
            THEN 'Strong Positives'
        WHEN appointments.result = 'POSITIVE'
            AND alinity_results.cn >= 26
            THEN 'Weak Positives'
        WHEN appointments.result IN ('NEGATIVE', 'INDETERMINATE')
            THEN 'Negative Rack'
        WHEN appointments.result IN ('QNS', 'TNP', 'SNR')
            THEN 'Special Operations'
        ELSE 'Missed Exceptions'
    END AS bucket, 
    appointments.result AS result, 
    alinity_results.cn, 
    testing_sites.state AS testing_site_state, 
    patients.state AS patients_state, 
    patients.zipcode AS patients_zipcode,
    Box.barcode AS box_barcode,
    concat(CASE WHEN appointments.box_y_position = 0 THEN 'A' 
                WHEN appointments.box_y_position = 1 THEN 'B' 
                WHEN appointments.box_y_position = 2 THEN 'C' 
                WHEN appointments.box_y_position = 3 THEN 'D' 
                WHEN appointments.box_y_position = 4 THEN 'E' 
                WHEN appointments.box_y_position = 5 THEN 'F' 
                WHEN appointments.box_y_position = 6 THEN 'G' 
                WHEN appointments.box_y_position = 7 THEN 'H' 
                ELSE '' END, 
            CASE WHEN appointments.box_x_position = 0 THEN '1' 
                WHEN appointments.box_x_position = 1 THEN '2' 
                WHEN appointments.box_x_position = 2 THEN '3' 
                WHEN appointments.box_x_position = 3 THEN '4' 
                WHEN appointments.box_x_position = 4 THEN '5' 
                WHEN appointments.box_x_position = 5 THEN '6' 
                WHEN appointments.box_x_position = 6 THEN '7' 
                WHEN appointments.box_x_position = 7 THEN '8' 
                WHEN appointments.box_x_position = 8 THEN '9' 
                WHEN appointments.box_x_position = 9 THEN '10' 
                WHEN appointments.box_x_position = 10 THEN '11' 
                WHEN appointments.box_x_position = 11 THEN '12' 
                ELSE '' END) AS box_posn

FROM alinity_results
INNER JOIN (
        select alinity_results.tube_barcode, MAX(alinity_results.created_at) AS created_at from alinity_results GROUP BY alinity_results.tube_barcode
    ) AS alinity_results_agg on alinity_results.tube_barcode = alinity_results_agg.tube_barcode AND alinity_results.created_at = alinity_results_agg.created_at
	LEFT JOIN test_kits on alinity_results.tube_barcode = test_kits.barcode
	LEFT JOIN appointments on test_kits.appointment_id = appointments.id
	LEFT JOIN patients on patients.id = appointments.patient_id
	LEFT JOIN Box on Box.id = appointments.Box_id
	LEFT JOIN testing_sites on testing_sites.id = appointments.testing_site_id

WHERE {{box_barcode}}

ORDER BY appointments.box_y_position, appointments.box_x_position