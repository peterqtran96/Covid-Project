

-- CLeaning Data in SQL Queries

SELECT *
FROM nashvillehousing


-- Standardize Date Format


SELECT SaleDate, CONVERT(Date,SaleDate)
FROM nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)


-- Populate Property Address Data


SELECT *
FROM nashvillehousing
ORDER BY ParcelID


SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b ON a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueid]
WHERE a.propertyaddress is null


UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b ON a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueid]




-- Breaking out Address into Individual Colums (Address, City, State)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',Propertyaddress) -1 ) as Address
,SUBSTRING(PropertyAddress,  CHARINDEX(',',Propertyaddress) +1 , LEN(PropertyAddress)) as Address
FROM nashvillehousing


ALTER TABLE Nashvillehousing
ADD propertysplitaddress NVARCHAR(255);

UPDATE Nashvillehousing
SET propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',Propertyaddress) -1 )

ALTER TABLE nashvillehousing
ADD propertysplitcity NVARCHAR(255);

UPDATE nashvillehousing
SET propertysplitcity = SUBSTRING(PropertyAddress,  CHARINDEX(',',Propertyaddress) +1 , LEN(PropertyAddress))


SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM nashvillehousing

ALTER TABLE Nashvillehousing
ADD ownersplitaddress NVARCHAR(255);

UPDATE Nashvillehousing
SET ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)



ALTER TABLE nashvillehousing
ADD ownersplitcity NVARCHAR(255);

UPDATE nashvillehousing
SET ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE nashvillehousing
ADD ownersplitstate NVARCHAR(255);

UPDATE nashvillehousing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)


-- Change Y and N to Yes and No in 'Sold as Vacant" field


SELECT soldasvacant
, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
       ELSE soldasvacant
	   END
FROM nashvillehousing

UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
       ELSE soldasvacant
	   END
	

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM nashvillehousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete Unused Colums

ALTER TABLE nashvillehousing
DROP COLUMN Owneraddress, taxdistrict, propertyaddress

ALTER TABLE nashvillehousing
DROP COLUMN saledate