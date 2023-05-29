/*
CLEANING DATA
*/
SELECT SaleDateconverted
FROM NashvilleHousing

-- Standardizing Date Format
-------------------------------------------------------------------
--The approach below did not work but using the alter table to add the new column and later add the values from the saledate colum to  the new column actually worked
SELECT SaleDate, CONVERT(date, saledate) as NewSaleDate
FROM NashvilleHousing

ALTER Table nashvillehousing
Add saleDateConverted date;

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(date, saledate)

--Populate Property Address
----------------------------------------------------------
 SELECT *
 FROM NashvilleHousing
 --WHERE PropertyAddress is null
 ORDER BY ParcelID

--Check whether there are duplicates
SELECT PropertyAddress
FROM NashvilleHousing
WHERE ParcelID = '025 07 0 031.00' 


--Check for nulls
 SELECT nash1.ParcelID, nash1.PropertyAddress, nash2.ParcelID, nash2.PropertyAddress, isnull( nash1.PropertyAddress, nash2.PropertyAddress)
 FROM NashvilleHousing as nash1
 JOIN NashvilleHousing as nash2
	on nash1.ParcelID = nash2.ParcelID
	and nash1.[UniqueID ]<>nash2.[UniqueID ]
WHERE nash1.PropertyAddress is null

--Replace nulls with the actual property addresses
UPDATE nash1
SET PropertyAddress = isnull( nash1.PropertyAddress, nash2.PropertyAddress)
FROM NashvilleHousing as nash1
 JOIN NashvilleHousing as nash2
	on nash1.ParcelID = nash2.ParcelID
	and nash1.[UniqueID ]<>nash2.[UniqueID ]
WHERE nash1.PropertyAddress is null

--Breaking our adress in to individual columns ( address, city, state)
SELECT PropertyAddress
FROM NashvilleHousing

--Getting rid of the delimiter "," from the property address using substring
SELECT
SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address,
SUBSTRING (propertyaddress, charindex(', ', propertyaddress)+1, LEN(propertyaddress)) AS Address2
FROM NashvilleHousing

--adding the new columns and updating them
ALTER TABLE nashvillehousing
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (propertyaddress, charindex(', ', propertyaddress)+1, LEN(propertyaddress))

--check if the query was a success
SELECT * 
FROM NashvilleHousing

----Owner address using parsename and replace
SELECT 
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
FROM NashvilleHousing

--adding the new columns and updating them
ALTER Table nashvillehousing
add OwnerSplitAddress varchar(255)
UPDATE NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER Table nashvillehousing
add OwnerSplitCity varchar(255)
UPDATE NashvilleHousing
SET OwnerSplitCity =  PARSENAME(replace(owneraddress, ',','.'),2)

ALTER Table nashvillehousing
add OwnerSplitState varchar(255)
UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(replace(owneraddress, ',','.'), 1)

--check if the query was a success
SELECT *
FrOM NashvilleHousing

------------------------------------------------------------------------------------
--Changing Y to Yes and N to No in the "Sold as Vacant" field
--- CHeck for any occurances of Y, Yes, N, No
SELECT DISTINCT (SoldAsVacant), COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER By 2

--Usw case statement to update the columns 
SELECT SoldAsVacant,  
	CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

--Update the soldasvacant column using the case statement
UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end



---Remove duplicates using a CTE
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				ORDER BY 
					uniqueID
					) as row_num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

--Deleting unused columns (dont do this to your raw data in the database)
ALTER TABLE nashvillehousing
DROP column owneraddress, taxdistrict, propertyaddress

ALTER TABLE nashvillehousing
DROP column saledate

SELECT *
FROM NashvilleHousing
WHERE LandUse = 'Residential Condo'