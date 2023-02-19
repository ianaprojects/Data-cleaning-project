DROP TABLE IF EXISTS NashvilleHousing;
CREATE TABLE NashvilleHousing(
UniqueID 		INT,
ParcelID		VARCHAR(255),
LandUse			VARCHAR(255),
PropertyAddress	VARCHAR(255),
SaleDate		DATE,
SalePrice		VARCHAR(255),
LegalReference	VARCHAR(255),
SoldAsVacant	VARCHAR(255),
OwnerName		VARCHAR(255),
OwnerAddress	VARCHAR(255),
Acreage			FLOAT,
TaxDistrict		VARCHAR(255),
LandValue		INT,
BuildingValue	INT,
TotalValue		INT,
YearBuilt		INT,
Bedrooms		INT,
FullBath		INT,
HalfBath		INT
);

SELECT * FROM NashvilleHousing;