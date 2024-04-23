MERGE INTO {var_table_name} AS target
        USING {var_temp_table_name} AS source
        ON target.comhis_date = source.comhis_date AND target.comhis_day_week = source.comhis_day_week AND target.comhis_commodity = source.comhis_commodity
        WHEN MATCHED THEN
            UPDATE SET target.comhis_date = source.comhis_date, target.comhis_day_week = source.comhis_day_week, target.comhis_commodity = source.comhis_commodity,
                target.comhis_SAP_product = source.comhis_SAP_product, target.comhis_price = source.comhis_price, target.comhis_indicator = source.comhis_indicator,
                target.comhis_unit = source.comhis_unit
        WHEN NOT MATCHED THEN
            INSERT (comhis_date, comhis_day_week, comhis_commodity, comhis_SAP_product, comhis_price, comhis_indicator, comhis_unit) VALUES
                (source.comhis_date, source.comhis_day_week, source.comhis_commodity, source.comhis_SAP_product, source.comhis_price, source.comhis_indicator, source.comhis_unit);
