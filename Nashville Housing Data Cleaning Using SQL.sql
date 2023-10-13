/*
Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format---------------------

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address Data---------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- USING JOINS---------------------
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- UPDATE JOINS
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)---------------------
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address


FROM PortfolioProject.dbo.NashvilleHousing

--ADDING NEW COLUMNS---------------------
--COLUMN 1: ADDING PropertySplitAddress 
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--COLUMN 2: ADDING PropertySplityCity---------------------
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Owner Address Column
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- OwnerAddress Column in the correct order using PARSENAME
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', ','), 3),
PARSENAME(REPLACE(OwnerAddress, ',', ','), 2),
PARSENAME(REPLACE(OwnerAddress, ',', ','), 1)
FROM PortfolioProject.dbo.NashvilleHousing

-- ADDING OwnerSplitAddress Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', ','), 3)

-- ADDING OwnerSplitCity Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', ','), 2)

-- ADDING OwnerSplitState Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitState  NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', ','), 1)

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to YES and NO in "Sold as Vacant' Field---------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Removing Duplicates---------------------

WITH ROWNUMCTE AS(
SELECT*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UNIQUEID
				) ROW_NUM


FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT*
FROM ROWNUMCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

--DELETE UNSUSED COLUMNS---------------------
SELECT*
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate