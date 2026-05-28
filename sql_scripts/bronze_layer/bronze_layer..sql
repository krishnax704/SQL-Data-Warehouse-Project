create or alter procedure bronze.load_bronze as
begin
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time datetime, @batch_end_time datetime;
	begin try
		set @batch_start_time = GETDATE();
		print '======================================'
		print 'Loading bronze layer'
		print '======================================'

		print '------------------------------------'
		print 'Loading CRM Tables'
		print '------------------------------------'

		SET @start_time = getdate();
		print '>> Truncating Table: bronze.crm_cust_info'
		truncate table bronze.crm_cust_info;

		print '>> Inserting Data into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		SET @start_time = getdate();
		print '>> Truncating Table: bronze.crm_prd_info'
		truncate table bronze.crm_prd_info;

		print '>> Inserting Data into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		SET @start_time = getdate();
		print '>> Truncating Table: bronze.crm_sales_details'
		truncate table bronze.crm_sales_details;

		print '>> Inserting Data into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		print '------------------------------------'
		print 'Loading ERP Tables'
		print '------------------------------------'
	
		SET @start_time = getdate();
		print '>> Truncating Table: bronze.erp_CUST_AZ12'
		truncate table bronze.erp_CUST_AZ12;

		print '>> Inserting Data into: bronze.erp_CUST_AZ12'
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		SET @start_time = getdate();
		print '>> Truncating Table: bronze.erp_loc_a101'
		truncate table bronze.erp_loc_a101;

		print '>> Inserting Data into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		SET @start_time = getdate();
		print '>> Truncating Table: bronze.erp_px_cat_g1v2'
		truncate table bronze.erp_px_cat_g1v2;

		print '>> Inserting Data into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\krish\Downloads\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT '>> Load Duration: ' + cast (DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + 'seconds';
		PRINT '>> --------------------';

		SET	@batch_end_time = GETDATE();
		PRINT '==================================='
		PRINT 'Loading Bronze Layer is completed';
		PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) as nvarchar) + '  seconds';
		PRINT '==================================='
	end try
	begin catch
		print '==================================='
		print 'ERROR OCCURED DURING BRONZE LAYER'
		print 'Error Message' + ERROR_MESSAGE();
		print 'Error Message' + CAST (ERROR_NUMBER() as NVARCHAR);
		print 'Error Message' + CAST (ERROR_STATE() as NVARCHAR);
		print '==================================='
	end catch
end