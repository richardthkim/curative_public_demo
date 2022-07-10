SELECT port_number, STRING_AGG(machine_name, '; ') AS machine_name,
    CASE WHEN machine_name = 'Alinity m-M00797' THEN 'A1'
        WHEN machine_name = 'Alinity m-M00798' THEN 'A2'
        WHEN machine_name = 'Alinity m-M00796' THEN 'A3'
        WHEN machine_name = 'Alinity m-M00795' THEN 'A4'
        WHEN machine_name = 'Alinity m-M00779' THEN 'A5'
        WHEN machine_name = 'Alinity m-M00792' THEN 'A6'
        WHEN machine_name = 'Alinity m-M00794' THEN 'A7'
        WHEN machine_name = 'Alinity m-M00793' THEN 'A8'
        WHEN machine_name = 'Alinity m-M00773' THEN 'B1'
        WHEN machine_name = 'Alinity m-M00775' THEN 'B2'
        WHEN machine_name = 'Alinity m-M00776' THEN 'B3'
        WHEN machine_name = 'Alinity m-M00774' THEN 'B4'
        WHEN machine_name = 'Alinity m-M00772' THEN 'B5'
        WHEN machine_name = 'Alinity m-M00768' THEN 'B6'
        WHEN machine_name = 'Alinity m-M00762' THEN 'B7'
        WHEN machine_name = 'Alinity m-M00767' THEN 'B8'
        WHEN machine_name = 'Alinity m-M00766' THEN 'C1'
        WHEN machine_name = 'Alinity m-M00761' THEN 'C2'
        WHEN machine_name = 'Alinity m-M00771' THEN 'C3'
        WHEN machine_name = 'Alinity m-M00770' THEN 'C4'
        WHEN machine_name = 'Alinity m-M00769' THEN 'C5'
        WHEN machine_name = 'Alinity m-M00699' THEN 'D1'
        WHEN machine_name = 'Alinity m-M00700' THEN 'D2'
        WHEN machine_name = 'Alinity m-M00698' THEN 'D3'
        WHEN machine_name = 'Alinity m-M00704' THEN 'D4'
        WHEN machine_name = 'Alinity m-M00697' THEN 'E1'
        WHEN machine_name = 'Alinity m-M00696' THEN 'E2'
        WHEN machine_name = 'Alinity m-M00702' THEN 'E3'
        WHEN machine_name = 'Alinity m-M00701' THEN 'E4'
        WHEN machine_name = 'Alinity m-M00705' THEN 'E5'
        WHEN machine_name = 'Alinity m-M00703' THEN 'E6'
        END AS local_machine_name,
    CASE WHEN machine_name IN ('Alinity m-M00797', 'Alinity m-M00798', 'Alinity m-M00796', 'Alinity m-M00795', 'Alinity m-M00779', 'Alinity m-M00792', 'Alinity m-M00794', 'Alinity m-M00793') THEN 'A'
        WHEN machine_name IN ('Alinity m-M00773', 'Alinity m-M00775', 'Alinity m-M00776', 'Alinity m-M00774', 'Alinity m-M00772', 'Alinity m-M00768', 'Alinity m-M00762', 'Alinity m-M00767') THEN 'B'
        WHEN machine_name IN ('Alinity m-M00766', 'Alinity m-M00761', 'Alinity m-M00771', 'Alinity m-M00770', 'Alinity m-M00769') THEN 'C'
        WHEN machine_name IN ('Alinity m-M00699', 'Alinity m-M00700', 'Alinity m-M00698', 'Alinity m-M00704') THEN 'D'
        WHEN machine_name IN ('Alinity m-M00697', 'Alinity m-M00696', 'Alinity m-M00702', 'Alinity m-M00701', 'Alinity m-M00705', 'Alinity m-M00703') THEN 'E'
    END AS local_machine_room

FROM
    (
        SELECT DISTINCT
            port_number,
            lab_id,
            LEFT(alinity_machine_name, 16) AS machine_name
        FROM alinity_messages
    WHERE TRUE
        AND created_at >= CURRENT_DATE + INTERVAL '-6 day'
        AND alinity_machine_name IS NOT NULL
    ) AS port_machine_mapping
WHERE lab_id = 3
GROUP BY port_number, lab_id, port_machine_mapping.machine_name