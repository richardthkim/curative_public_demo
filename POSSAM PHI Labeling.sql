SELECT test_kits.barcode, patients.full_name, patients.date_of_birth, 
to_char(appointments.completed_at, 'yyyy-MM-dd hh24:mi:ss') AS completed_at, 
concat(CASE WHEN "public"."appointments"."box_y_position" = 0 THEN 'A' 
            WHEN "public"."appointments"."box_y_position" = 1 THEN 'B' 
            WHEN "public"."appointments"."box_y_position" = 2 THEN 'C' 
            WHEN "public"."appointments"."box_y_position" = 3 THEN 'D' 
            WHEN "public"."appointments"."box_y_position" = 4 THEN 'E' 
            WHEN "public"."appointments"."box_y_position" = 5 THEN 'F' 
            WHEN "public"."appointments"."box_y_position" = 6 THEN 'G' 
            WHEN "public"."appointments"."box_y_position" = 7 THEN 'H' ELSE 'error' END, 
        CASE WHEN "public"."appointments"."box_x_position" = 0 THEN '1' 
            WHEN "public"."appointments"."box_x_position" = 1 THEN '2' 
            WHEN "public"."appointments"."box_x_position" = 2 THEN '3' 
            WHEN "public"."appointments"."box_x_position" = 3 THEN '4' 
            WHEN "public"."appointments"."box_x_position" = 4 THEN '5' 
            WHEN "public"."appointments"."box_x_position" = 5 THEN '6' 
            WHEN "public"."appointments"."box_x_position" = 6 THEN '7' 
            WHEN "public"."appointments"."box_x_position" = 7 THEN '8' 
            WHEN "public"."appointments"."box_x_position" = 8 THEN '9' 
            WHEN "public"."appointments"."box_x_position" = 9 THEN '10' 
            WHEN "public"."appointments"."box_x_position" = 10 THEN '11' 
            WHEN "public"."appointments"."box_x_position" = 11 THEN '12' ELSE 'error' END) AS "POSN",
Box.barcode

FROM test_kits
    LEFT JOIN appointments on test_kits.appointment_id = appointments.id
    LEFT JOIN patients on appointments.patient_id = patients.id
    LEFT JOIN Box on appointments.box_id = Box.id
    
WHERE FALSE [[OR Box.barcode = {{box_barcode}}]]

ORDER BY appointments.box_y_position, appointments.box_x_position