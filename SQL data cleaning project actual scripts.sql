-- Populate Property Address data

SELECT *
FROM NashvilleHousing
--WHERE propertyaddress IS NULL;
ORDER BY ParcelID

-- Houses with the same parcel id (parcelid) have the same property address (propertyaddress) too.
-- So if the first house doesn't have a property address but other house with the same parcel id does,
-- we can get property address from the second house and set it as a property address of the first one.

SELECT n.parcelid, n.propertyaddress
, h.parcelid, h.propertyaddress
, COALESCE(n.propertyaddress, h.propertyaddress)
FROM NashvilleHousing n
JOIN NashvilleHousing h
ON n.parcelid = h.parcelid AND n.uniqueid != h.uniqueid
WHERE n.propertyaddress IS NULL;

-- Updating the original table
UPDATE NashvilleHousing nh
SET propertyaddress = (
	SELECT COALESCE(n.propertyaddress, h.propertyaddress)
	FROM NashvilleHousing n
	JOIN NashvilleHousing h
	ON n.parcelid = h.parcelid AND n.uniqueid != h.uniqueid
	WHERE n.propertyaddress IS NULL
	AND nh.uniqueid = n.uniqueid
	LIMIT 1
	)
WHERE propertyaddress IS NULL;


-- Breaking out PropertyAddress into Individual columns (Address, City, State)

SELECT propertyaddress
FROM NashvilleHousing;

SELECT propertyaddress,
SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) AS address
, SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 2) AS city
FROM NashvilleHousing;

--Creating new columns for split address

ALTER TABLE NashvilleHousing
ADD COLUMN address VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD COLUMN city VARCHAR(255);

-- Updating table adding values to new columns

UPDATE NashvilleHousing
SET address = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1);
UPDATE NashvilleHousing
SET city = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 2);

-- Breaking out OwnerAddress into Individual columns (Address, City, State)

SELECT owneraddress, SPLIT_PART(owneraddress, ',', 1) AS owner_address
,SPLIT_PART(owneraddress, ',', 2) AS owner_city
,SPLIT_PART(owneraddress, ',', 3) AS owner_state
FROM NashvilleHousing;

--Creating new columns for split owneraddress

ALTER TABLE NashvilleHousing
ADD COLUMN owner_address VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD COLUMN owner_city VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD COLUMN owner_state VARCHAR(255);

-- Updating table adding values to new columns
UPDATE NashvilleHousing
SET owner_address = SPLIT_PART(owneraddress, ',', 1);
UPDATE NashvilleHousing
SET owner_city = SPLIT_PART(owneraddress, ',', 2);
UPDATE NashvilleHousing
SET owner_state = SPLIT_PART(owneraddress, ',', 3);

-- Change 'Y' and 'N' to 'Yes' and 'No' in 'Sold as Vacant' field

SELECT DISTINCT(soldasvacant)
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant END;

-- Remove Duplicates
-- Find duplicates using row_number function in cte
WITH row_num_cte AS(
SELECT *
, ROW_NUMBER() OVER(PARTITION BY parcelid, 
				   				 propertyaddress,
				   				 saleprice,
				   				 legalreference
				   	ORDER BY uniqueid) AS row_num
FROM NashvilleHousing
ORDER BY parcelid)
SELECT *
FROM row_num_cte
WHERE row_num >1;

-- Delete duplicates from the previous step 
WITH row_num_cte AS(
	SELECT *
	, ROW_NUMBER() OVER(PARTITION BY parcelid, 
									 propertyaddress,
									 saleprice,
									 legalreference
						ORDER BY uniqueid) AS row_num
	FROM NashvilleHousing
	)
DELETE FROM NashvilleHousing
WHERE uniqueid IN (
		SELECT uniqueid
		FROM row_num_cte
		WHERE row_num >1
	);

-- Remove unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress
,DROP COLUMN taxdistrict
,DROP COLUMN propertyaddress;

