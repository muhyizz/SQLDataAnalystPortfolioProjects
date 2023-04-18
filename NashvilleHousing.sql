/*

Data Cleaning

*/

SELECT *
FROM PortfolioProject.dbo.updateNashville

/*

*/

-- Standardizing Date Format

ALTER TABLE updateNashville
ADD SaleDateConverted Date

UPDATE updateNashville
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, SaleDate, CONVERT(Date,SaleDate)
FROM updateNashville

/*

*/

-- Populating Property Missing Address Data

SELECT *
FROM PortfolioProject.dbo.updateNashville
ORDER BY ParcelID

SELECT 
First.ParcelID, First.PropertyAddress,
Second.ParcelID, Second.PropertyAddress,
ISNULL(First.PropertyAddress,Second.PropertyAddress)
FROM updateNashville First
JOIN updateNashville Second
	ON First.ParcelID = Second.ParcelID
	AND First.[UniqueID ] <> Second.[UniqueID ]
WHERE First.PropertyAddress is null

UPDATE First
SET PropertyAddress = ISNULL(First.PropertyAddress, Second.PropertyAddress)
FROM updateNashville First
JOIN updateNashville Second
	ON First.ParcelID = Second.ParcelID
	AND First.[UniqueID ] = Second.[UniqueID ]
WHERE First.PropertyAddress is NULL

SELECT PropertyAddress
FROM PortfolioProject.dbo.updateNashville
WHERE PropertyAddress = NULL

/*

*/

-- Splitting out address into individual columns (Address, City, State)

-- Using Substring

SELECT PropertyAddress
FROM updateNashville

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS State
FROM updateNashville

ALTER TABLE updateNashville
ADD PropertyHomeAddress Nvarchar(255);

UPDATE updateNashville
SET PropertyHomeAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE updateNashville
ADD PropertyCity Nvarchar(255);

UPDATE updateNashville
SET PropertyCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertyHomeAddress, PropertyCity
FROM updateNashville

-- Using Parsename

SELECT OwnerAddress
FROM updateNashville

SELECT
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
FROM updateNashville

ALTER TABLE updateNashville
ADD OwnerHouseAddress Nvarchar(255);

UPDATE updateNashville
SET OwnerHouseAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

ALTER TABLE updateNashville
ADD OwnerCity Nvarchar(255);

UPDATE updateNashville
SET OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

ALTER TABLE updateNashville
ADD OwnerState Nvarchar(255);

UPDATE updateNashville
SET OwnerState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

SELECT OwnerAddress,OwnerHouseAddress,OwnerCity,OwnerState
FROM updateNashville

/*

*/

-- Removing error in sold as vacant 

SELECT *
FROM updateNashville

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM updateNashville
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM updateNashville

UPDATE updateNashville
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant= 'Y' THEN 'Yes'
	WHEN SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
END

/*

*/

-- Removing Duplicates

SELECT *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY UniqueID) row_num
FROM updateNashville

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY UniqueID) row_num
FROM updateNashville
)

Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID

WITH RowNumCTEdelete AS (
SELECT *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY UniqueID) row_num
FROM updateNashville
)

DELETE
FROM RowNumCTEdelete
WHERE row_num > 1

/*

*/

ALTER TABLE updateNashville
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress

/*

*/

-- Creating View

SELECT *
FROM updateNashville

CREATE VIEW cleanUpdateNashville AS
SELECT * 
FROM updateNashville;

SELECT * FROM cleanUpdateNashville



